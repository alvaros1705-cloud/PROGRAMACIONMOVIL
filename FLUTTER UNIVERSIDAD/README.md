# 🧘 MindfulPhone — Flutter/Dart App

> **App para el Uso Responsable del Celular**  
> Prototipo UI profesional con animaciones, modo oscuro/claro y diseño responsivo.

---

## 📂 Estructura del Proyecto

```
mindfulphone/
├── lib/
│   ├── main.dart                    # Entry point + MaterialApp
│   ├── theme/
│   │   ├── app_theme.dart           # Colores, tipografía, temas claro/oscuro
│   │   └── theme_provider.dart      # ChangeNotifier para toggle de tema
│   ├── widgets/
│   │   └── common_widgets.dart      # GradientText, GlassCard, GradientButton,
│   │                                #   AnimatedOrb, OrbsBackground, PulsingLogo
│   └── screens/
│       ├── splash_screen.dart       # Onboarding (3 slides animados)
│       ├── login_screen.dart        # Login con Google
│       ├── register_screen.dart     # Registro con selector de perfil
│       └── dashboard_screen.dart    # Dashboard completo
├── assets/
│   └── images/                      # (Agrega tus assets aquí)
└── pubspec.yaml
```

---

## 🚀 Cómo ejecutar

### Requisitos
- Flutter SDK `>=3.0.0`
- Dart `>=3.0.0`
- Android Studio / VS Code con extensión Flutter

### Pasos

```bash
# 1. Entra al directorio
cd mindfulphone

# 2. Instala dependencias
flutter pub get

# 3. Ejecuta en dispositivo/emulador
flutter run

# 4. Para release APK
flutter build apk --release
```

---

## 🎨 Diseño y Features

### Pantallas implementadas

| Pantalla | Features |
|---|---|
| **Splash / Onboarding** | 3 slides animados, logos pulsantes, orbs flotantes, dots de navegación |
| **Login** | Email/contraseña, toggle de visibilidad, Google Sign-In, olvidé contraseña, toggle tema |
| **Registro** | Selector de perfil (Estudiante/Profesional/Familia/Bienestar), validación visual, terms checkbox |
| **Dashboard** | Ring chart animado, gráfica semanal, apps más usadas (scroll horizontal), límites con barras de progreso, tips de bienestar, racha semanal, bottom nav |

### Sistema de diseño

```dart
// Colores principales
accent:  #6C63FF  (Violeta)
accent3: #4ECDC4  (Turquesa)
accent5: #FF6B9D  (Rosa)
accent4: #FFD166  (Amarillo)
green:   #43E97B
red:     #FF6B6B
orange:  #FF9A3C

// Fuentes
Sora          → Títulos (Google Fonts)
Plus Jakarta Sans → Cuerpo (Google Fonts)

// Gradientes
gradient1: #6C63FF → #4ECDC4
gradient2: #FF6B9D → #FFD166
gradient3: #43E97B → #38F9D7
gradient4: #6C63FF → #FF6B9D
```

### Animaciones incluidas

- **Splash**: Scale + Opacity con elasticOut, SlideTransition entre onboarding cards
- **Login / Register**: Staggered entry animations (8 elementos con delay progresivo)
- **Dashboard**: Ring chart con easeOutCubic (1.8s), staggered card entry
- **Orbs**: Float animation con reverse (8s loop)
- **Logo**: Glow pulse (3s loop)
- **Botones**: Scale press feedback (120ms)
- **Theme toggle**: AnimatedContainer (300ms)

---

## 🌙 Modo Oscuro / Claro

El toggle de tema está disponible en:
- **Login** → ícono sol/luna arriba a la derecha
- **Registro** → mismo ícono
- **Dashboard** → mismo ícono

Se usa `ThemeProvider` (Provider) con `ThemeMode` de Flutter.

---

## 📱 Responsividad

Toda la UI usa `MediaQuery.of(context).size` para adaptar:
- Tamaños de fuente: `size.width * 0.07` (escala con pantalla)
- Padding: `size.width * 0.05` a `0.06`
- Ring chart: `size.width * 0.32`
- Logo en splash: `size.width * 0.18`

Compatible con:
- ✅ Teléfonos pequeños (320px+)
- ✅ Teléfonos estándar (375–430px)
- ✅ Teléfonos grandes / tablets (600px+)

---

## 📦 Dependencias

```yaml
animate_do: ^3.3.4          # Animaciones declarativas
flutter_animate: ^4.5.0     # Sistema de animaciones fluidas
fl_chart: ^0.68.0            # Gráficas (para expandir)
google_fonts: ^6.2.1         # Sora + Plus Jakarta Sans
provider: ^6.1.2             # State management para tema
percent_indicator: ^4.2.3    # Indicadores de progreso
```

---

## 🔧 Próximos pasos para producir

1. Conectar **Firebase Auth** para Google Sign-In real
2. Integrar **UsageStatsManager** (Android) / **Screen Time API** (iOS)
3. Agregar **flutter_local_notifications** para alertas
4. Implementar **Hive / Isar** para persistencia local
5. Diseñar pantallas de **Estadísticas**, **Focus Mode**, **Alertas** y **Perfil**

---

## 👨‍💻 Tecnologías

- **Flutter 3.x** — Framework UI
- **Dart 3.x** — Lenguaje
- **Provider** — State management
- **Google Fonts** — Tipografía premium
- **CustomPainter** — Ring chart animado

---

*Desarrollado como prototipo profesional de alta fidelidad para MindfulPhone — App para el Uso Responsable del Celular.*
