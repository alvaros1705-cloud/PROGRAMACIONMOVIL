# 📱 Guía: Convertir LicoStoke a APK Android

## Opción 1: Capacitor (Recomendado) ⚡

### Paso 1: Instalar Capacitor
```bash
npm install @capacitor/core @capacitor/cli
npm install @capacitor/android
```

### Paso 2: Inicializar Capacitor
```bash
npx cap init
```
Se te pedirá:
- **App name**: LicoStoke
- **App ID**: com.licostoke.app
- **Web dir**: dist

### Paso 3: Configurar Vite para build
Edita `vite.config.ts`:
```typescript
export default defineConfig({
  base: './',  // ← Importante para Capacitor
  build: {
    outDir: 'dist'
  }
})
```

### Paso 4: Build de la app web
```bash
npm run build
```

### Paso 5: Agregar plataforma Android
```bash
npx cap add android
```

### Paso 6: Sincronizar archivos
```bash
npx cap sync
```

### Paso 7: Abrir en Android Studio
```bash
npx cap open android
```

### Paso 8: Generar APK
En Android Studio:
1. **Build** → **Build Bundle(s) / APK(s)** → **Build APK(s)**
2. Espera a que compile
3. Haz clic en "locate" cuando termine
4. El APK estará en: `android/app/build/outputs/apk/debug/app-debug.apk`

---

## Opción 2: PWA + Capacitor (Más rápido) 🚀

### Paso 1: Crear `public/manifest.json`
```json
{
  "name": "LicoStoke",
  "short_name": "LicoStoke",
  "description": "Sistema de Gestión Inteligente",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#0F172A",
  "theme_color": "#C89B6D",
  "icons": [
    {
      "src": "/logo-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "/logo-512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
```

### Paso 2: Agregar al `index.html`
```html
<link rel="manifest" href="/manifest.json">
<meta name="theme-color" content="#C89B6D">
```

### Paso 3: Seguir pasos de Capacitor (Opción 1)

---

## Requisitos del Sistema 💻

- **Node.js** 16+
- **npm** o **pnpm**
- **Android Studio** (última versión)
- **Java JDK** 11 o superior
- **Android SDK** (se instala con Android Studio)

---

## Configuración de Android Studio ⚙️

### 1. Instalar Android Studio
Descarga desde: https://developer.android.com/studio

### 2. Instalar SDK
- Abrir **SDK Manager**
- Instalar **Android API 33** (o la más reciente)
- Instalar **Android SDK Build-Tools**

### 3. Configurar Variables de Entorno
```bash
# En ~/.bashrc o ~/.zshrc
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/platform-tools
```

---

## Personalización del APK 🎨

### Cambiar icono de la app
1. Generar iconos en: https://icon.kitchen
2. Descargar recursos Android
3. Reemplazar en: `android/app/src/main/res/`

### Cambiar nombre de la app
Editar `android/app/src/main/res/values/strings.xml`:
```xml
<string name="app_name">LicoStoke</string>
```

### Cambiar splash screen
Editar `android/app/src/main/res/drawable/splash.xml`

---

## Firmar APK para Producción 🔐

### 1. Generar keystore
```bash
keytool -genkey -v -keystore licostoke.keystore -alias licostoke -keyalg RSA -keysize 2048 -validity 10000
```

### 2. Configurar en `android/app/build.gradle`
```gradle
android {
    signingConfigs {
        release {
            storeFile file("licostoke.keystore")
            storePassword "TU_PASSWORD"
            keyAlias "licostoke"
            keyPassword "TU_PASSWORD"
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### 3. Build release
```bash
cd android
./gradlew assembleRelease
```

APK firmado en: `android/app/build/outputs/apk/release/app-release.apk`

---

## Troubleshooting 🔧

### Error: "Android SDK not found"
```bash
export ANDROID_HOME=$HOME/Android/Sdk
```

### Error: "Java version"
Instalar JDK 11:
```bash
# Ubuntu/Debian
sudo apt install openjdk-11-jdk

# macOS
brew install openjdk@11
```

### Error: Build failed
```bash
# Limpiar y rebuild
cd android
./gradlew clean
./gradlew assembleDebug
```

### Error: "Permission denied"
```bash
chmod +x android/gradlew
```

---

## Testing en Dispositivo Real 📱

### 1. Habilitar USB Debugging
En tu Android:
1. **Ajustes** → **Acerca del teléfono**
2. Tocar **Número de compilación** 7 veces
3. Volver → **Opciones de desarrollador**
4. Activar **Depuración USB**

### 2. Conectar y verificar
```bash
adb devices
```

### 3. Instalar APK
```bash
adb install android/app/build/outputs/apk/debug/app-debug.apk
```

---

## Actualizar la App 🔄

Cada vez que cambies código:
```bash
npm run build
npx cap sync
npx cap open android
# Rebuild en Android Studio
```

---

## Publicar en Google Play Store 🚀

1. Crear cuenta de desarrollador: https://play.google.com/console
2. Generar APK firmado (release)
3. Crear app en Play Console
4. Subir APK
5. Completar información de la app
6. Enviar para revisión

---

## Links Útiles 🔗

- Capacitor Docs: https://capacitorjs.com/docs
- Android Studio: https://developer.android.com/studio
- Icon Generator: https://icon.kitchen
- Play Console: https://play.google.com/console

---

## Comandos Rápidos ⚡

```bash
# Build completo
npm run build && npx cap sync && npx cap open android

# Solo sincronizar cambios
npx cap sync

# Ver logs del dispositivo
adb logcat

# Desinstalar app
adb uninstall com.licostoke.app

# Instalar APK
adb install ruta/al/app.apk
```
