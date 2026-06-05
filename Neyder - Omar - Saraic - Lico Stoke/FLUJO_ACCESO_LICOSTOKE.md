# 🔐 Flujo de Acceso y Seguridad - LicoStoke

## Arquitectura del Sistema de Roles

LicoStoke implementa un sistema de control de acceso jerárquico donde el **Dueño (Administrador)** tiene control total sobre quién puede acceder al sistema y con qué permisos.

---

## 📋 Flujo Completo del Sistema

### **Paso 1: Estado Inicial de Fábrica**

Cuando un usuario se registra por primera vez en LicoStoke:

1. **Pantalla de Selección de Perfiles** (Estado Inicial):
   - ✅ **Perfil Dueño**: ACTIVO - Único perfil disponible para el primer acceso
   - 🔒 **Perfil Gerente**: BLOQUEADO (opacidad 40%)
   - 🔒 **Perfil Trabajador**: BLOQUEADO (opacidad 40%)

2. **Indicadores Visuales de Bloqueo**:
   - Icono de candado cerrado (LockKeyhole)
   - Overlay con blur sobre la tarjeta
   - Texto: "Perfil Bloqueado"
   - Subtexto: "Habilitar desde el panel de Administrador"

---

### **Paso 2: Configuración por el Dueño**

El Dueño debe acceder al módulo **"Gestión de Seguridad y Roles"** (visible solo para perfil owner):

#### **2.1 PIN Maestro del Administrador**
- Campo obligatorio (4-6 dígitos numéricos)
- Formato oculto con botón "ojo" para revelar
- Este PIN se usará para validar el acceso futuro del Dueño

#### **2.2 Configuración de Perfiles Secundarios**

Para cada rol (Gerente y Trabajador):

**Tarjeta con Switch de Activación:**
- Switch OFF (inicial) → Perfil deshabilitado, formulario oculto
- Switch ON → Formulario se expande con animación

**Campos del Formulario (cuando está activado):**
- ✏️ Nombre del usuario (ej: "Carlos Mendoza")
- 📧 Email (ej: "gerente@licostoke.com")
- 🔢 PIN de Acceso (4-6 dígitos, campo oculto con botón revelar)

---

### **Paso 3: Guardar y Activar**

**Botón "Guardar y Activar Perfiles":**

**Estados del Botón:**
- ❌ **Deshabilitado** (gris): Cuando faltan campos requeridos
  - Validaciones:
    - PIN del Administrador obligatorio (mínimo 4 dígitos)
    - Si Gerente está activado: nombre, email y PIN requeridos
    - Si Trabajador está activado: nombre, email y PIN requeridos

- ✅ **Activo** (gradiente cobre): Cuando todos los campos están completos
  - Gradiente: `from-[#C89B6D] to-[#B8895D]`
  - Hover: `from-[#B8895D] to-[#A87A4D]`
  - Shadow premium: `shadow-xl hover:shadow-2xl`

**Texto del Botón:**
- Con cambios: "Guardar y Activar Perfiles"
- Sin cambios: "✓ Configuración Guardada"

**Mensaje Helper:**
Cuando hay cambios válidos pendientes:
```
"Los perfiles se desbloquearán en la pantalla de selección"
```

---

### **Paso 4: Desbloqueo Permanente**

Una vez que el Dueño guarda la configuración:

**Comportamiento Automático del Sistema:**

1. **Los datos se almacenan en localStorage:**
   ```
   licostoke_{userId}_security_config
   ```

2. **La Pantalla de Selección de Perfiles se actualiza:**
   - Los perfiles con `enabled: true` se muestran **completamente activos**
   - Opacidad 100%, sin overlay de bloqueo
   - Tarjetas interactivas con animaciones hover
   - Acceso mediante validación de PIN

3. **Persistencia:**
   - Los perfiles activados quedan **permanentemente desbloqueados**
   - Solo se bloquean de nuevo si el Dueño desactiva el switch
   - La configuración persiste entre sesiones

---

## 🎯 Flujo de Validación de Acceso

### **Acceso como Dueño:**
1. Usuario selecciona tarjeta "Dueño"
2. Modal de verificación solicita PIN
3. Sistema valida contra `security_config.adminPin`
4. Si es correcto → Acceso concedido

### **Acceso como Gerente:**
1. Usuario selecciona tarjeta "Gerente"
2. Sistema verifica si está habilitado (`security_config.managerRole.enabled`)
3. Si está bloqueado → Toast: "Este perfil no está habilitado"
4. Si está activo → Modal solicita PIN
5. Sistema valida contra `security_config.managerRole.pin`
6. Si es correcto → Acceso concedido

