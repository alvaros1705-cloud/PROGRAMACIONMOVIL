# 🚀 Guía de Configuración - Monorepo Web + Mobile

## 📋 Pasos para completar la migración

### 1. **Copia los archivos de la carpeta `src` a `web/src`**

Tu código actual web está en `src/`, necesitas copiarlo a `web/src/`:

```bash
# En Windows (desde el directorio raíz)
copy src web\src  # Copia la carpeta src a web\src
copy index.html web\
copy vite.config.ts web\
copy postcss.config.mjs web\
copy tailwind.config.ts web\ (si existe)
```

O manualmente en VS Code:
1. Selecciona toda la carpeta `src/` → Copia
2. Abre la carpeta `web/` → Pega la carpeta dentro
3. Repite para `index.html`, `vite.config.ts`, etc.

### 2. **Actualiza las importaciones en `web/src/app/App.tsx`**

Cambia:
```typescript
// ANTES
import { supabase } from '../lib/supabase';

// DESPUÉS
import { supabase } from '@medical-app/shared/lib/supabase';
import { useAuth } from '@medical-app/shared/hooks/useAuth';
```

### 3. **Instala las dependencias del monorepo**

```bash
# Desde la raíz del proyecto
pnpm install
```

Este comando instalará las dependencias de:
- `web/` (aplicación web)
- `mobile/` (aplicación móvil)
- `shared/` (código compartido)

### 4. **Ejecuta la aplicación web**

```bash
# Desde la raíz, en una terminal
pnpm web:dev
```

La aplicación web estará disponible en `http://localhost:5173`

### 5. **Configura la aplicación móvil (Expo)**

```bash
# Instala Expo CLI globalmente (una sola vez)
npm install -g expo-cli

# Desde la carpeta mobile/
cd mobile

# Inicia el servidor de desarrollo
pnpm start

# Para iOS
pnpm ios

# Para Android
pnpm android

# Para web (versión web con React Native Web)
pnpm web
```

## 📁 Estructura final esperada

```
medical-appointment-app/
├── web/                          # ← Copia tu código aquí
│   ├── src/                       # (Copia de src/ actual)
│   │   ├── app/
│   │   ├── components/
│   │   ├── lib/
│   │   └── styles/
│   ├── index.html                # (Copia el actual)
│   ├── vite.config.ts            # (Copia el actual)
│   └── package.json              # ✅ Ya existe
│
├── mobile/                        # ✅ Ya creado con Expo
│   ├── app/
│   │   ├── index.tsx             # ✅ Punto de entrada
│   │   ├── RootNavigator.tsx      # ✅ Navegación
│   │   └── screens/              # ✅ Screens de ejemplo
│   ├── app.json                  # ✅ Configuración Expo
│   └── package.json              # ✅ Ya existe
│
├── shared/                        # ✅ Código compartido
│   ├── src/
│   │   ├── lib/
│   │   │   └── supabase.ts        # ✅ Cliente Supabase
│   │   ├── types/
│   │   │   └── index.ts           # ✅ Tipos TypeScript
│   │   ├── hooks/
│   │   │   └── useAuth.ts         # ✅ Hook de autenticación
│   │   └── utils/
│   │       └── index.ts           # ✅ Funciones de utilidad
│   └── package.json              # ✅ Ya existe
│
├── package.json                   # ✅ Root (modificado)
├── pnpm-workspace.yaml            # ✅ Configuración workspaces
├── MONOREPO_SETUP.md              # ✅ Documentación
└── NEXT_STEPS.md                  # ← Este archivo
```

## 🎯 Siguientes pasos

### Para la web:
1. Copia `src/app/App.tsx` a `web/src/app/App.tsx`
2. Actualiza las importaciones para usar `@medical-app/shared`
3. Copia los componentes UI de `src/app/components/ui/` a `web/src/app/components/ui/`
4. Ejecuta `pnpm web:dev`

### Para mobile:
1. Los screens ya están creados como ejemplo
2. Personaliza `mobile/app/screens/` según tus necesidades
3. Usa el mismo código de lógica que en web (desde `@medical-app/shared`)
4. Ejecuta `pnpm mobile:start`

## 🔧 Comandos útiles

```bash
# Instalar dependencia en web
pnpm -F web add nombre-paquete

# Instalar dependencia en mobile
pnpm -F mobile add nombre-paquete

# Instalar dependencia en shared
pnpm -F shared add nombre-paquete

# Ejecutar dev web
pnpm web:dev

# Ejecutar dev mobile
pnpm mobile:start

# Build web
pnpm web:build

# Ver estructura de workspaces
pnpm ls

# Ejecutar comando en todos los workspaces
pnpm -r build
```

## 📱 Diferencias web vs mobile

### Web (`web/`)
- ✅ Usa componentes shadcn + Tailwind CSS
- ✅ Responsive design con CSS
- ✅ Acceso a DOM APIs

### Mobile (`mobile/`)
- ✅ Usa componentes React Native + Expo
- ✅ Acceso a APIs nativas (cámara, ubicación, etc.)
- ✅ Performance optimizado para móviles

### Compartido (`shared/`)
- ✅ Lógica de autenticación (useAuth)
- ✅ Cliente Supabase
- ✅ Tipos TypeScript
- ✅ Funciones utilitarias

## ⚠️ Notas importantes

1. **No duplicar código**: Si usas código en ambas plataformas, ponlo en `shared/`
2. **Variables de entorno**: Copia `.env.example` a `.env.local` y rellena los valores
3. **Dependencias**: Algunas dependencias (como `react-router` para web) solo irán en `web/`
4. **Componentes**: Los componentes UI específicos de cada plataforma van en su respectiva carpeta

## 🆘 Solución de problemas

### Error: "No podría encontrar el módulo '@medical-app/shared'"
→ Ejecuta `pnpm install` desde la raíz

### Error en mobile: "Cannot find module 'expo'"
→ Ejecuta `pnpm -F mobile install`

### Los cambios en shared no se reflejan en web/mobile
→ Reinicia el servidor de desarrollo (Ctrl+C y vuelve a ejecutar)

## 📚 Más información

Ver [MONOREPO_SETUP.md](./MONOREPO_SETUP.md) para más detalles sobre la estructura.
