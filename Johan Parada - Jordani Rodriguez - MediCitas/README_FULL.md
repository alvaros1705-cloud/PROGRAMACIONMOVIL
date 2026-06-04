# 🏥 Medical Appointment Management App
## Web + Mobile (Monorepo)

Una aplicación completa para gestionar citas médicas disponible en **web** y **móvil** (iOS/Android).

---

## 🎯 Características

- ✅ **Autenticación** con Supabase (email/contraseña)
- ✅ **Gestión de citas** médicas
- ✅ **Registro de exámenes** y resultados
- ✅ **Control de medicamentos**
- ✅ **Perfil de usuario**
- ✅ **Cross-platform**: Web + iOS + Android
- ✅ **Código compartido** entre plataformas

---

## 📊 Estructura del Proyecto

```
medical-appointment-app/
├── web/              # Aplicación web (Vite + React)
├── mobile/           # Aplicación móvil (Expo + React Native)
├── shared/           # Código compartido entre plataformas
├── pnpm-workspace.yaml
└── package.json
```

### Detalles de cada carpeta:

**`web/`** - Aplicación Web
- Framework: Vite + React 18
- Styling: Tailwind CSS
- Componentes: shadcn/ui + Radix UI
- Target: Desktop y tablet

**`mobile/`** - Aplicación Móvil
- Framework: Expo + React Native
- Styling: StyleSheet (React Native)
- Componentes: React Native
- Target: iOS y Android

**`shared/`** - Código Compartido
- Hooks: `useAuth`
- Librerías: Cliente Supabase
- Tipos: Interfaces TypeScript
- Utils: Funciones auxiliares

---

## 🚀 Comenzar rápidamente

### Requisitos previos
- Node.js 18+
- pnpm (o npm/yarn)
- Expo CLI (para desarrollo móvil)

### Instalación

```bash
# 1. Clonar el repositorio
git clone <tu-repo>
cd medical-appointment-app

# 2. Instalar dependencias del monorepo
pnpm install

# 3. Configurar variables de entorno (copiar .env.example a .env.local)
cp .env.example .env.local
```

### Ejecutar en desarrollo

