import React from 'react';
import * as SplashScreen from 'expo-splash-screen';
import { AppProvider } from '../src/context/AppContext';
import * as Font from 'expo-font';
import * as SystemUI from 'expo-system-ui';
import { useEffect } from 'react';
import RootNavigator from './RootNavigator';

// Mantener la splash screen visible mientras cargamos recursos
SplashScreen.preventAutoHideAsync();

export default function App() {
  const [fontLoaded, setFontLoaded] = React.useState(false);

  useEffect(() => {
    async function prepare() {
      try {
        // Cargar fuentes personalizadas si las hay
        await Font.loadAsync({
          // 'custom-font': require('../assets/fonts/CustomFont.ttf'),
        });
        
        // Configurar el color de la barra del sistema
        await SystemUI.setBackgroundColorAsync('#ffffff');
      } catch (e) {
        console.warn(e);
      } finally {
        setFontLoaded(true);
        await SplashScreen.hideAsync();
      }
    }

    prepare();
  }, []);

  if (!fontLoaded) {
    return null;
  }

  return (
    <AppProvider>
      <RootNavigator />
    </AppProvider>
  );
}
