import numpy as np
import pandas as pd

class InventoryLogic:
    @staticmethod
    def calculate_safety_stock(z_score, std_dev, lead_time):
        """
        IS = Z * sigma * sqrt(LT)
        """
        return z_score * std_dev * np.sqrt(lead_time)

    @staticmethod
    def calculate_reorder_point(avg_demand, lead_time, safety_stock):
        """
        PR = (Demanda promedio * Tiempo de entrega) + IS
        """
        return (avg_demand * lead_time) + safety_stock

    @staticmethod
    def calculate_suggested_order(reorder_point, current_stock):
        """
        Cantidad a pedir = PR - Stock actual
        """
        suggested = reorder_point - current_stock
        return max(0, suggested)

    @staticmethod
    def analyze_sales_data(sales_df):
        """
        Analyzes sales data to get average demand and standard deviation.
        Expected columns: ['referencia', 'cantidad', 'fecha']
        """
        # Ensure date format
        sales_df['fecha'] = pd.to_datetime(sales_df['fecha'])
        
        # Group by reference and calculate metrics
        stats = sales_df.groupby('referencia')['cantidad'].agg(['mean', 'std']).reset_index()
        stats.columns = ['referencia', 'avg_demand', 'std_dev']
        
        # Fill NaN std_dev with 0
        stats['std_dev'] = stats['std_dev'].fillna(0)
        
        return stats
