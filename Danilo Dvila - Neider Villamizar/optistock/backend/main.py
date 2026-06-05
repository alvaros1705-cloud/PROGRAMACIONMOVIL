from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import pandas as pd
import io
import os
import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime
from core.inventory import InventoryLogic

app = FastAPI(title="OptiStock Analysis API")

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize Firebase Admin SDK
# Note: You need to download 'serviceAccountKey.json' from Firebase Console
# Project Settings -> Service Accounts -> Generate New Private Key
try:
    if not firebase_admin._apps:
        cred_path = 'serviceAccountKey.json'
        if os.path.exists(cred_path):
            cred = credentials.Certificate(cred_path)
            firebase_admin.initialize_app(cred)
            print("Firebase Admin SDK initialized successfully")
        else:
            print("Warning: serviceAccountKey.json not found. Firestore features disabled.")
except Exception as e:
    print(f"Error initializing Firebase: {e}")

db = firestore.client() if firebase_admin._apps else None

@app.get("/")
async def root():
    return {"message": "OptiStock API is running"}

@app.post("/analyze-inventory")
async def analyze_inventory(
    file: UploadFile = File(...),
    z_score: float = 1.645,
    lead_time: float = 20
):
    if not file.filename.endswith(('.xlsx', '.xls')):
        raise HTTPException(status_code=400, detail="Invalid file format.")

    try:
        content = await file.read()
        df = pd.read_excel(io.BytesIO(content))
        # Normalize column names (strip whitespace)
        df.columns = [str(c).strip() for c in df.columns]
        print(f"[analyze] Columnas detectadas: {list(df.columns)}")

        # --- Support new Odoo-style format: "Producto" + "Terminado" ---
        if 'Producto' in df.columns and 'Terminado' in df.columns:
            import re

            # Extract reference from brackets [REF] in Producto column
            def extract_ref(val):
                match = re.search(r'\[([^\]]+)\]', str(val))
                return match.group(1).strip() if match else str(val).strip()

            df['referencia'] = df['Producto'].apply(extract_ref)
            df['cantidad'] = pd.to_numeric(df['Terminado'], errors='coerce').fillna(0)

            # --- Handle 'Transferir' column for inventory movements ---
            if 'Transferir' in df.columns:
                df['Transferir_str'] = df['Transferir'].astype(str).str.strip().str.lower()
                def get_mov_type(val):
                    if val.startswith('ent') or val.startswith('dev'):
                        return 'in'
                    elif val.startswith('wh'):
                        return 'out'
                    return 'out'
                df['mov_type'] = df['Transferir_str'].apply(get_mov_type)
            else:
                df['mov_type'] = 'out'

            # Keep only rows that have a valid reference and quantity > 0
            df = df[df['referencia'].notna() & (df['referencia'] != '') & (df['cantidad'] > 0)]

            # Calculate stock change (in = +cantidad, out = -cantidad)
            df['stock_change'] = df.apply(lambda row: row['cantidad'] if row['mov_type'] == 'in' else -row['cantidad'], axis=1)
            stock_changes = df.groupby('referencia')['stock_change'].sum().reset_index()

            # Group by reference: total sold over period (only 'out' counts as demand)
            sales_df = df[df['mov_type'] == 'out']
            PERIOD_DAYS = 90
            grouped = sales_df.groupby('referencia')['cantidad'].agg(['sum', 'count']).reset_index()
            grouped.columns = ['referencia', 'total_vendido', 'num_transacciones']

            # Simulate daily demand: avg = total / days, std = sqrt(avg) (Poisson approximation)
            grouped['avg_demand'] = grouped['total_vendido'] / PERIOD_DAYS
            grouped['std_dev'] = (grouped['avg_demand'] ** 0.5).clip(lower=0)
            
            stats = pd.merge(stock_changes, grouped[['referencia', 'avg_demand', 'std_dev']], on='referencia', how='left').fillna({'avg_demand': 0, 'std_dev': 0})

        # --- Support legacy format: referencia, cantidad, fecha, tipo_movimiento ---
        elif all(col in df.columns for col in ['referencia', 'cantidad', 'fecha', 'tipo_movimiento']):
            sales_df = df[df['tipo_movimiento'].str.lower() == 'venta'].copy()
            stats = InventoryLogic.analyze_sales_data(sales_df)
        else:
            raise HTTPException(
                status_code=400,
                detail="Formato no reconocido. Use columnas 'Producto'+'Terminado' o 'referencia'+'cantidad'+'fecha'+'tipo_movimiento'."
            )

        results = []
        if db:
            batch = db.batch()
            batch_count = 0

        for _, row in stats.iterrows():
            is_val = InventoryLogic.calculate_safety_stock(z_score, row['std_dev'], lead_time)
            pr_val = InventoryLogic.calculate_reorder_point(row['avg_demand'], lead_time, is_val)

            now_str = datetime.now().isoformat()
            firestore_data = {
                "referencia": row['referencia'],
                "demanda_promedio_diaria": round(float(row['avg_demand']), 4),
                "desviacion_estandar": round(float(row['std_dev']), 4),
                "stock_seguridad": round(is_val, 2),
                "punto_reorden": round(pr_val, 2),
                "lead_time_dias": lead_time,
                "ultima_actualizacion": datetime.now()
            }
            
            # Increment stock if there is a net change
            net_change = int(row.get('stock_change', 0))
            if net_change != 0 and db:
                firestore_data["stock_actual"] = firestore.Increment(net_change)

            # JSON-safe version (no datetime objects)
            json_data = {
                "referencia": row['referencia'],
                "demanda_promedio_diaria": round(float(row['avg_demand']), 4),
                "desviacion_estandar": round(float(row['std_dev']), 4),
                "stock_seguridad": round(is_val, 2),
                "punto_reorden": round(pr_val, 2),
                "lead_time_dias": lead_time,
                "ultima_actualizacion": now_str,
                "stock_change_aplicado": net_change
            }

            if db:
                doc_ref = db.collection('productos').document(row['referencia'])
                batch.set(doc_ref, firestore_data, merge=True)
                batch_count += 1
                if batch_count == 400:
                    batch.commit()
                    batch = db.batch()
                    batch_count = 0

            results.append(json_data)

        if db and batch_count > 0:
            batch.commit()

        return {
            "status": "success",
            "firebase_sync": db is not None,
            "lead_time_usado": lead_time,
            "total_referencias": len(results),
            "data": results
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")


@app.post("/upload-initial-inventory")
async def upload_initial_inventory(file: UploadFile = File(...)):
    if not file.filename.endswith(('.xlsx', '.xls')):
        raise HTTPException(status_code=400, detail="Invalid file format.")

    try:
        content = await file.read()
        df = pd.read_excel(io.BytesIO(content))
        # Normalize column names (strip whitespace)
        df.columns = [str(c).strip() for c in df.columns]
        print(f"[initial] Columnas detectadas: {list(df.columns)}")

        required_columns = ['Referencia interna', 'Cantidad a la mano']
        if not all(col in df.columns for col in required_columns):
            raise HTTPException(
                status_code=400,
                detail=f"Faltan columnas. Se encontraron: {list(df.columns)}. Se esperan: {required_columns}"
            )

        results = []
        if db:
            batch = db.batch()
            batch_count = 0
            
        for _, row in df.iterrows():
            referencia = str(row['Referencia interna']).strip()
            if not referencia or str(row['Referencia interna']).lower() == 'nan':
                continue
            
            try:
                cantidad = float(row['Cantidad a la mano'])
            except:
                cantidad = 0.0

            if db:
                firestore_data = {
                    "referencia": referencia,
                    "stock_actual": cantidad,
                    "ultima_actualizacion_stock": datetime.now()
                }
                doc_ref = db.collection('productos').document(referencia)
                batch.set(doc_ref, firestore_data, merge=True)
                batch_count += 1
                if batch_count == 400:
                    batch.commit()
                    batch = db.batch()
                    batch_count = 0
            
            # JSON-safe (no datetime)
            results.append({"referencia": referencia, "stock_actual": cantidad})

        if db and batch_count > 0:
            batch.commit()

        return {
            "status": "success",
            "message": f"Se actualizaron {len(results)} productos.",
            "data": results
        }
    except HTTPException:
        raise
    except Exception as e:
        import traceback
        print(f"[initial] ERROR: {traceback.format_exc()}")
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")

@app.get("/export-report")
async def export_report():
    if not db:
        raise HTTPException(status_code=500, detail="Firestore not initialized")
    
    try:
        # Get all products from Firestore
        products_ref = db.collection('productos').stream()
        data = []
        for doc in products_ref:
            p = doc.to_dict()
            stock = p.get('stock_actual', 0)
            pr = p.get('punto_reorden', 0)
            
            if stock <= pr:
                suggested = pr - stock
                data.append({
                    "Referencia": p.get('referencia', ''),
                    "Stock Actual": stock,
                    "Punto de Reorden": pr,
                    "Stock de Seguridad": p.get('stock_seguridad', 0),
                    "Demanda Promedio": p.get('demanda_promedio', 0),
                    "CANTIDAD A PEDIR": round(suggested, 0)
                })
        
        if not data:
            return {"message": "No hay pedidos sugeridos en este momento."}
            
        # Create Excel in memory
        df = pd.DataFrame(data)
        output = io.BytesIO()
        with pd.ExcelWriter(output, engine='openpyxl') as writer:
            df.to_excel(writer, index=False, sheet_name='Sugerencias de Pedido')
        
        output.seek(0)
        
        from fastapi.responses import StreamingResponse
        return StreamingResponse(
            io.BytesIO(output.read()),
            media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            headers={"Content-Disposition": "attachment; filename=reporte_pedidos_optistock.xlsx"}
        )

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error generating report: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
