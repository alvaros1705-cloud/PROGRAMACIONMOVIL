/// INSTRUCCIONES PARA CONFIGURAR FIREBASE
/// ========================================
///
/// Este archivo es un PLACEHOLDER. Después de configurar Firebase,
/// debes reemplazarlo con el archivo generado automáticamente.
///
/// PASO 1: Crear proyecto en Firebase Console
/// -------------------------------------------
/// 1. Ve a https://console.firebase.google.com/
/// 2. Haz clic en "Agregar proyecto"
/// 3. Ingresa un nombre para tu proyecto (ej: "judisa-taller")
/// 4. Acepta los términos y continúa
/// 5. Opcional: Habilitar Google Analytics (recomendado)
/// 6. Configura Analytics si lo habilitaste, o salta este paso
/// 7. Crea el proyecto
///
/// PASO 2: Agregar app Flutter a Firebase
/// ---------------------------------------
/// 1. En el dashboard del proyecto, haz clic en el icono de Android (</>)
/// 2. Ingresa el nombre del paquete de tu app:
///    - Lo encuentras en: android/app/build.gradle
///    - Busca: applicationId "com.example.judisa_taller"
///    - O usa uno personalizado como: "com.judisa.taller"
/// 3. Ingresa un nickname para la app (opcional)
/// 4. Descarga el archivo google-services.json
///
/// PASO 3: Ubicar google-services.json
/// -------------------------------------
/// 1. Copia el archivo google-services.json descargado
/// 2. Pégalo en: android/app/
/// 3. La ruta debe quedar: android/app/google-services.json
///
/// PASO 4: Configurar iOS (opcional pero recomendado)
/// --------------------------------------------------
/// 1. En Firebase Console, haz clic en "Agregar app" y selecciona iOS
/// 2. Ingresa el Bundle ID de tu app iOS
///    - Lo encuentras en: ios/Runner.xcodeproj/project.pbxproj
///    - O en Xcode: Runner > General > Bundle Identifier
/// 3. Descarga el archivo GoogleService-Info.plist
/// 4. Copia el archivo a: ios/Runner/
/// 5. La ruta debe quedar: ios/Runner/GoogleService-Info.plist
///
/// PASO 5: Habilitar Firestore
/// -----------------------------
/// 1. En Firebase Console, ve a "Firestore Database" en el menú lateral
/// 2. Haz clic en "Crear base de datos"
/// 3. Selecciona "Iniciar en modo de prueba" (para desarrollo)
/// 4. Selecciona la ubicación del servidor (recomendado: us-central1)
/// 5. Habilitar
///
/// PASO 6: Instalar FlutterFire CLI y configurar
/// ---------------------------------------------
/// En tu terminal, ejecuta:
///
///   # Instalar FlutterFire CLI
///   dart pub global activate flutterfire_cli
///
///   # Configurar Firebase en el proyecto
///   flutterfire configure --project=TU_PROJECT_ID
///
/// Reemplaza TU_PROJECT_ID con el ID de tu proyecto de Firebase.
///
/// Esto generará automáticamente el archivo lib/firebase_options.dart
/// con todas las configuraciones correctas.
///
/// NOTA: Si prefieres configurar manualmente sin FlutterFire CLI,
/// consulta la documentación oficial de Firebase para Flutter:
/// https://firebase.google.com/docs/flutter/setup

/// Este placeholder evita errores de compilación temporalmente.
/// REEMPLAZAR con el archivo generado por FlutterFire CLI.
class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static const String placeholder =
      'REEMPLAZAR con firebase_options.dart generado por FlutterFire CLI';
}
