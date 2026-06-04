import React, { useState } from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { ActivityIndicator, View } from 'react-native';
import { Ionicons, MaterialCommunityIcons } from '@expo/vector-icons';

import { useAuth } from '@medical-app/shared/hooks/useAuth';
import LoginScreen from './screens/LoginScreen';
import RegisterScreen from './screens/RegisterScreen';
import DashboardScreen from './screens/DashboardScreen';
import AppointmentsScreen from './screens/AppointmentsScreen';
import ExamsScreen from './screens/ExamsScreen';
import ProfileScreen from './screens/ProfileScreen';
import BookAppointmentScreen from './screens/BookAppointmentScreen';
import MedicationsScreen from './screens/MedicationsScreen';
import ExamDetailScreen from './screens/ExamDetailScreen';
import SplashAnimScreen from './screens/SplashAnimScreen';

const Stack = createNativeStackNavigator();
const Tab   = createBottomTabNavigator();

function AuthStack() {
  return (
    <Stack.Navigator screenOptions={{ headerShown: false }}>
      <Stack.Screen name="Login"    component={LoginScreen} />
      <Stack.Screen name="Register" component={RegisterScreen} />
    </Stack.Navigator>
  );
}

function AppTabs() {
  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        headerShown: false,
        tabBarActiveTintColor:   '#2563eb',
        tabBarInactiveTintColor: '#94a3b8',
        tabBarStyle: {
          backgroundColor: '#fff',
          borderTopWidth: 1,
          borderTopColor: '#f1f5f9',
          paddingBottom: 8,
          paddingTop: 6,
          height: 64,
        },
        tabBarLabelStyle: { fontSize: 11, fontWeight: '600' },
        tabBarIcon: ({ focused, color }) => {
          if (route.name === 'Inicio')
            return <Ionicons name={focused ? 'home' : 'home-outline'} size={24} color={color} />;
          if (route.name === 'Citas')
            return <Ionicons name={focused ? 'calendar' : 'calendar-outline'} size={24} color={color} />;
          if (route.name === 'Exámenes')
            return <Ionicons name={focused ? 'document-text' : 'document-text-outline'} size={24} color={color} />;
          if (route.name === 'Medicamentos')
            return <MaterialCommunityIcons name={focused ? 'pill' : 'pill'} size={24} color={color} />;
          if (route.name === 'Perfil')
            return <Ionicons name={focused ? 'person' : 'person-outline'} size={24} color={color} />;
          return null;
        },
      })}
    >
      <Tab.Screen name="Inicio"       component={DashboardScreen} />
      <Tab.Screen name="Citas"        component={AppointmentsScreen} />
      <Tab.Screen name="Exámenes"     component={ExamsScreen} />
      <Tab.Screen name="Medicamentos" component={MedicationsScreen} />
      <Tab.Screen name="Perfil"       component={ProfileScreen} />
    </Tab.Navigator>
  );
}

/* Wraps tabs + booking flow as a stack */
function AppStack() {
  return (
    <Stack.Navigator screenOptions={{ headerShown: false }}>
      <Stack.Screen name="Main"          component={AppTabs} />
      <Stack.Screen
        name="BookAppointment"
        component={BookAppointmentScreen}
        options={{ animation: 'slide_from_right' }}
      />
      <Stack.Screen
        name="Medications"
        component={MedicationsScreen}
        options={{ animation: 'slide_from_right' }}
      />
      <Stack.Screen
        name="ExamDetail"
        component={ExamDetailScreen}
        options={{ animation: 'slide_from_right' }}
      />
    </Stack.Navigator>
  );
}

export default function RootNavigator() {
  const { session, loading } = useAuth();
  const [splashDone, setSplashDone] = useState(false);

  // Show animated splash on first launch
  if (!splashDone) {
    return <SplashAnimScreen onFinish={() => setSplashDone(true)} />;
  }

  if (loading) {
    return (
      <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: '#eff6ff' }}>
        <ActivityIndicator size="large" color="#2563eb" />
      </View>
    );
  }

  return (
    <NavigationContainer>
      {session ? <AppStack /> : <AuthStack />}
    </NavigationContainer>
  );
}
