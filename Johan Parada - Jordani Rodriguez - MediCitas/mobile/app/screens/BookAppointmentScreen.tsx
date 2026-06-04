import React, { useState } from 'react';
import {
  View, Text, StyleSheet, ScrollView, TouchableOpacity,
  StatusBar, Alert, Dimensions,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons } from '@expo/vector-icons';
import { useAppContext } from '../../src/context/AppContext';

const { width: SW } = Dimensions.get('window');

// ─── Data ────────────────────────────────────────────────────────────────────

const SPECIALTIES = [
  { name: 'Medicina General', emoji: '🩺', color: '#2563eb' },
  { name: 'Cardiología',      emoji: '❤️',  color: '#dc2626' },
  { name: 'Dermatología',     emoji: '✨',  color: '#7c3aed' },
  { name: 'Oftalmología',     emoji: '👁️',  color: '#0891b2' },
  { name: 'Pediatría',        emoji: '👶',  color: '#f59e0b' },
  { name: 'Ginecología',      emoji: '🌸',  color: '#ec4899' },
  { name: 'Traumatología',    emoji: '🦴',  color: '#6b7280' },
  { name: 'Psiquiatría',      emoji: '🧠',  color: '#8b5cf6' },
];

type Specialty = typeof SPECIALTIES[0];

const DOCTORS: Record<string, { name: string; available: boolean; rating: number; years: number }[]> = {
  'Medicina General': [
    { name: 'Dr. Carlos Rodríguez', available: true,  rating: 4.8, years: 15 },
    { name: 'Dra. Patricia López',  available: true,  rating: 4.9, years: 12 },
    { name: 'Dr. Roberto Sánchez', available: false, rating: 4.7, years: 10 },
  ],
  'Cardiología': [
    { name: 'Dra. María González', available: true,  rating: 4.9, years: 18 },
    { name: 'Dr. Andrés Torres',   available: true,  rating: 4.7, years: 14 },
    { name: 'Dra. Lucía Vargas',   available: false, rating: 4.8, years: 20 },
  ],
  'Dermatología': [
    { name: 'Dr. Luis Martínez', available: true,  rating: 4.8, years: 11 },
    { name: 'Dra. Ana Ramírez',  available: true,  rating: 4.6, years: 8  },
  ],
  'Oftalmología': [
    { name: 'Dr. Felipe Herrera', available: true,  rating: 4.9, years: 16 },
    { name: 'Dra. Claudia Mora',  available: false, rating: 4.7, years: 13 },
  ],
  'Pediatría': [
    { name: 'Dra. Sofía Castro', available: true, rating: 5.0, years: 14 },
    { name: 'Dr. Javier Ruiz',   available: true, rating: 4.8, years: 9  },
  ],
  'Ginecología': [
    { name: 'Dra. Isabella Díaz',  available: true,  rating: 4.9, years: 17 },
    { name: 'Dr. Tomás Guerrero', available: false, rating: 4.6, years: 12 },
  ],
  'Traumatología': [
    { name: 'Dr. Sergio Medina',     available: true, rating: 4.7, years: 19 },
    { name: 'Dra. Valentina Cruz', available: true, rating: 4.8, years: 11 },
  ],
  'Psiquiatría': [
    { name: 'Dr. Mateo Parra',       available: true, rating: 4.8, years: 15 },
    { name: 'Dra. Natalia Jiménez', available: true, rating: 4.9, years: 13 },
  ],
};

const LOCATIONS: Record<string, string[]> = {
  'Medicina General': ['Clínica del Norte, Piso 3', 'Centro Médico Sur, Consultorio 101'],
  'Cardiología':     ['Hospital Central, Consultorio 205', 'Clínica Cardio Vital, Piso 5'],
  'Dermatología':    ['Centro Médico Sur, Piso 2', 'Clínica Dermosalud, Consultorio 3'],
  'Oftalmología':    ['Clínica Visual, Consultorio 103', 'Hospital San José - Oftalmología'],
  'Pediatría':       ['Clínica del Niño, Piso 1', 'Hospital Pediátrico Central'],
  'Ginecología':     ['Clínica de la Mujer, Piso 4', 'Hospital Universitario - Ginecología'],
  'Traumatología':   ['Hospital Ortopédico, Piso 6', 'Centro Médico Trauma, Consultorio 8'],
  'Psiquiatría':     ['Clínica de Salud Mental, Piso 3', 'Instituto Psiquiátrico Nacional'],
};

