import React, { useState, useMemo } from 'react';
import {
  View, Text, StyleSheet, ScrollView,
  TouchableOpacity, StatusBar, Alert, ActivityIndicator,
  Modal, TextInput, KeyboardAvoidingView, Platform,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons, MaterialCommunityIcons } from '@expo/vector-icons';
import { useAppContext } from '../../src/context/AppContext';
import { insertMedication } from '../../src/lib/db';
import { supabase } from '../../src/lib/supabase';
import type { Prescription } from '../../src/context/AppContext';

// ─── Types ────────────────────────────────────────────────────────────────────

interface ScheduleItem {
  id: string;
  name: string;
  time: string;
  taken: boolean;
}

// ─── Sub-components ───────────────────────────────────────────────────────────

function AdherenceBar({ value, total = 3 }: { value: number; total?: number }) {
  return (
    <View style={adh.row}>
      <View style={adh.track}>
        {Array.from({ length: total }).map((_, i) => (
          <View
            key={i}
            style={[
              adh.segment,
              { marginRight: i < total - 1 ? 4 : 0 },
              i < value ? adh.filled : adh.empty,
            ]}
          />
        ))}
      </View>
      <Text style={adh.label}>{value}/{total}</Text>
    </View>
  );
}

const adh = StyleSheet.create({
  row:     { flexDirection: 'row', alignItems: 'center', gap: 10, marginBottom: 12 },
  track:   { flex: 1, flexDirection: 'row' },
  segment: { flex: 1, height: 7, borderRadius: 4 },
  filled:  { backgroundColor: '#16a34a' },
  empty:   { backgroundColor: '#e2e8f0' },
  label:   { fontSize: 12, fontWeight: '700', color: '#64748b', minWidth: 28 },
});

// ─── Main Screen ──────────────────────────────────────────────────────────────

