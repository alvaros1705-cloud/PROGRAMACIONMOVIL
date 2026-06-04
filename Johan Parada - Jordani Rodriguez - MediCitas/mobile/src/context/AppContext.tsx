import React, { createContext, useContext, useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import {
  fetchAppointments, insertAppointment, updateAppointmentStatus,
  fetchExams, insertExam,
  fetchMedications,
  Exam, Prescription,
} from '../lib/db';

// ── Exams auto-generated per specialty ───────────────────────────────────────
const SPECIALTY_EXAMS: Record<string, { name: string; type: string }[]> = {
  'Medicina General':  [{ name: 'Hemograma Completo', type: 'Sangre' }, { name: 'Glucosa en Ayunas', type: 'Sangre' }],
  'Cardiología':       [{ name: 'Perfil Lipídico', type: 'Sangre' }, { name: 'Electrocardiograma', type: 'Imagen' }],
  'Dermatología':      [{ name: 'Examen de Piel', type: 'Imagen' }],
  'Oftalmología':      [{ name: 'Agudeza Visual', type: 'Imagen' }],
  'Pediatría':         [{ name: 'Hemograma Pediátrico', type: 'Sangre' }],
  'Ginecología':       [{ name: 'Citología Cervical', type: 'Orina' }, { name: 'Ecografía Pélvica', type: 'Imagen' }],
  'Traumatología':     [{ name: 'Radiografía Ósea', type: 'Imagen' }],
  'Psiquiatría':       [{ name: 'Hemograma Completo', type: 'Sangre' }],
};

// ── Types ────────────────────────────────────────────────────────────────────

export interface Appointment {
  id: string;
  specialty: string;
  status: 'Confirmada' | 'Pendiente' | 'Cancelada' | 'Completada';
  doctor: string;
  date: string;
  time: string;
  location: string;
  color: string;
}

export type { Exam, Prescription };

interface AppContextType {
  appointments: Appointment[];
  exams: Exam[];
  medications: Prescription[];
  loading: boolean;
  addAppointment: (apt: Omit<Appointment, 'id'>) => Promise<void>;
  cancelAppointment: (id: string) => Promise<void>;
  showToast: boolean;
  reload: () => Promise<void>;
}

// ── Context ───────────────────────────────────────────────────────────────────

const AppContext = createContext<AppContextType>({} as AppContextType);

export function AppProvider({ children }: { children: React.ReactNode }) {
  const [appointments, setAppointments] = useState<Appointment[]>([]);
  const [exams, setExams]               = useState<Exam[]>([]);
  const [medications, setMedications]   = useState<Prescription[]>([]);
  const [loading, setLoading]           = useState(true);
  const [showToast, setShowToast]       = useState(false);

  // ── Load all data for a user ────────────────────────────────────────────────
  const loadAll = async (userId: string) => {
    try {
      const [apts, exs, meds] = await Promise.all([
        fetchAppointments(userId),
        fetchExams(userId),
        fetchMedications(userId),
      ]);
      setAppointments(apts);
      setExams(exs);
      setMedications(meds);
    } catch (e) {
      console.error('[AppContext] loadAll error:', e);
    } finally {
      setLoading(false);
    }
  };

  const reload = async () => {
    const { data: { session } } = await supabase.auth.getSession();
    if (session?.user) {
      setLoading(true);
      await loadAll(session.user.id);
    }
  };

  // ── React to auth state ─────────────────────────────────────────────────────
  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      if (session?.user) {
        loadAll(session.user.id);
      } else {
        setLoading(false);
      }
    });

    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      if (session?.user) {
        loadAll(session.user.id);
      } else {
        setAppointments([]);
        setExams([]);
        setMedications([]);
        setLoading(false);
      }
    });

    return () => subscription.unsubscribe();
  }, []);

  // ── Mutations ────────────────────────────────────────────────────────────────

  const addAppointment = async (apt: Omit<Appointment, 'id'>) => {
    const { data: { session } } = await supabase.auth.getSession();
    if (!session?.user) return;
    try {
      const newApt = await insertAppointment(session.user.id, apt);
      setAppointments(prev => [newApt, ...prev]);

      // Auto-crear exámenes relacionados con la especialidad
      const examDefs = SPECIALTY_EXAMS[apt.specialty] ?? [{ name: 'Examen General', type: 'Sangre' }];
      const newExams: Exam[] = [];
      for (const def of examDefs) {
        try {
          const ex = await insertExam(session.user.id, {
            name: def.name,
            type: def.type,
            date: apt.date,
            doctor: apt.doctor,
            status: 'Disponible',
          });
          newExams.push(ex);
        } catch { /* ignore individual exam errors */ }
      }
      if (newExams.length > 0) {
        setExams(prev => [...newExams, ...prev]);
      }

      setShowToast(true);
      setTimeout(() => setShowToast(false), 3500);
    } catch (e) {
      console.error('[AppContext] addAppointment error:', e);
    }
  };

  const cancelAppointment = async (id: string) => {
    try {
      await updateAppointmentStatus(id, 'Cancelada');
      setAppointments(prev =>
        prev.map(a => a.id === id ? { ...a, status: 'Cancelada' as const } : a)
      );
    } catch (e) {
      console.error('[AppContext] cancelAppointment error:', e);
    }
  };

  return (
    <AppContext.Provider value={{
      appointments, exams, medications, loading,
      addAppointment, cancelAppointment,
      showToast, reload,
    }}>
      {children}
    </AppContext.Provider>
  );
}

export const useAppContext = () => useContext(AppContext);