#### Web
```bash
pnpm web:dev
```
Abre [http://localhost:5173](http://localhost:5173)

#### Mobile
```bash
# Opciones:
pnpm mobile:start     # Abre Expo Dev Client
pnpm mobile:ios       # iOS Simulator
pnpm mobile:android   # Android Emulator
pnpm mobile:web       # Web versión
```

---

## 📱 Estructura de Carpetas Detallada

### Web (`web/src/`)

```
src/
├── app/
│   ├── App.tsx                 # Componente principal
│   └── components/
│       ├── LoginScreen.tsx
│       ├── RegisterScreen.tsx
│       ├── DashboardScreen.tsx
│       ├── AppointmentsScreen.tsx
│       ├── ExamsScreen.tsx
│       ├── MedicationsScreen.tsx
│       ├── ProfileScreen.tsx
│       ├── BottomNav.tsx
│       ├── NewAppointmentForm.tsx
│       └── ui/                 # Componentes shadcn
├── lib/
│   └── supabase.ts            # [DEPRECATED] usar @medical-app/shared
├── styles/
│   ├── globals.css
│   ├── theme.css
│   └── tailwind.css
└── main.tsx                   # Entry point
```

### Mobile (`mobile/app/`)

```
app/
├── index.tsx                   # App entry point
├── RootNavigator.tsx           # Navegación principal
└── screens/
    ├── LoginScreen.tsx
    ├── RegisterScreen.tsx
    ├── DashboardScreen.tsx
    ├── AppointmentsScreen.tsx
    └── ProfileScreen.tsx
```

### Shared (`shared/src/`)

```
src/
├── lib/
│   └── supabase.ts            # Cliente Supabase compartido
├── hooks/
│   └── useAuth.ts             # Hook de autenticación
├── types/
│   └── index.ts               # Tipos TypeScript compartidos
└── utils/
    └── index.ts               # Funciones auxiliares
```

---

## 🔄 Flujo de Datos

```
┌─────────────────────────────────────────┐
│   Componentes Web/Mobile                │
│   (App.tsx, Screens)                    │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│   Hooks Compartidos                     │
│   (useAuth, useAppointments)            │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│   Shared Library (@medical-app/shared)  │
│   - Supabase Client                     │
│   - Types & Utils                       │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│   Supabase Backend                      │
│   - Authentication                      │
│   - Database                            │
│   - Real-time Sync                      │
└─────────────────────────────────────────┘
```

---

## 🔐 Autenticación

La autenticación se maneja con Supabase y el hook `useAuth`:

```typescript
import { useAuth } from '@medical-app/shared/hooks/useAuth';

function MyComponent() {
  const { session, loading, signIn, signUp, signOut } = useAuth();
  
  // Usar según sea necesario
}
```

---

## 📦 Gestión de Dependencias

### Instalar paquete en web
```bash
pnpm -F web add nombre-paquete
```

### Instalar paquete en mobile
```bash
pnpm -F mobile add nombre-paquete
```

### Instalar paquete compartido
```bash
pnpm -F shared add nombre-paquete
```

### Instalar en todos
```bash
pnpm add -r nombre-paquete
```

---

## 🛠️ Comandos Disponibles

### Desarrollo
```bash
pnpm web:dev          # Web en desarrollo
pnpm mobile:start     # Mobile con Expo
pnpm web:build        # Build web
pnpm mobile:prebuild  # Prebuild para iOS/Android
```

### Construcción
```bash
pnpm web:build        # Build optimizado web
pnpm mobile:prebuild  # Generar código nativo
pnpm mobile:build     # Build con EAS
```

### Herramientas
```bash
pnpm install          # Instalar todas las dependencias
pnpm -r build         # Build en todos los workspaces
pnpm ls               # Ver estructura de dependencias
```

---

## 🌍 Variables de Entorno

Crear `.env.local` basado en `.env.example`:

```env
# Supabase
VITE_SUPABASE_PROJECT_ID=tu_project_id
VITE_SUPABASE_ANON_KEY=tu_anon_key

# API (opcional)
VITE_API_URL=https://api.tu-dominio.com
```

---

## 📝 Convenciones de Código

### Imports
```typescript
// ✅ CORRECTO - Desde shared
import { useAuth } from '@medical-app/shared/hooks/useAuth';
import { formatDate } from '@medical-app/shared/utils';
import type { User } from '@medical-app/shared/types';

// ❌ EVITAR - Imports relativos largos
import { useAuth } from '../../../shared/src/hooks/useAuth';
```

### Componentes
```typescript
// Web - usa shadcn + Tailwind
<Button className="w-full">Click</Button>

// Mobile - usa React Native
<TouchableOpacity style={styles.button}>
  <Text>Click</Text>
</TouchableOpacity>
```

### Hooks
```typescript
// Usa hooks de shared para lógica compartida
const { session, loading } = useAuth();
```

---

## 🐛 Troubleshooting

### Error: "Cannot find module '@medical-app/shared'"
```bash
# Solución
pnpm install
pnpm -F web install
pnpm -F mobile install
```

### Mobile: "Metro error"
```bash
# Solución
cd mobile
pnpm start --reset-cache
```

### Web: "Vite error"
```bash
# Solución
rm -rf web/.vite
pnpm web:dev
```

---

## 📚 Documentación Adicional

- [MONOREPO_SETUP.md](./MONOREPO_SETUP.md) - Detalles de configuración del monorepo
- [NEXT_STEPS.md](./NEXT_STEPS.md) - Pasos para completar la migración
- [Documentación Supabase](https://supabase.com/docs)
- [Documentación Expo](https://docs.expo.dev)
- [Documentación React Native](https://reactnative.dev)

---

## 🤝 Contribuir

Las contribuciones son bienvenidas. Para cambios importantes:

1. Fork el repositorio
2. Crea una rama (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

---

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Ver [LICENSE](./LICENSE) para más detalles.

---

## 📧 Contacto

Para preguntas o soporte, abre un [Issue](https://github.com/tu-usuario/medical-appointment-app/issues).

---

**Última actualización:** Marzo 2024  
**Versión:** 0.0.1