export default function MedicationsScreen({ navigation }: any) {
  const { medications: prescriptions, loading, reload } = useAppContext();

  // ── Add medication form state ──────────────────────────────────────────────
  const [showForm, setShowForm]     = useState(false);
  const [saving, setSaving]         = useState(false);
  const [formName, setFormName]     = useState('');
  const [formDesc, setFormDesc]     = useState('');
  const [formFreq, setFormFreq]     = useState('');
  const [formHours, setFormHours]   = useState('');
  const [formDuration, setFormDuration] = useState('Continuo');
  const [formDoctor, setFormDoctor] = useState('');

  const resetForm = () => {
    setFormName(''); setFormDesc(''); setFormFreq('');
    setFormHours(''); setFormDuration('Continuo'); setFormDoctor('');
  };

  const handleSaveMedication = async () => {
    if (!formName.trim() || !formFreq.trim() || !formHours.trim() || !formDoctor.trim()) {
      Alert.alert('Campos requeridos', 'Por favor completa nombre, frecuencia, horarios y médico.');
      return;
    }
    setSaving(true);
    try {
      const { data: { session } } = await supabase.auth.getSession();
      if (!session?.user) return;
      const today = new Date();
      const months = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
      const dateStr = `${today.getDate()} ${months[today.getMonth()]}, ${today.getFullYear()}`;
      await insertMedication(session.user.id, {
        name: formName.trim(),
        description: formDesc.trim(),
        frequency: formFreq.trim(),
        hours: formHours.trim(),
        duration: formDuration.trim() || 'Continuo',
        doctor: formDoctor.trim(),
        date: dateStr,
        status: 'Activo',
        adherence: 0,
        color: '#2563eb',
      });
      await reload();
      resetForm();
      setShowForm(false);
      Alert.alert('✅ Medicamento agregado', `${formName} fue registrado correctamente.`);
    } catch (e) {
      Alert.alert('Error', 'No se pudo guardar el medicamento. Intenta de nuevo.');
    } finally {
      setSaving(false);
    }
  };

  // Derive today's schedule from medication hours
  const [takenIds, setTakenIds] = useState<Set<string>>(new Set());

  const schedule = useMemo<ScheduleItem[]>(() =>
    prescriptions
      .filter(p => p.status === 'Activo')
      .flatMap(p =>
        p.hours.split(',').map((h, idx) => ({
          id: `${p.id}-${idx}`,
          name: p.name,
          time: h.trim(),
          taken: takenIds.has(`${p.id}-${idx}`),
        }))
      ),
    [prescriptions, takenIds]
  );

  const takenCount   = schedule.filter(s => s.taken).length;
  const pendingCount = schedule.filter(s => !s.taken).length;
  const activeCount  = prescriptions.filter(p => p.status === 'Activo').length;

  const markTaken = (id: string) => {
    setTakenIds(prev => new Set([...prev, id]));
  };

  const handleMarcar = (item: ScheduleItem) => {
    Alert.alert(
      'Marcar como tomado',
      `¿Confirmás que tomaste ${item.name} a las ${item.time}?`,
      [
        { text: 'Cancelar', style: 'cancel' },
        { text: 'Confirmar', onPress: () => markTaken(item.id) },
      ]
    );
  };

  const handleAgregar = () => setShowForm(true);

  const handleDetails = (p: Prescription) => {
    Alert.alert(
      p.name,
      `Indicación: ${p.description}\n\nFrecuencia: ${p.frequency}\nHorarios: ${p.hours}\nDuración: ${p.duration}\n\nRecetado por: ${p.doctor}\nFecha: ${p.date}`,
      [{ text: 'Cerrar' }]
    );
  };

  const handleReminders = (p: Prescription) => {
    Alert.alert(
      'Recordatorios',
      `Tienes recordatorios configurados para ${p.name}.\n\n🔔 ${p.hours} - Notificación activa\n\n(Administración de notificaciones próximamente)`,
      [{ text: 'OK' }]
    );
  };

  return (
    <View style={styles.container}>
      <StatusBar barStyle="light-content" backgroundColor="#6d28d9" />

      {/* ── Modal Agregar Medicamento ── */}
      <Modal visible={showForm} animationType="slide" transparent>
        <KeyboardAvoidingView behavior={Platform.OS === 'ios' ? 'padding' : 'height'} style={mf.overlay}>
          <View style={mf.sheet}>
            <View style={mf.header}>
              <Text style={mf.title}>Agregar Medicamento</Text>
              <TouchableOpacity onPress={() => { resetForm(); setShowForm(false); }}>
                <Ionicons name="close" size={24} color="#64748b" />
              </TouchableOpacity>
            </View>

            <ScrollView showsVerticalScrollIndicator={false} keyboardShouldPersistTaps="handled">
              <Text style={mf.label}>Nombre del medicamento *</Text>
              <TextInput style={mf.input} placeholder="Ej: Losartán 50mg" value={formName} onChangeText={setFormName} />

              <Text style={mf.label}>Indicación / descripción</Text>
              <TextInput style={mf.input} placeholder="Ej: Control de presión arterial" value={formDesc} onChangeText={setFormDesc} />

              <Text style={mf.label}>Frecuencia *</Text>
              <TextInput style={mf.input} placeholder="Ej: 1 vez al día" value={formFreq} onChangeText={setFormFreq} />

              <Text style={mf.label}>Horarios * (separados por coma)</Text>
              <TextInput style={mf.input} placeholder="Ej: 8:00 AM, 8:00 PM" value={formHours} onChangeText={setFormHours} />

              <Text style={mf.label}>Duración</Text>
              <TextInput style={mf.input} placeholder="Ej: 30 días / Continuo" value={formDuration} onChangeText={setFormDuration} />

              <Text style={mf.label}>Médico que lo recetó *</Text>
              <TextInput style={mf.input} placeholder="Ej: Dr. Carlos Rodríguez" value={formDoctor} onChangeText={setFormDoctor} />

              <TouchableOpacity
                style={[mf.saveBtn, saving && { opacity: 0.6 }]}
                onPress={handleSaveMedication}
                disabled={saving}
              >
                <Text style={mf.saveTxt}>{saving ? 'Guardando...' : 'Guardar Medicamento'}</Text>
              </TouchableOpacity>
              <View style={{ height: 24 }} />
            </ScrollView>
          </View>
        </KeyboardAvoidingView>
      </Modal>

      {/* ── Gradient Header ── */}
      <LinearGradient colors={['#6d28d9', '#2563eb']} style={styles.header}>
        {/* Title row */}
        <View style={styles.headerTop}>
          <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backBtn}>
            <Ionicons name="chevron-back" size={20} color="#fff" />
          </TouchableOpacity>
          <Text style={styles.headerTitle}>Mis Medicamentos</Text>
          <TouchableOpacity style={styles.addBtn} onPress={handleAgregar}>
            <Ionicons name="add" size={15} color="#6d28d9" />
            <Text style={styles.addBtnTxt}>Agregar</Text>
          </TouchableOpacity>
        </View>

        {/* Stats */}
        <View style={styles.statsRow}>
          <View style={styles.statBox}>
            <Text style={styles.statNum}>{activeCount}</Text>
            <Text style={styles.statLbl}>Activos</Text>
          </View>
          <View style={styles.statBox}>
            <Text style={styles.statNum}>{takenCount}</Text>
            <Text style={styles.statLbl}>Tomados hoy</Text>
          </View>
          <View style={styles.statBox}>
            <Text style={styles.statNum}>{pendingCount}</Text>
            <Text style={styles.statLbl}>Pendientes</Text>
          </View>
        </View>
      </LinearGradient>

      <ScrollView style={styles.body} showsVerticalScrollIndicator={false}>

        {loading && (
          <ActivityIndicator size="large" color="#6d28d9" style={{ marginTop: 40 }} />
        )}

        {/* ── Horario de Hoy ── */}
        {!loading && <Text style={styles.sectionTitle}>Horario de Hoy</Text>}
        {!loading && schedule.length === 0 && (
          <View style={{ padding: 20, alignItems: 'center' }}>
            <Text style={{ color: '#94a3b8', fontSize: 14 }}>No hay medicamentos registrados hoy</Text>
          </View>
        )}
        {!loading && <View style={styles.section}>
          {schedule.map((item, idx) => (
            <View
              key={item.id}
              style={[
                styles.scheduleItem,
                idx < schedule.length - 1 && styles.scheduleItemBorder,
              ]}
            >
              {/* Icon */}
              <View style={[
                styles.scheduleIcon,
                { backgroundColor: item.taken ? '#dcfce7' : '#dbeafe' },
              ]}>
                {item.taken
                  ? <Ionicons name="checkmark" size={20} color="#16a34a" />
                  : <MaterialCommunityIcons name="pill" size={20} color="#2563eb" />
                }
              </View>

              {/* Info */}
              <View style={styles.scheduleInfo}>
                <Text style={[styles.scheduleName, item.taken && styles.scheduleNameDone]}>
                  {item.name}
                </Text>
                <View style={styles.scheduleTimeRow}>
                  <Ionicons name="time-outline" size={13} color="#94a3b8" />
                  <Text style={styles.scheduleTime}>{item.time}</Text>
                  {item.taken && (
                    <View style={styles.takenBadge}>
                      <Text style={styles.takenTxt}>Tomado</Text>
                    </View>
                  )}
                </View>
              </View>

              {/* Action */}
              {!item.taken && (
                <TouchableOpacity style={styles.marcarBtn} onPress={() => handleMarcar(item)}>
                  <Text style={styles.marcarTxt}>Marcar</Text>
                </TouchableOpacity>
              )}
            </View>
          ))}
        </View>}

        {/* ── Recetas Activas ── */}
        <View style={styles.sectionHeader}>
          <Text style={styles.sectionTitle}>Recetas Activas</Text>
          <TouchableOpacity onPress={() =>
            Alert.alert('Recetas', 'Vista completa de recetas próximamente.')
          }>
            <Text style={styles.sectionLink}>Ver todas</Text>
          </TouchableOpacity>
        </View>

        {prescriptions.map(p => (
          <View key={p.id} style={styles.prescCard}>
            <View style={[styles.prescBorder, { backgroundColor: p.color }]} />
            <View style={styles.prescBody}>
              {/* Name + badge */}
              <View style={styles.prescNameRow}>
                <Text style={styles.prescName}>{p.name}</Text>
                <View style={[styles.statusBadge, p.status === 'Activo' ? styles.badgeGreen : styles.badgeGrey]}>
                  <Text style={[styles.statusTxt, p.status === 'Activo' ? styles.statusGreen : styles.statusGrey]}>
                    {p.status}
                  </Text>
                </View>
              </View>

              <Text style={styles.prescDesc}>{p.description}</Text>

              {/* Meta rows */}
              <View style={styles.metaRow}>
                <Ionicons name="time-outline" size={14} color="#64748b" />
                <Text style={styles.metaLbl}>Frecuencia:</Text>
                <Text style={styles.metaVal}>{p.frequency}</Text>
              </View>
              <View style={styles.metaRow}>
                <Ionicons name="notifications-outline" size={14} color="#64748b" />
                <Text style={styles.metaLbl}>Horarios:</Text>
                <Text style={styles.metaVal}>{p.hours}</Text>
              </View>
              <View style={[styles.metaRow, { marginBottom: 10 }]}>
                <Ionicons name="calendar-outline" size={14} color="#64748b" />
                <Text style={styles.metaLbl}>Duración:</Text>
                <Text style={styles.metaVal}>{p.duration}</Text>
              </View>

              {/* Doctor */}
              <Text style={styles.prescDoctor}>
                Recetado por: <Text style={styles.prescDoctorBold}>{p.doctor}</Text>
                {'  ·  '}{p.date}
              </Text>

              {/* Adherence */}
              <Text style={styles.adherenceLbl}>Adherencia últimos 3 días</Text>
              <AdherenceBar value={p.adherence} />

              {/* Buttons */}
              <View style={styles.prescActions}>
                <TouchableOpacity style={styles.detailsBtn} onPress={() => handleDetails(p)}>
                  <Text style={styles.detailsTxt}>Ver Detalles</Text>
                </TouchableOpacity>
                <TouchableOpacity style={styles.remindersBtn} onPress={() => handleReminders(p)}>
                  <Ionicons name="notifications-outline" size={15} color="#2563eb" />
                  <Text style={styles.remindersTxt}>Recordatorios</Text>
                </TouchableOpacity>
              </View>
            </View>
          </View>
        ))}

        {/* ── Consejo del día ── */}
        <View style={styles.tipCard}>
          <View style={styles.tipIcon}>
            <Ionicons name="notifications" size={22} color="#fff" />
          </View>
          <View style={{ flex: 1 }}>
            <Text style={styles.tipTitle}>Consejo del día</Text>
            <Text style={styles.tipTxt}>
              Toma tus medicamentos a la misma hora todos los días para crear una rutina. Esto ayuda a mejorar la adherencia al tratamiento.
            </Text>
          </View>
        </View>

        <View style={{ height: 32 }} />
      </ScrollView>
    </View>
  );
}

