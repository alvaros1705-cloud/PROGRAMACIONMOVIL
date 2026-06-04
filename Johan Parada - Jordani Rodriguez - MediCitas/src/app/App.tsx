import { useState, useEffect } from 'react';
import { Toaster } from './components/ui/sonner';
import LoginScreen from './components/LoginScreen';
import RegisterScreen from './components/RegisterScreen';
import DashboardScreen from './components/DashboardScreen';
import AppointmentsScreen from './components/AppointmentsScreen';
import ExamsScreen from './components/ExamsScreen';
import ProfileScreen from './components/ProfileScreen';
import MedicationsScreen from './components/MedicationsScreen';
import DiscreteMathScreen from './components/DiscreteMathScreen';
import { supabase } from '../lib/supabase';
import type { Session } from '@supabase/supabase-js';

type Screen = 'login' | 'register' | 'dashboard' | 'appointments' | 'exams' | 'profile' | 'medications' | 'discrete';

export default function App() {
  const [currentScreen, setCurrentScreen] = useState<Screen>('login');
  const [openNewAppointment, setOpenNewAppointment] = useState(false);
  const [session, setSession] = useState<Session | null>(null);
  const [userData, setUserData] = useState<{ full_name?: string; email?: string; phone?: string; eps?: string } | null>(null);
  const [loading, setLoading] = useState(true);

  const normalizeUserData = (session: Session | null) => {
    if (!session) return null;
    const user = session.user;
    return {
      full_name: user.user_metadata?.full_name || user.user_metadata?.name || '',
      email: user.email || '',
      phone: user.user_metadata?.phone || '',
      eps: user.user_metadata?.eps || '',
    };
  };

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
      setUserData(normalizeUserData(session));
      if (session) setCurrentScreen('dashboard');
      setLoading(false);
    });

    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session);
      setUserData(normalizeUserData(session));
      if (session) {
        setCurrentScreen('dashboard');
      } else {
        setCurrentScreen('login');
      }
    });

    return () => subscription.unsubscribe();
  }, []);

  const handleNavigate = (screen: string) => {
    if (screen.includes('appointments?new=true')) {
      setCurrentScreen('appointments');
      setOpenNewAppointment(true);
    } else {
      setCurrentScreen(screen as Screen);
      setOpenNewAppointment(false);
    }
  };

  const handleSignOut = async () => {
    const { error } = await supabase.auth.signOut();
    if (!error) {
      setSession(null);
      setUserData(null);
      setCurrentScreen('login');
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 to-cyan-50 flex items-center justify-center">
        <div className="text-center">
          <div className="w-16 h-16 bg-blue-600 rounded-full flex items-center justify-center mx-auto mb-4 animate-pulse">
            <svg className="w-8 h-8 text-white" fill="currentColor" viewBox="0 0 24 24">
              <path d="M12 21.593c-5.63-5.539-11-10.297-11-14.402 0-3.791 3.068-5.191 5.281-5.191 1.312 0 4.151.501 5.719 4.457 1.59-3.968 4.464-4.447 5.726-4.447 2.54 0 5.274 1.621 5.274 5.181 0 4.069-5.136 8.625-11 14.402z" />
            </svg>
          </div>
          <p className="text-gray-500 text-sm">Cargando MediCitas...</p>
        </div>
      </div>
    );
  }

  return (
    <>
      <div className="size-full">
        {!session && currentScreen === 'login' && <LoginScreen onNavigate={handleNavigate} />}
        {!session && currentScreen === 'register' && <RegisterScreen onNavigate={handleNavigate} />}
        {session && currentScreen === 'dashboard' && <DashboardScreen onNavigate={handleNavigate} user={userData} />}
        {session && currentScreen === 'appointments' && (
          <AppointmentsScreen
            onNavigate={handleNavigate}
            openNew={openNewAppointment}
            onCloseNew={() => setOpenNewAppointment(false)}
          />
        )}
        {session && currentScreen === 'exams' && <ExamsScreen onNavigate={handleNavigate} />}
        {session && currentScreen === 'discrete' && <DiscreteMathScreen onNavigate={handleNavigate} />}
        {session && currentScreen === 'profile' && (
          <ProfileScreen onNavigate={handleNavigate} onSignOut={handleSignOut} user={userData} />
        )}
        {session && currentScreen === 'medications' && <MedicationsScreen onNavigate={handleNavigate} />}
      </div>
      <Toaster />
    </>
  );
}