const TIME_SLOTS       = ['8:00 AM', '9:00 AM', '10:00 AM', '11:00 AM', '2:00 PM', '3:00 PM', '4:00 PM', '5:00 PM'];
const UNAVAILABLE_TIMES = new Set(['10:00 AM', '4:00 PM']);

const DAYS_ES   = ['dom', 'lun', 'mar', 'mié', 'jue', 'vie', 'sáb'];
const MONTHS_ES = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
const MONTHS_FULL = ['enero','febrero','marzo','abril','mayo','junio','julio','agosto','septiembre','octubre','noviembre','diciembre'];
const DAYS_FULL   = ['domingo','lunes','martes','miércoles','jueves','viernes','sábado'];
const MONTHS_SHORT = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];

function getNextDays(count: number): Date[] {
  const days: Date[] = [];
  const d = new Date();
  d.setDate(d.getDate() + 1);
  while (days.length < count) {
    if (d.getDay() !== 0) days.push(new Date(d)); // skip Sundays
    d.setDate(d.getDate() + 1);
  }
  return days;
}

function formatFull(d: Date) {
  return `${DAYS_FULL[d.getDay()]}, ${d.getDate()} de ${MONTHS_FULL[d.getMonth()]} de ${d.getFullYear()}`;
}
function formatShort(d: Date) {
  return `${d.getDate()} ${MONTHS_SHORT[d.getMonth()]}, ${d.getFullYear()}`;
}

// ─── Step Indicator ──────────────────────────────────────────────────────────

function StepIndicator({ step }: { step: number }) {
  return (
    <View style={si.row}>
      {[0, 1, 2].map((i, idx) => {
        const done   = step > i;
        const active = step === i;
        return (
          <React.Fragment key={i}>
            <View style={[si.circle, (done || active) ? si.circleBlue : si.circleGrey]}>
              {done
                ? <Ionicons name="checkmark" size={14} color="#fff" />
                : <Text style={si.num}>{i + 1}</Text>}
            </View>
            {idx < 2 && <View style={[si.line, done ? si.lineDone : si.lineGrey]} />}
          </React.Fragment>
        );
      })}
    </View>
  );
}

const si = StyleSheet.create({
  row:        { flexDirection: 'row', alignItems: 'center', flex: 1, justifyContent: 'center' },
  circle:     { width: 28, height: 28, borderRadius: 14, alignItems: 'center', justifyContent: 'center' },
  circleBlue: { backgroundColor: '#2563eb' },
  circleGrey: { backgroundColor: 'rgba(255,255,255,0.3)' },
  line:       { width: 28, height: 2 },
  lineDone:   { backgroundColor: '#2563eb' },
  lineGrey:   { backgroundColor: 'rgba(255,255,255,0.3)' },
  num:        { fontSize: 13, fontWeight: '700', color: '#fff' },
});

// ─── Step 1: Specialty ───────────────────────────────────────────────────────

function Step1({ onSelect }: { onSelect: (s: Specialty) => void }) {
  const cardW = (SW - 48) / 2;
  return (
    <View style={st1.grid}>
      {SPECIALTIES.map(sp => (
        <TouchableOpacity key={sp.name} style={[st1.card, { width: cardW }]} onPress={() => onSelect(sp)}>
          <View style={[st1.iconBox, { backgroundColor: sp.color + '18' }]}>
            <Text style={st1.emoji}>{sp.emoji}</Text>
          </View>
          <Text style={st1.name}>{sp.name}</Text>
        </TouchableOpacity>
      ))}
    </View>
  );
}

const st1 = StyleSheet.create({
  grid:    { flexDirection: 'row', flexWrap: 'wrap', gap: 12, paddingTop: 4 },
  card:    {
    backgroundColor: '#fff', borderRadius: 16, padding: 16, alignItems: 'center',
    shadowColor: '#000', shadowOffset: { width: 0, height: 1 }, shadowOpacity: 0.07, shadowRadius: 6, elevation: 2,
  },
  iconBox: { width: 60, height: 60, borderRadius: 18, alignItems: 'center', justifyContent: 'center', marginBottom: 10 },
  emoji:   { fontSize: 30 },
  name:    { fontSize: 13, fontWeight: '600', color: '#1e293b', textAlign: 'center', lineHeight: 18 },
});

// ─── Step 2: Doctor ──────────────────────────────────────────────────────────