### **Acceso como Trabajador:**
1. Usuario selecciona tarjeta "Trabajador"
2. Sistema verifica si está habilitado (`security_config.workerRole.enabled`)
3. Si está bloqueado → Toast: "Este perfil no está habilitado"
4. Si está activo → Acceso directo (sin PIN requerido en esta versión)
5. Acceso concedido

---

## 🎨 Elementos Visuales Premium

### **Paleta de Colores**

**Oscuros:**
- Background principal: `#1f2937`
- Cards: `#2c3545`
- Borders: `#3a4556`
- Text primary: `#f1f5f9`
- Text secondary: `#94a3b8`
- Text muted: `#64748b`

**Acentos:**
- Cobre premium: `#C89B6D`
- Hover cobre: `#B8895D`
- Pressed cobre: `#A87A4D`

**Estados:**
- Success: `#4ade80` (green)
- Warning: `#f59e0b` (orange)
- Error: `#ef4444` (red)
- Info: `#60a5fa` (blue)

### **Componentes Clave**

**Switch (Shadcn UI):**
- Estado OFF: Gris neutro
- Estado ON: Acento cobre
- Animación suave de transición

**Input PIN:**
- Tipo: `password` con toggle eye/eye-off
- Formato: Solo numéricos (regex: `/\D/g`)
- Max length: 6 dígitos
- Tracking: `tracking-widest` para estética de PIN
- Text align: `text-center`

**Badges de Estado:**
- Activo: `border-green-500/30 text-green-500 bg-green-500/10`
- Bloqueado: `border-gray-500/30 text-gray-500 bg-gray-500/10`

---

## 🔒 Reglas de Seguridad

1. ✅ Solo el Dueño puede crear y gestionar usuarios
2. ✅ Los usuarios no pueden auto-registrarse
3. ✅ Los PINes se almacenan en localStorage (en producción usar backend seguro)
4. ✅ Cada usuario tiene separación de datos por `userId`
5. ✅ Los perfiles desactivados no son accesibles desde la pantalla de selección
6. ✅ Validación de PIN obligatoria para Dueño y Gerente

---

## 📱 Responsive Design

**Mobile (< 768px):**
- Stack vertical de tarjetas de perfil
- Modal ocupa 90% del ancho
- Inputs y botones con touch-friendly sizing (min height 44px)

**Desktop (≥ 768px):**
- Grid de 3 columnas para perfiles
- Modal ancho máximo 500px centrado
- Hover effects completos

---

## ✨ Animaciones

**Motion/React Animations:**

1. **Entrada de perfiles:**
   - Delay escalonado (0.5s + index * 0.1s)
   - Fade + slide up

2. **Hover de tarjetas activas:**
   - Scale: 1.05
   - Translate Y: -8px
   - Shadow elevation

3. **Modal de PIN:**
   - Backdrop fade (opacity 0 → 1)
   - Content spring (scale 0.9 → 1)
   - Exit animations inversas

4. **Expansión de formularios:**
   - Height: 0 → auto
   - Opacity: 0 → 1
   - Duration: 300ms

---

## 🎓 Mensajes Educativos

El sistema incluye mensajes contextuales para guiar al usuario:

**En Gestión de Seguridad:**
```
💡 Comportamiento del Sistema

✓ Activación Permanente: Una vez guardados los PINes y activados los perfiles,
  estos quedarán desbloqueados permanentemente en la pantalla de selección.

🔒 Control Total: Solo tú como Administrador puedes activar/desactivar perfiles
   y gestionar los PINes de acceso. Los usuarios no pueden auto-registrarse.

⚠️ Perfiles Desactivados: Si desactivas un perfil, volverá a aparecer bloqueado
   en la pantalla de selección hasta que lo reactives.
```

**En Pantalla de Selección (perfil bloqueado):**
```
Perfil Bloqueado
Habilitar desde el panel
de Administrador
```

---

## 🚀 Próximos Pasos (Producción)

Para llevar este sistema a producción real:

1. **Backend de Autenticación:**
   - Migrar PINes a base de datos encriptada
   - Implementar JWT tokens
   - Hash de PINes con bcrypt

2. **Validación de Permisos:**
   - Middleware de autorización en rutas
   - Verificación de permisos por módulo
   - Auditoría de accesos

3. **Seguridad Adicional:**
   - Rate limiting para intentos de PIN
   - Bloqueo temporal tras N intentos fallidos
   - Sesiones con timeout automático
   - 2FA opcional para perfil Dueño

---

**Desarrollado para LicoStoke v1.0.0**
Sistema de Gestión Inteligente para Licorerías
