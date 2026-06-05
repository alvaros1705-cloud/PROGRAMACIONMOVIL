# 🔒 Sistema de Lock Screen POS - LicoStoke

## 🎯 Concepto: Pantalla de Bloqueo con PINes Rápidos

LicoStoke implementa un sistema tipo **Point of Sale (POS)** donde la pantalla de selección de perfiles actúa como **lock screen** permanente, permitiendo acceso rápido mediante PINes de 4 dígitos.

---

## ✨ Cambios Implementados

### **1. Pantalla de Selección de Perfiles como Lock Screen**

**Comportamiento Global:**

- ✅ La app **siempre arranca en la pantalla de perfiles** una vez configurada
- ✅ No requiere login con email/password en cada inicio
- ✅ Acceso rápido mediante PIN de 4 dígitos
- ✅ Perfiles desbloqueados permanentemente (Dueño, Gerente, Trabajador)

**Lógica de Inicio:**

```typescript
// Si el sistema está configurado (tiene ownerPin)
→ Arrancar en "Selecciona tu perfil" (lock screen)

// Si NO está configurado
→ Arrancar en Splash → Login → Configuración inicial
```

### **2. PIN de 4 Dígitos para TODOS los Perfiles**

**Antes:**
- ❌ Dueño: Login tradicional (email + password)
- ✅ Gerente: PIN de 4 dígitos
- ✅ Trabajador: Acceso directo

**Ahora:**
- ✅ **Dueño: PIN Maestro de 4 dígitos** (acceso rápido)
- ✅ **Gerente: PIN de 4 dígitos**
- ✅ **Trabajador: Acceso directo** (sin PIN, pero configurable)

**Ventajas:**
- ⚡ Acceso ultra rápido (4 dígitos vs email + password)
- 🔒 Seguridad mantenida
- 📱 Experiencia tipo POS/Tablet
- 🚀 Ideal para dispositivo compartido

### **3. Campo "PIN Maestro" en Control de Accesos**

**Nueva Sección Premium:**