function Step2({ specialty, onSelect }: { specialty: Specialty; onSelect: (name: string) => void }) {
  const docs = DOCTORS[specialty.name] ?? [];
  return (
    <View style={st2.container}>
      {docs.map(doc => (
        <TouchableOpacity
          key={doc.name}
          style={[st2.card, !doc.available && st2.cardOff]}
          onPress={() => doc.available && onSelect(doc.name)}
          disabled={!doc.available}
          activeOpacity={doc.available ? 0.7 : 1}
        >
          <View style={st2.nameRow}>
            <Text style={[st2.name, !doc.available && st2.nameOff]}>{doc.name}</Text>
            <View style={[st2.badge, doc.available ? st2.badgeGreen : st2.badgeGrey]}>
              <Text style={[st2.badgeText, doc.available ? st2.badgeGreenTxt : st2.badgeGreyTxt]}>
                {doc.available ? 'Disponible' : 'No disponible'}
              </Text>
            </View>
          </View>
          <Text style={st2.specialty}>{specialty.name}</Text>
          <View style={st2.meta}>
            <Text style={st2.star}>⭐</Text>
            <Text style={st2.rating}>{doc.rating}</Text>
            <Text style={st2.years}>{doc.years} años de experiencia</Text>
          </View>
        </TouchableOpacity>
      ))}
    </View>
  );
}

const st2 = StyleSheet.create({
  container:    { gap: 12, paddingTop: 4 },
  card:         {
    backgroundColor: '#fff', borderRadius: 16, padding: 16,
    shadowColor: '#000', shadowOffset: { width: 0, height: 1 }, shadowOpacity: 0.07, shadowRadius: 6, elevation: 2,
  },
  cardOff:      { opacity: 0.55 },
  nameRow:      { flexDirection: 'row', alignItems: 'center', flexWrap: 'wrap', gap: 8, marginBottom: 4 },
  name:         { fontSize: 16, fontWeight: '700', color: '#1e293b' },
  nameOff:      { color: '#94a3b8' },
  badge:        { paddingHorizontal: 8, paddingVertical: 3, borderRadius: 6 },
  badgeGreen:   { backgroundColor: '#dcfce7' },
  badgeGrey:    { backgroundColor: '#f1f5f9' },
  badgeText:    { fontSize: 12, fontWeight: '600' },
  badgeGreenTxt:{ color: '#16a34a' },
  badgeGreyTxt: { color: '#94a3b8' },
  specialty:    { fontSize: 13, color: '#64748b', marginBottom: 8 },
  meta:         { flexDirection: 'row', alignItems: 'center', gap: 6 },
  star:         { fontSize: 14 },
  rating:       { fontSize: 14, fontWeight: '700', color: '#1e293b' },
  years:        { fontSize: 13, color: '#64748b' },
});

// ─── Step 3: Date / Time / Location ─────────────────────────────────────────

