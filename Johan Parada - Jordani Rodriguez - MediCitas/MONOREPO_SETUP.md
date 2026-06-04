# Estructura del Proyecto - Web + Mobile Monorepo

## 📁 Estructura

```
medical-app/
├── web/                    # App web (Vite + React)
│   ├── src/
│   ├── package.json
│   └── vite.config.ts
├── mobile/                 # App móvil (Expo + React Native)
│   ├── app/
│   ├── package.json
│   └── app.json
├── shared/                 # Código compartido (lógica, tipos, servicios)
│   ├── src/
│   │   ├── lib/
│   │   │   └── supabase.ts    # Cliente Supabase compartido
│   │   ├── types/             # Tipos TypeScript
│   │   ├── hooks/             # Hooks reutilizables
│   │   └── utils/             # Funciones de utilidad
│   └── package.json
├── package.json            # Root package.json (configuración del monorepo)
└── pnpm-workspace.yaml     # Configuración de workspaces
```

## 🚀 Comandos disponibles

```bash
# Instalar dependencias del monorepo completo
pnpm install

# Ejecutar en desarrollo (web)
pnpm -F web dev

# Ejecutar en desarrollo (mobile)
pnpm -F mobile start

# Construir todo
pnpm -F web build
pnpm -F mobile prebuild

# Instalar dependencias en un workspace específico
pnpm -F shared install <package>
pnpm -F web install <package>
pnpm -F mobile install <package>
```

## 📦 Estructura de código compartido (shared/)

Este paquete contiene:
- **lib/supabase.ts** - Cliente Supabase compartido para autenticación y BD
- **types/** - Interfaces y tipos TypeScript compartidos
- **hooks/** - Custom React hooks (useAuth, etc)
- **utils/** - Funciones de utilidad compartidas

## 🔗 Cómo importar código compartido

Desde `web/`:
```typescript
import { supabase } from '@medical-app/shared/lib/supabase'
import type { User } from '@medical-app/shared/types'
```

Desde `mobile/`:
```typescript
import { supabase } from '@medical-app/shared/lib/supabase'
import type { User } from '@medical-app/shared/types'
```

## 🛠 Configuración de TypeScript

Cada workspace tiene su propio `tsconfig.json` que extiende la configuración base del monorepo.

## 📱 Diferencias entre web y mobile

- **Web**: Usa componentes shadcn + Tailwind CSS
- **Mobile**: Usa componentes React Native + Expo UI
- **Compartido**: Lógica, tipos, servicios (Supabase)
