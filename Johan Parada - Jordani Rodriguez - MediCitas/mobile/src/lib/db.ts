import { supabase } from './supabase';
import type { Appointment } from '../context/AppContext';

// ── Appointments ──────────────────────────────────────────────────────────────

export async function fetchAppointments(userId: string): Promise<Appointment[]> {
  const { data, error } = await supabase
    .from('appointments')
    .select('*')
    .eq('user_id', userId)
    .order('created_at', { ascending: false });
  if (error) throw error;
  return (data ?? []) as Appointment[];
}

export async function insertAppointment(
  userId: string,
  apt: Omit<Appointment, 'id'>
): Promise<Appointment> {
  const { data, error } = await supabase
    .from('appointments')
    .insert({ user_id: userId, ...apt })
    .select()
    .single();
  if (error) throw error;
  return data as Appointment;
}

export async function updateAppointmentStatus(
  id: string,
  status: Appointment['status']
): Promise<void> {
  const { error } = await supabase
    .from('appointments')
    .update({ status })
    .eq('id', id);
  if (error) throw error;
}

// ── Exams ─────────────────────────────────────────────────────────────────────

export interface Exam {
  id: string;
  name: string;
  type: string;
  status: 'Disponible' | 'Pendiente';
  date: string;
  doctor: string;
  result?: string;
  notes?: string;
}

export async function fetchExams(userId: string): Promise<Exam[]> {
  const { data, error } = await supabase
    .from('exams')
    .select('*')
    .eq('user_id', userId)
    .order('created_at', { ascending: false });
  if (error) throw error;
  return (data ?? []) as Exam[];
}

export async function insertExam(
  userId: string,
  exam: Omit<Exam, 'id'>
): Promise<Exam> {
  const { data, error } = await supabase
    .from('exams')
    .insert({ user_id: userId, ...exam })
    .select()
    .single();
  if (error) throw error;
  return data as Exam;
}

// ── Medications ───────────────────────────────────────────────────────────────

export interface Prescription {
  id: string;
  name: string;
  status: 'Activo' | 'Inactivo';
  description: string;
  frequency: string;
  hours: string;
  duration: string;
  doctor: string;
  date: string;
  adherence: number;
  color: string;
}

export async function fetchMedications(userId: string): Promise<Prescription[]> {
  const { data, error } = await supabase
    .from('medications')
    .select('*')
    .eq('user_id', userId)
    .order('created_at', { ascending: false });
  if (error) throw error;
  return (data ?? []) as Prescription[];
}

export async function insertMedication(
  userId: string,
  med: Omit<Prescription, 'id'>
): Promise<Prescription> {
  const { data, error } = await supabase
    .from('medications')
    .insert({ user_id: userId, ...med })
    .select()
    .single();
  if (error) throw error;
  return data as Prescription;
}

// ── Profile ───────────────────────────────────────────────────────────────────

export interface Profile {
  id: string;
  full_name: string | null;
  phone: string | null;
  eps: string | null;
  blood_type: string | null;
  allergies: string[];
}

export async function fetchProfile(userId: string): Promise<Profile | null> {
  const { data, error } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', userId)
    .single();
  if (error) return null;
  return data as Profile;
}

export async function upsertProfile(profile: Partial<Profile> & { id: string }): Promise<void> {
  const { error } = await supabase
    .from('profiles')
    .upsert({ ...profile, updated_at: new Date().toISOString() });
  if (error) throw error;
}