function Step3({
  specialty, days, selectedDate, onSelectDate,
  selectedTime, onSelectTime, selectedLocation, onSelectLocation, onNext,
}: {
  specialty: Specialty; days: Date[];
  selectedDate: Date | null;   onSelectDate: (d: Date) => void;
  selectedTime: string;        onSelectTime: (t: string) => void;
  selectedLocation: string;    onSelectLocation: (l: string) => void;
  onNext: () => void;
}) {
  const locs = LOCATIONS[specialty.name] ?? ['Clínica Principal'];
  const slotW = (SW - 64) / 4;

  // Group days into rows of 4
  const rows: Date[][] = [];
  for (let i = 0; i < days.length; i += 4) rows.push(days.slice(i, i + 4));

  const canProceed = !!(selectedDate && selectedTime && selectedLocation);

  return (
    <View style={st3.container}>
      <Text style={st3.sectionTitle}>Selecciona el día</Text>
      {rows.map((row, ri) => (
        <View key={ri} style={st3.dateRow}>
          {row.map(day => {
            const isSel = selectedDate?.toDateString() === day.toDateString();
            return (
              <TouchableOpacity
                key={day.toISOString()}
                style={[st3.dayBtn, isSel && st3.dayBtnSel]}
                onPress={() => onSelectDate(day)}
              >
                <Text style={[st3.dayName, isSel && st3.dayTxtSel]}>{DAYS_ES[day.getDay()]}</Text>
                <Text style={[st3.dayNum,  isSel && st3.dayTxtSel]}>{day.getDate()}</Text>
                <Text style={[st3.dayMth,  isSel && st3.dayTxtSel]}>{MONTHS_ES[day.getMonth()]}</Text>
              </TouchableOpacity>
            );
          })}
        </View>
      ))}

      {selectedDate && (
        <>
          <Text style={[st3.sectionTitle, { marginTop: 20 }]}>Selecciona la hora</Text>
          <View style={st3.timeGrid}>
            {TIME_SLOTS.map(t => {
              const unavail = UNAVAILABLE_TIMES.has(t);
              const isSel   = selectedTime === t;
              return (
                <TouchableOpacity
                  key={t}
                  style={[st3.timeBtn, { width: slotW }, isSel && st3.timeSel, unavail && st3.timeOff]}
                  onPress={() => !unavail && onSelectTime(t)}
                  disabled={unavail}
                >
                  <Text style={[st3.timeTxt, isSel && st3.timeSelTxt, unavail && st3.timeOffTxt]}>{t}</Text>
                </TouchableOpacity>
              );
            })}
          </View>
          <Text style={st3.hint}>Los horarios en gris no están disponibles</Text>

          <Text style={[st3.sectionTitle, { marginTop: 20 }]}>Selecciona la ubicación</Text>
          {locs.map(loc => {
            const isSel = selectedLocation === loc;
            return (
              <TouchableOpacity
                key={loc}
                style={[st3.locBtn, isSel && st3.locBtnSel]}
                onPress={() => onSelectLocation(loc)}
              >
                <Ionicons name="location-outline" size={18} color={isSel ? '#2563eb' : '#64748b'} />
                <Text style={[st3.locTxt, isSel && st3.locTxtSel]}>{loc}</Text>
              </TouchableOpacity>
            );
          })}

          <TouchableOpacity
            style={[st3.nextBtn, !canProceed && { opacity: 0.45 }]}
            onPress={onNext}
          >
            <Text style={st3.nextTxt}>Continuar</Text>
          </TouchableOpacity>
        </>
      )}
    </View>
  );
}

const st3 = StyleSheet.create({
  container:   { paddingTop: 4 },
  sectionTitle:{ fontSize: 15, fontWeight: '700', color: '#1e293b', marginBottom: 10 },
  dateRow:     { flexDirection: 'row', gap: 8, marginBottom: 8 },
  dayBtn:      {
    flex: 1, alignItems: 'center', backgroundColor: '#fff', borderRadius: 10,
    paddingVertical: 10,
    shadowColor: '#000', shadowOffset: { width: 0, height: 1 }, shadowOpacity: 0.06, shadowRadius: 4, elevation: 1,
  },
  dayBtnSel:   { backgroundColor: '#2563eb' },
  dayName:     { fontSize: 11, color: '#64748b', marginBottom: 2 },
  dayNum:      { fontSize: 17, fontWeight: 'bold', color: '#1e293b', marginBottom: 2 },
  dayMth:      { fontSize: 11, color: '#94a3b8' },
  dayTxtSel:   { color: '#fff' },
  timeGrid:    { flexDirection: 'row', flexWrap: 'wrap', gap: 8, marginBottom: 6 },
  timeBtn:     {
    alignItems: 'center', backgroundColor: '#fff', borderRadius: 8, paddingVertical: 10,
    shadowColor: '#000', shadowOffset: { width: 0, height: 1 }, shadowOpacity: 0.06, shadowRadius: 4, elevation: 1,
  },
  timeSel:     { backgroundColor: '#2563eb' },
  timeOff:     { backgroundColor: '#f1f5f9' },
  timeTxt:     { fontSize: 13, fontWeight: '600', color: '#1e293b' },
  timeSelTxt:  { color: '#fff' },
  timeOffTxt:  { color: '#cbd5e1' },
  hint:        { fontSize: 11, color: '#94a3b8', marginBottom: 4 },
  locBtn:      {
    flexDirection: 'row', alignItems: 'center', gap: 10, backgroundColor: '#fff',
    borderRadius: 12, padding: 14, marginBottom: 10,
    borderWidth: 1.5, borderColor: '#e2e8f0',
  },
  locBtnSel:   { borderColor: '#2563eb', backgroundColor: '#eff6ff' },
  locTxt:      { fontSize: 14, color: '#64748b', flex: 1 },
  locTxtSel:   { color: '#2563eb', fontWeight: '600' },
  nextBtn:     { backgroundColor: '#2563eb', borderRadius: 12, paddingVertical: 14, alignItems: 'center', marginTop: 16 },
  nextTxt:     { color: '#fff', fontSize: 16, fontWeight: '700' },
});

