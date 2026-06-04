# ⚠️ Node.js no está instalado

Para ejecutar este proyecto, necesitas instalar **Node.js v18+** primero.

## 🔧 Instalar Node.js

### Opción 1: Descargar desde nodejs.org (Recomendado)

1. Abre https://nodejs.org/
2. Descarga la versión **LTS** (versión estable)
3. Ejecuta el instalador y sigue los pasos
4. **Importante:** Marca la opción "Add to PATH" durante la instalación
5. Reinicia PowerShell/CMD después de instalar

### Opción 2: Usar Chocolatey (si lo tienes)

```powershell
choco install nodejs
```

### Opción 3: Usar Winget (Windows 11)

```powershell
winget install OpenJS.NodeJS
```

---

## ✅ Verificar Instalación

Después de instalar Node.js, abre una **nueva terminal** (PowerShell/CMD) y ejecuta:

```powershell
node --version
npm --version
```

Deberían mostrar versiones (ej: v20.x.x)

---

## 🚀 Una vez instalado Node.js

Desde la carpeta del proyecto, ejecuta:

```powershell
# 1. Instalar pnpm (gestor de paquetes optimizado)
npm install -g pnpm

# 2. Instalar todas las dependencias
pnpm install

# 3. Ejecutar la aplicación web
pnpm web:dev

# 4. En otra terminal, ejecutar mobile (opcional)
pnpm mobile:start
```

---

## 📋 Checklist

- [ ] Node.js v18+ instalado
- [ ] npm funcionando (`npm --version`)
- [ ] Terminal reiniciada después de instalar Node.js
- [ ] Ejecutó `pnpm install` desde la raíz del proyecto
- [ ] Web corriendo en http://localhost:5173

---

## ❓ ¿Problemas?

Si después de instalar Node.js aparece un error, intenta:

1. Reinicia PowerShell completamente
2. Navega a la carpeta del proyecto
3. Ejecuta `npm install -g pnpm` nuevamente
4. Luego `pnpm install`

---

Ver: [NEXT_STEPS.md](./NEXT_STEPS.md) para instrucciones detalladas.
