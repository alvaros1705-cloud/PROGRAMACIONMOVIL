# 🚀 Guía Rápida de Migración

## Resumen: Qué necesitas hacer

Tu proyecto ya está estructurado como un **monorepo web + mobile**. Solo necesitas:

### ✅ Paso 1: Copiar el código actual a `web/`

```bash
# Copiar desde src/ a web/src/
xcopy src web\src /E /I

# Copiar archivos de configuración
copy index.html web\
copy vite.config.ts web\
copy postcss.config.mjs web\
```

### ✅ Paso 2: Actualizar importaciones en web

En **`web/src/app/App.tsx`** y otros archivos:

**Cambiar:**
```typescript
import { supabase } from '../lib/supabase';
```

**Por:**
```typescript
import { supabase } from '@medical-app/shared/lib/supabase';
```

### ✅ Paso 3: Instalar dependencias

```bash
# Desde la raíz del proyecto
pnpm install
```

### ✅ Paso 4: Ejecutar

**Web:**
```bash
pnpm web:dev
```

**Mobile:**
```bash
pnpm mobile:start
```

---

## 📂 Lo que ya está listo

| Carpeta | Estado | Qué hace |
|---------|--------|----------|
| `shared/` | ✅ Listo | Código compartido (auth, tipos, utils) |
| `mobile/` | ✅ Listo | App Expo con screens de ejemplo |
| `web/` | ⏳ Necesita migración | Tu código actual irá aquí |
| `package.json` | ✅ Actualizado | Configuración monorepo |
| `pnpm-workspace.yaml` | ✅ Actualizado | Define los workspaces |

---

## 🎯 Archivos creados para compartir código

### shared/src/lib/supabase.ts
Cliente Supabase que usan ambas plataformas

### shared/src/hooks/useAuth.ts
Hook de autenticación para React

### shared/src/types/index.ts
Tipos TypeScript compartidos (User, Appointment, etc)

### shared/src/utils/index.ts
Funciones auxiliares (formatDate, validateEmail, etc)

---

## 📱 Mobile ya tiene

- ✅ Navegación con React Navigation
- ✅ Screens de Login, Register, Dashboard
- ✅ Integración con Supabase
- ✅ Ejemplos de formularios

Solo personaliza según tus necesidades.

---

## 🔗 Referencias rápidas

```bash
# Ver estructura de workspaces
pnpm ls

# Instalar en web específicamente
pnpm -F web add package-name

# Instalar en mobile específicamente
pnpm -F mobile add package-name

# Instalar en shared (para ambos)
pnpm -F shared add package-name
```

---

## ⏱️ Tiempo estimado

- **Copiar archivos**: 5 minutos
- **Actualizar imports**: 10-15 minutos
- **Instalar dependencias**: 5-10 minutos
- **Verificar funcionamiento**: 5 minutos

**Total: ~30 minutos**

---

¿Necesitas ayuda en algún paso? Revisa [NEXT_STEPS.md](./NEXT_STEPS.md) para detalles completos.