// ─── Step 4: Confirmation ────────────────────────────────────────────────────

function Step4({
  specialty, doctor, date, time, location, onBack, onConfirm,
}: {
  specialty: Specialty; doctor: string; date: Date;
  time: string; location: string;
  onBack: () => void; onConfirm: () => void;
}) {
  return (
    <View style={st4.container}>
      <View style={st4.card}>
        <View style={st4.bigIcon}>
          <Ionicons name="calendar" size={34} color="#2563eb" />
        </View>
        <Text style={st4.title}>Confirma tu cita</Text>
        <Text style={st4.subtitle}>Revisa los detalles antes de confirmar</Text>

        {/* Doctor */}
        <View style={st4.row}>
          <View style={[st4.icon, { backgroundColor: '#dbeafe' }]}>
            <Ionicons name="person-outline" size={20} color="#2563eb" />
          </View>
          <View style={{ flex: 1 }}>
            <Text style={st4.lbl}>Médico</Text>
            <Text style={st4.val}>{doctor}</Text>
            <Text style={st4.sub}>{specialty.name}</Text>
          </View>
        </View>

        {/* Date */}
        <View style={st4.row}>
          <View style={[st4.icon, { backgroundColor: '#dcfce7' }]}>
            <Ionicons name="calendar-outline" size={20} color="#16a34a" />
          </View>
          <View style={{ flex: 1 }}>
            <Text style={st4.lbl}>Fecha y hora</Text>
            <Text style={st4.val}>{formatFull(date)}</Text>
            <Text style={st4.sub}>{time}</Text>
          </View>
        </View>

        {/* Location */}
        <View style={[st4.row, { borderBottomWidth: 0 }]}>
          <View style={[st4.icon, { backgroundColor: '#f3e8ff' }]}>
            <Ionicons name="location-outline" size={20} color="#7c3aed" />
          </View>
          <View style={{ flex: 1 }}>
            <Text style={st4.lbl}>Ubicación</Text>
            <Text style={st4.val}>{location}</Text>
          </View>
        </View>

        <View style={st4.reminder}>
          <Text style={st4.reminderTxt}>
            <Text style={{ fontWeight: '700' }}>Recordatorio: </Text>
            Por favor llega 15 minutos antes de tu cita. Trae tu documento de identidad y carnet de la EPS.
          </Text>
        </View>
      </View>

      <View style={st4.btnRow}>
        <TouchableOpacity style={st4.backBtn} onPress={onBack}>
          <Text style={st4.backTxt}>Regresar</Text>
        </TouchableOpacity>
        <TouchableOpacity style={st4.confirmBtn} onPress={onConfirm}>
          <Text style={st4.confirmTxt}>Confirmar Cita</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}

const st4 = StyleSheet.create({
  container:  { paddingTop: 4 },
  card:       {
    backgroundColor: '#fff', borderRadius: 20, padding: 20,
    shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.08, shadowRadius: 10, elevation: 3,
  },
  bigIcon:    {
    width: 68, height: 68, borderRadius: 34, backgroundColor: '#eff6ff',
    alignItems: 'center', justifyContent: 'center', alignSelf: 'center', marginBottom: 14,
  },
  title:      { fontSize: 20, fontWeight: 'bold', color: '#1e293b', textAlign: 'center', marginBottom: 4 },
  subtitle:   { fontSize: 14, color: '#64748b', textAlign: 'center', marginBottom: 20 },
  row:        {
    flexDirection: 'row', alignItems: 'flex-start', gap: 14,
    paddingVertical: 14, borderBottomWidth: 1, borderBottomColor: '#f1f5f9',
  },
  icon:       { width: 42, height: 42, borderRadius: 12, alignItems: 'center', justifyContent: 'center' },
  lbl:        { fontSize: 12, color: '#94a3b8', marginBottom: 3 },
  val:        { fontSize: 15, fontWeight: '700', color: '#1e293b' },
  sub:        { fontSize: 13, color: '#64748b', marginTop: 2 },
  reminder:   { backgroundColor: '#eff6ff', borderRadius: 10, padding: 12, marginTop: 16 },
  reminderTxt:{ fontSize: 13, color: '#1e40af', lineHeight: 20 },
  btnRow:     { flexDirection: 'row', gap: 12, marginTop: 20 },
  backBtn:    {
    flex: 1, borderWidth: 1.5, borderColor: '#e2e8f0', borderRadius: 12,
    paddingVertical: 14, alignItems: 'center',
  },
  backTxt:    { fontSize: 15, color: '#475569', fontWeight: '600' },
  confirmBtn: { flex: 2, backgroundColor: '#2563eb', borderRadius: 12, paddingVertical: 14, alignItems: 'center' },
  confirmTxt: { fontSize: 15, color: '#fff', fontWeight: '700' },
});

// ─── Main Screen ─────────────────────────────────────────────────────────────

const STEP_TITLES = [
  'Selecciona la especialidad',
  'Elige tu médico',
  'Fecha y hora',
  'Confirmar cita',
];

const DAYS_AHEAD = getNextDays(14);

export default function BookAppointmentScreen({ navigation }: any) {
  const [step, setStep]             = useState(0);
  const [specialty, setSpecialty]   = useState<Specialty | null>(null);
  const [doctor, setDoctor]         = useState('');
  const [selDate, setSelDate]       = useState<Date | null>(null);
  const [selTime, setSelTime]       = useState('');
  const [selLoc, setSelLoc]         = useState('');
  const { addAppointment }          = useAppContext();

  const handleBack = () => {
    if (step === 0) navigation.goBack();
    else setStep(s => s - 1);
  };

  const handleConfirm = async () => {
    if (!specialty || !selDate) return;
    await addAppointment({
      specialty: specialty.name,
      status: 'Confirmada',
      doctor,
      date: formatShort(selDate),
      time: selTime,
      location: selLoc,
      color: specialty.color,
    });
    navigation.navigate('Main', { screen: 'Citas' });
  };

  return (
    <View style={styles.container}>
      <StatusBar barStyle="light-content" backgroundColor="#1e40af" />

      {/* Header */}
      <LinearGradient colors={['#1e40af', '#0891b2']} style={styles.header}>
        <View style={styles.headerRow}>
          <TouchableOpacity onPress={handleBack} style={styles.backBtn}>
            <Ionicons name="chevron-back" size={20} color="#fff" />
            <Text style={styles.backTxt}>Volver</Text>
          </TouchableOpacity>
          <StepIndicator step={step} />
          <View style={{ width: 70 }} />
        </View>
        <Text style={styles.stepTitle}>{STEP_TITLES[step]}</Text>
      </LinearGradient>

      <ScrollView
        style={styles.body}
        contentContainerStyle={styles.bodyContent}
        showsVerticalScrollIndicator={false}
        keyboardShouldPersistTaps="handled"
      >
        {step === 0 && (
          <Step1 onSelect={s => { setSpecialty(s); setStep(1); }} />
        )}

        {step === 1 && specialty && (
          <Step2
            specialty={specialty}
            onSelect={d => { setDoctor(d); setStep(2); }}
          />
        )}

        {step === 2 && specialty && (
          <Step3
            specialty={specialty}
            days={DAYS_AHEAD}
            selectedDate={selDate}     onSelectDate={setSelDate}
            selectedTime={selTime}     onSelectTime={setSelTime}
            selectedLocation={selLoc}  onSelectLocation={setSelLoc}
            onNext={() => {
              if (!selDate || !selTime || !selLoc) {
                Alert.alert('Completa los datos', 'Selecciona fecha, hora y ubicación para continuar.');
                return;
              }
              setStep(3);
            }}
          />
        )}

        {step === 3 && specialty && selDate && (
          <Step4
            specialty={specialty}
            doctor={doctor}
            date={selDate}
            time={selTime}
            location={selLoc}
            onBack={() => setStep(2)}
            onConfirm={handleConfirm}
          />
        )}

        <View style={{ height: 40 }} />
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container:   { flex: 1, backgroundColor: '#f8fafc' },
  header:      { paddingTop: 52, paddingHorizontal: 20, paddingBottom: 20 },
  headerRow:   { flexDirection: 'row', alignItems: 'center', marginBottom: 14 },
  backBtn:     { flexDirection: 'row', alignItems: 'center', gap: 2, width: 70 },
  backTxt:     { color: '#fff', fontSize: 15, fontWeight: '600' },
  stepTitle:   { fontSize: 22, fontWeight: 'bold', color: '#fff' },
  body:        { flex: 1 },
  bodyContent: { padding: 16 },
});