- 📍 **Ubicación:** Primera sección en "Control de Accesos"
- 🎨 **Estilo:** Card con gradiente y borde cobre (#C89B6D)
- 👑 **Icono:** Crown (corona) para indicar nivel de administrador
- 🔢 **Input:** 4 dígitos, tipo password con botón revelar

**Título:** "Tu PIN Maestro de Acceso Rápido"
**Descripción:** "Define tu PIN de 4 dígitos para entrar sin usar contraseña"

**Características del Input:**
```css
- Texto centrado, tamaño 2xl, tracking widest
- Solo números (máximo 4 dígitos)
- Botón ojo/ojo-cerrado para revelar
- Placeholder: ••••
- Helper text: "⚡ Con este PIN podrás ingresar directamente desde la pantalla de perfiles"
```

### **4. Diferenciación: Cambiar de Rol vs Cerrar Sesión**

**Botón "Cambiar de Rol" (Sidebar):**

**Acción:**
```typescript
- Quita el perfil activo del usuario
- Mantiene los datos del usuario en memoria
- Redirección a "Selecciona tu perfil" (lock screen)
- Toast: "Selecciona un nuevo perfil"
```

**Uso:**
- Cambiar entre Dueño ↔ Gerente ↔ Trabajador
- Sin necesidad de login completo
- Validación de PIN al re-seleccionar perfil

**Botón "Cerrar Sesión" (Sidebar):**

**Acción:**
```typescript
- Borra el usuario activo de memoria
- Elimina "licostoke_user" de localStorage
- Si sistema configurado → Vuelve a lock screen
- Si NO configurado → Va a login tradicional
- Toast: "Selecciona tu perfil para ingresar" o "Sesión cerrada completamente"
```

**Uso:**
- Logout completo del usuario
- Permite que otra persona ingrese con su PIN
- Si el sistema tiene PINes configurados, vuelve al lock screen (no al login)

---

## 🔄 Flujo Completo del Sistema

### **Primera Instalación**

**Paso 1: Registro Inicial del Dueño**
```
Splash → Login/Registro → Dashboard (como owner)
```

**Paso 2: Configuración en "Control de Accesos"**
```
1. Ingresar PIN Maestro (4 dígitos) - Campo obligatorio ⚠️
2. Activar Switch de Gerente (opcional)
   - Nombre, Email, PIN de 4 dígitos
3. Activar Switch de Trabajador (opcional)
   - Nombre, Email, PIN de 4 dígitos
4. Click "Guardar y Habilitar Equipo"
5. ✓ Sistema configurado como lock screen
```

**Paso 3: Logout o Cierre de App**
```
Al reabrir → Pantalla "Selecciona tu perfil" (lock screen)
```

### **Uso Diario (Sistema Configurado)**

**Inicio de la App:**
```
App abre → Lock Screen (Selecciona tu perfil)
```

**Acceso como Dueño:**
```
1. Click en tarjeta "Dueño"
2. Modal de PIN aparece
3. Ingresar 4 dígitos
4. ✓ Dashboard (perfil owner)
```

**Acceso como Gerente:**
```
1. Click en tarjeta "Gerente"
2. Modal de PIN aparece
3. Ingresar 4 dígitos
4. ✓ Dashboard (perfil manager)
```

**Acceso como Trabajador:**
```
1. Click en tarjeta "Trabajador"
2. Acceso directo
3. ✓ Dashboard (perfil worker)
```

**Cambiar de Rol:**
```
1. Click "Cambiar de Rol" (sidebar)
2. → Lock Screen
3. Seleccionar nuevo perfil
4. Ingresar PIN si es necesario
5. ✓ Dashboard con nuevo perfil
```

**Cerrar Sesión:**
```
1. Click "Cerrar Sesión" (sidebar)
2. → Lock Screen (si sistema configurado)
   → Login (si sistema NO configurado)
3. Otra persona puede ingresar
```

---

## 🎨 Elementos Visuales

### **Modal de PIN (Acceso Rápido)**

**Header:**
```
Título: "Acceso Rápido"
Subtítulo: "Ingresa tu PIN de 4 dígitos para acceder como [Perfil]"
Icono: Lock (candado) con color del perfil
```

**Input de PIN:**
```css
- Altura: 64px (h-16)
- Texto: text-3xl, centrado, tracking-[1rem]
- Font: bold
- Placeholder: ••••
- Solo números, máximo 4 dígitos
- Enter key: Validar automáticamente
```

**Helper Text:**
```
"⚡ Acceso rápido sin contraseña"
Color: cobre (#C89B6D)
```

**Botones:**
```
- Cancelar: Outline, sin estilo especial
- Verificar: Color del perfil seleccionado
```

### **Card "PIN Maestro" en Control de Accesos**

**Estilo Premium:**
```css
- Background: Gradiente from-[#2c3545] to-[#1e293b]
- Border: 2px solid rgba(200, 155, 109, 0.5)
- Shadow: shadow-lg
- Icon: Crown en bg-[#C89B6D]/20
```

**Input:**
```css
- Altura: estándar (h-10/12)
- Texto: text-2xl, centrado, tracking-widest, bold
- Solo números, máximo 4 dígitos
- Botón revelar en posición absoluta
- Focus: border-[#C89B6D]
```

### **Botones en Sidebar**

**"Cambiar de Rol":**
```css
- Color texto: #C89B6D (cobre)
- Border: border-[#3a4556] hover:border-[#C89B6D]
- Icono: RefreshCw
- Posición: Antes de "Cerrar Sesión"
```

**"Cerrar Sesión":**
```css
- Color texto: Normal (blanco/gris)
- Border: border-[#3a4556] hover:border-red-500/50
- Icono: LogOut
- Posición: Última acción del sidebar
```

---

## 🔒 Validación y Seguridad

### **Validación de PIN**

```typescript
// Owner
if (pin === securityConfig.ownerPin) → Acceso concedido

// Manager
if (pin === securityConfig.managerRole.pin) → Acceso concedido

// Caso contrario
→ Toast: "PIN incorrecto"
→ Limpiar campo de PIN
```

### **Almacenamiento**

```javascript
// SecurityConfig structure
licostoke_{userId}_security_config = {
  ownerPin: "1234",              // ← NUEVO: PIN maestro del dueño
  managerRole: {
    enabled: true,
    pin: "5678",
    name: "Carlos Mendoza",
    email: "gerente@..."
  },
  workerRole: {
    enabled: true,
    pin: "9012",
    name: "María López",
    email: "trabajador@..."
  }
}
```

### **Persistencia de Sesión**

```typescript
// Usuario activo (con perfil)
licostoke_user = {
  name: "Juan",
  email: "juan@...",
  id: "user_123",
  profile: "owner"  // owner, manager, worker, undefined
}

// Cambiar de Rol: profile = undefined
// Cerrar Sesión: Remove licostoke_user
```

---

## 📱 Experiencia de Usuario

### **Ventajas del Sistema**

✅ **Acceso Ultra Rápido:**
- 4 dígitos vs email largo + password
- Ideal para dispositivos compartidos
- Perfecto para entorno POS/retail

✅ **Sin Fricción:**
- No recordar emails ni contraseñas
- Todos los días: abrir app → PIN → trabajar

✅ **Multi-Usuario Ágil:**
- Cambiar de rol en 2 clicks
- Cerrar sesión y permitir otro usuario
- Lock screen siempre disponible

✅ **Seguridad Mantenida:**
- PINes individuales por usuario
- Validación en cada acceso
- Solo admin puede configurar PINes

### **Casos de Uso**

**Caso 1: Tienda con Tablet Compartida**
```
Mañana: Dueño abre app → PIN 1234 → Revisa reportes
Tarde: Trabajador → PIN 5678 → Vende en POS
Noche: Gerente → PIN 9012 → Genera pedido
```

**Caso 2: Múltiples Empleados**
```
Empleado 1 termina turno → "Cambiar de Rol"
Empleado 2 ingresa → PIN → Continúa vendiendo
```

**Caso 3: Reset Completo**
```
Cierre de día → "Cerrar Sesión"
Al día siguiente → Lock screen listo para cualquier usuario
```

---

## 🚀 Mejoras Futuras (Opcional)

### **Seguridad Avanzada**

1. **Intentos Fallidos:**
   - Bloqueo temporal tras 3 intentos fallidos
   - Requiere login con email/password para desbloquear

2. **Timeout de Sesión:**
   - Auto-logout tras X minutos de inactividad
   - Vuelve al lock screen automáticamente

3. **Biometría Opcional:**
   - Huella digital / Face ID como alternativa al PIN
   - Configuración en "Control de Accesos"

### **UX Adicional**

1. **Historial de Accesos:**
   - Ver quién ingresó y cuándo
   - Tiempo de sesión por usuario

2. **Cambio de PIN por Usuario:**
   - Gerente/Trabajador pueden cambiar su propio PIN
   - Admin puede resetear PINes olvidados

3. **Temas por Perfil:**
   - Color personalizado para cada perfil
   - Identificación visual inmediata

---

## 📊 Comparación: Antes vs Ahora

### **Flujo Anterior**

```
Abrir app → Splash → Login (email + password)
→ Selección de perfiles → Modal PIN (solo Gerente)
→ Dashboard

Problemas:
❌ Muy largo para uso diario
❌ Owner usa password larga siempre
❌ Lock screen no funcional sin login previo
```

### **Flujo Actual (Lock Screen POS)**

```
Abrir app (configurado) → Lock Screen
→ Click perfil → PIN 4 dígitos
→ Dashboard

Beneficios:
✅ Acceso en ~5 segundos
✅ Todos usan PIN de 4 dígitos
✅ Lock screen desde el inicio
✅ Experiencia tipo POS profesional
```

---

## ⚡ Comandos Rápidos

**Configurar Sistema por Primera Vez:**
1. Registro/Login → Dashboard
2. Sidebar → "Control de Accesos"
3. PIN Maestro (4 dígitos) ✓
4. Activar equipo (opcional) ✓
5. Guardar → Sistema configurado

**Uso Diario:**
1. Abrir app → Lock Screen
2. Click perfil → PIN (4 dígitos)
3. ✓ Trabajar

**Cambiar de Usuario:**
- Opción A: "Cambiar de Rol" → Lock Screen
- Opción B: "Cerrar Sesión" → Lock Screen

---

**✅ Sistema Lock Screen POS Implementado**
**Desarrollado para LicoStoke v1.1.0**
Sistema de Gestión Inteligente para Licorerías
Acceso Rápido con PINes de 4 Dígitos