// ─── Styles ───────────────────────────────────────────────────────────────────

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f8fafc' },

  // Header
  header:     { paddingTop: 52, paddingHorizontal: 20, paddingBottom: 20 },
  headerTop:  { flexDirection: 'row', alignItems: 'center', marginBottom: 20 },
  backBtn:    { marginRight: 10 },
  headerTitle:{ fontSize: 20, fontWeight: 'bold', color: '#fff', flex: 1 },
  addBtn:     {
    flexDirection: 'row', alignItems: 'center', gap: 4,
    backgroundColor: '#fff', borderRadius: 20, paddingHorizontal: 12, paddingVertical: 7,
  },
  addBtnTxt:  { fontSize: 13, color: '#6d28d9', fontWeight: '700' },
  statsRow:   { flexDirection: 'row', gap: 10 },
  statBox:    {
    flex: 1, backgroundColor: 'rgba(255,255,255,0.18)',
    borderRadius: 12, paddingVertical: 14, alignItems: 'center',
  },
  statNum:    { fontSize: 26, fontWeight: 'bold', color: '#fff', lineHeight: 30 },
  statLbl:    { fontSize: 11, color: 'rgba(255,255,255,0.85)', marginTop: 2, textAlign: 'center' },

  // Body
  body:          { flex: 1, paddingHorizontal: 16 },
  sectionHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginTop: 20, marginBottom: 10 },
  sectionTitle:  { fontSize: 17, fontWeight: '700', color: '#1e293b', marginTop: 20, marginBottom: 10 },
  sectionLink:   { fontSize: 14, color: '#2563eb', fontWeight: '600' },

  // Schedule card
  section:           {
    backgroundColor: '#fff', borderRadius: 16,
    shadowColor: '#000', shadowOffset: { width: 0, height: 1 }, shadowOpacity: 0.06, shadowRadius: 6, elevation: 2,
  },
  scheduleItem:      { flexDirection: 'row', alignItems: 'center', padding: 14, gap: 12 },
  scheduleItemBorder:{ borderBottomWidth: 1, borderBottomColor: '#f1f5f9' },
  scheduleIcon:      { width: 44, height: 44, borderRadius: 12, alignItems: 'center', justifyContent: 'center' },
  scheduleInfo:      { flex: 1 },
  scheduleName:      { fontSize: 14, fontWeight: '700', color: '#1e293b', marginBottom: 4 },
  scheduleNameDone:  { textDecorationLine: 'line-through', color: '#94a3b8' },
  scheduleTimeRow:   { flexDirection: 'row', alignItems: 'center', gap: 4 },
  scheduleTime:      { fontSize: 13, color: '#64748b' },
  takenBadge:        { backgroundColor: '#dcfce7', paddingHorizontal: 8, paddingVertical: 2, borderRadius: 6, marginLeft: 6 },
  takenTxt:          { fontSize: 12, color: '#16a34a', fontWeight: '600' },
  marcarBtn:         { backgroundColor: '#2563eb', borderRadius: 8, paddingHorizontal: 16, paddingVertical: 8 },
  marcarTxt:         { color: '#fff', fontSize: 13, fontWeight: '700' },

  // Prescription cards
  prescCard:    {
    flexDirection: 'row', backgroundColor: '#fff', borderRadius: 16,
    marginBottom: 12, overflow: 'hidden',
    shadowColor: '#000', shadowOffset: { width: 0, height: 1 }, shadowOpacity: 0.07, shadowRadius: 6, elevation: 2,
  },
  prescBorder:  { width: 4, alignSelf: 'stretch' },
  prescBody:    { flex: 1, padding: 14 },
  prescNameRow: { flexDirection: 'row', alignItems: 'center', flexWrap: 'wrap', gap: 8, marginBottom: 4 },
  prescName:    { fontSize: 16, fontWeight: '700', color: '#1e293b' },
  statusBadge:  { paddingHorizontal: 8, paddingVertical: 3, borderRadius: 6 },
  badgeGreen:   { backgroundColor: '#dcfce7' },
  badgeGrey:    { backgroundColor: '#f1f5f9' },
  statusTxt:    { fontSize: 12, fontWeight: '600' },
  statusGreen:  { color: '#16a34a' },
  statusGrey:   { color: '#94a3b8' },
  prescDesc:    { fontSize: 13, color: '#64748b', marginBottom: 10 },
  metaRow:      { flexDirection: 'row', alignItems: 'center', gap: 6, marginBottom: 5 },
  metaLbl:      { fontSize: 13, color: '#64748b' },
  metaVal:      { fontSize: 13, color: '#1e293b', fontWeight: '500', flex: 1 },
  prescDoctor:  { fontSize: 12, color: '#94a3b8', marginBottom: 8 },
  prescDoctorBold: { fontWeight: '600', color: '#64748b' },
  adherenceLbl: { fontSize: 12, color: '#64748b', marginBottom: 6 },
  prescActions: {
    flexDirection: 'row', gap: 10,
    paddingTop: 10, borderTopWidth: 1, borderTopColor: '#f1f5f9',
  },
  detailsBtn:   {
    flex: 1, borderWidth: 1.5, borderColor: '#e2e8f0', borderRadius: 8,
    paddingVertical: 8, alignItems: 'center',
  },
  detailsTxt:   { fontSize: 13, color: '#374151', fontWeight: '500' },
  remindersBtn: {
    flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 5,
    borderWidth: 1.5, borderColor: '#bfdbfe', borderRadius: 8, paddingVertical: 8,
  },
  remindersTxt: { fontSize: 13, color: '#2563eb', fontWeight: '500' },

  // Tip card (dummy to locate end of styles)
  tipCard:  {
    flexDirection: 'row', alignItems: 'flex-start', gap: 14,
    backgroundColor: '#eff6ff', borderRadius: 14, padding: 16, marginTop: 4, marginBottom: 8,
  },
  tipIcon:  {
    width: 44, height: 44, borderRadius: 22,
    backgroundColor: '#2563eb', alignItems: 'center', justifyContent: 'center',
    flexShrink: 0,
  },
  tipTitle: { fontSize: 14, fontWeight: '700', color: '#1e40af', marginBottom: 4 },
  tipTxt:   { fontSize: 13, color: '#1e40af', lineHeight: 20 },
});

// ── Modal form styles ─────────────────────────────────────────────────────────
const mf = StyleSheet.create({
  overlay:  { flex: 1, backgroundColor: 'rgba(0,0,0,0.5)', justifyContent: 'flex-end' },
  sheet:    {
    backgroundColor: '#fff', borderTopLeftRadius: 24, borderTopRightRadius: 24,
    padding: 24, maxHeight: '90%',
  },
  header:   { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 20 },
  title:    { fontSize: 18, fontWeight: '700', color: '#1e293b' },
  label:    { fontSize: 13, fontWeight: '600', color: '#64748b', marginBottom: 6, marginTop: 14 },
  input:    {
    borderWidth: 1.5, borderColor: '#e2e8f0', borderRadius: 10,
    paddingHorizontal: 14, paddingVertical: 12, fontSize: 15, color: '#1e293b',
  },
  saveBtn:  {
    backgroundColor: '#6d28d9', borderRadius: 12,
    paddingVertical: 14, alignItems: 'center', marginTop: 24,
  },
  saveTxt:  { color: '#fff', fontSize: 16, fontWeight: '700' },
});
