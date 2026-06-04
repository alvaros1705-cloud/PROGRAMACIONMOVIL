import React, { useState, useMemo, useEffect, useRef } from 'react';
import {
  View, Text, StyleSheet, ScrollView,
  TouchableOpacity, StatusBar, Alert, Animated, Easing,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons, MaterialCommunityIcons } from '@expo/vector-icons';
import { useAuth } from '@medical-app/shared/hooks/useAuth';
import { useAppContext } from '../../src/context/AppContext';

export default function DashboardScreen({ navigation }: any) {
  const { session } = useAuth();
  const { appointments, exams, medications } = useAppContext();
  const [takenIds, setTakenIds] = useState<Set<string>>(new Set());

  // ── Entrance animations ──────────────────────────────────────────────────
  const headerAnim = useRef(new Animated.Value(0)).current;
  const cardsAnim  = useRef(new Animated.Value(0)).current;
  const quickAnim  = useRef(new Animated.Value(0)).current;
  const remindAnim = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.stagger(120, [
      Animated.timing(headerAnim, { toValue: 1, duration: 400, easing: Easing.out(Easing.quad), useNativeDriver: true }),
      Animated.timing(cardsAnim,  { toValue: 1, duration: 400, easing: Easing.out(Easing.quad), useNativeDriver: true }),
      Animated.timing(quickAnim,  { toValue: 1, duration: 400, easing: Easing.out(Easing.quad), useNativeDriver: true }),
      Animated.timing(remindAnim, { toValue: 1, duration: 400, easing: Easing.out(Easing.quad), useNativeDriver: true }),
    ]).start();
  }, []);

  const fadeSlide = (anim: Animated.Value) => ({
    opacity: anim,
    transform: [{ translateY: anim.interpolate({ inputRange: [0, 1], outputRange: [20, 0] }) }],
  });

  // Upcoming appointments (max 2)
  const upcomingApts = appointments
    .filter(a => a.status === 'Confirmada' || a.status === 'Pendiente')
    .slice(0, 2);

  // Real counts
  const newExamsCount   = exams.filter(e => e.status === 'Disponible').length;
  const activeMedsCount = medications.filter(m => m.status === 'Activo').length;

  // Derive today's reminders from active medications
  const reminders = useMemo(() =>
    medications
      .filter(m => m.status === 'Activo')
      .flatMap(m =>
        m.hours.split(',').map((h, idx) => ({
          id: `${m.id}-${idx}`,
          name: m.name,
          dose: m.description || 'Tomar según indicación',
          time: h.trim(),
          taken: takenIds.has(`${m.id}-${idx}`),
        }))
      ),
    [medications, takenIds]
  );

  const handleMarcar = (id: string, name: string) => {
    Alert.alert(
      'Marcar como tomado',
      `¿Confirmás que tomaste ${name}?`,
      [
        { text: 'Cancelar', style: 'cancel' },
        { text: 'Confirmar', onPress: () => setTakenIds(prev => new Set([...prev, id])) },
      ]
    );
  };

  const email    = session?.user?.email ?? '';
  const name     = session?.user?.user_metadata?.full_name ?? email.split('@')[0];
  const initials = name.split(' ').map((n: string) => n[0]).join('').toUpperCase().slice(0, 2);
  const eps      = session?.user?.user_metadata?.eps ?? 'EPS Sura';

  return (
    <View style={styles.container}>
      <StatusBar barStyle="light-content" backgroundColor="#1e40af" />
      <ScrollView showsVerticalScrollIndicator={false}>

        {/* Header */}
        <LinearGradient colors={['#1e40af', '#0891b2']} style={styles.header}>
          <View style={styles.headerTop}>
            <View>
              <Text style={styles.welcomeSmall}>Bienvenido de nuevo</Text>
              <Text style={styles.welcomeName}>{name}</Text>
            </View>
            <View style={styles.headerRight}>
              <TouchableOpacity style={styles.bellBtn}>
                <Ionicons name="notifications-outline" size={24} color="#fff" />
                <View style={styles.badge}><Text style={styles.badgeText}>3</Text></View>
              </TouchableOpacity>
              <View style={styles.avatar}>
                <Text style={styles.avatarText}>{initials}</Text>
              </View>
            </View>
          </View>
          <View style={styles.epsChip}>
            <Text style={styles.epsChipText}>EPS: {eps}</Text>
          </View>

          {/* Nueva cita card */}
          <View style={styles.newAppCard}>
            <View>
              <Text style={styles.newAppTitle}>¿Necesitas atención médica?</Text>
              <Text style={styles.newAppSub}>Agenda tu cita en segundos</Text>
            </View>
            <TouchableOpacity style={styles.plusBtn} onPress={() => navigation.navigate('BookAppointment')}>
              <Ionicons name="add" size={28} color="#fff" />
            </TouchableOpacity>
          </View>
        </LinearGradient>

        <View style={styles.body}>

          {/* Próximas Citas */}
          <Animated.View style={fadeSlide(cardsAnim)}>
          <View style={styles.sectionHeader}>
            <Text style={styles.sectionTitle}>Próximas Citas</Text>
            <TouchableOpacity onPress={() => navigation.navigate('Citas')}>
              <Text style={styles.sectionLink}>Ver todas</Text>
            </TouchableOpacity>
          </View>

          {upcomingApts.map((apt) => (
            <TouchableOpacity key={apt.id} style={styles.appointmentCard}>
              <View style={[styles.cardBorder, { backgroundColor: apt.color }]} />
              <View style={styles.cardContent}>
                <View style={styles.cardTags}>
                  <View style={[styles.specialtyTag, { backgroundColor: apt.color + '20' }]}>
                    <Text style={[styles.specialtyText, { color: apt.color }]}>{apt.specialty}</Text>
                  </View>
                  <View style={[styles.statusTag, {
                    backgroundColor: apt.status === 'Confirmada' ? '#dcfce7' : '#fff7ed'
                  }]}>
                    <Text style={[styles.statusText, {
                      color: apt.status === 'Confirmada' ? '#16a34a' : '#ea580c'
                    }]}>{apt.status}</Text>
                  </View>
                </View>
                <Text style={styles.doctorName}>{apt.doctor}</Text>
                <View style={styles.cardMeta}>
                  <Ionicons name="calendar-outline" size={13} color="#64748b" />
                  <Text style={styles.metaText}>{apt.date}</Text>
                  <Ionicons name="time-outline" size={13} color="#64748b" style={{ marginLeft: 8 }} />
                  <Text style={styles.metaText}>{apt.time}</Text>
                </View>
                <View style={styles.cardMeta}>
                  <Ionicons name="location-outline" size={13} color="#64748b" />
                  <Text style={styles.metaText}>{apt.location}</Text>
                </View>
              </View>
              <Ionicons name="chevron-forward" size={18} color="#94a3b8" />
            </TouchableOpacity>
          ))}
          </Animated.View>

          {/* Accesos Rápidos */}
          <Animated.View style={fadeSlide(quickAnim)}>
          <Text style={styles.sectionTitle}>Accesos Rápidos</Text>
          <View style={styles.quickGrid}>
            <TouchableOpacity style={styles.quickCard} onPress={() => navigation.navigate('Exámenes')}>
              <View style={[styles.quickIcon, { backgroundColor: '#dcfce7' }]}>
                <Ionicons name="document-text-outline" size={26} color="#16a34a" />
              </View>
              <Text style={styles.quickTitle}>Exámenes</Text>
              <Text style={styles.quickSub}>Ver resultados</Text>
              {newExamsCount > 0 ? (
                <View style={styles.quickBadge}>
                  <Text style={styles.quickBadgeText}>{newExamsCount} disponibles</Text>
                </View>
              ) : (
                <Text style={[styles.quickBadgeBlue, { color: '#94a3b8' }]}>Sin resultados</Text>
              )}
            </TouchableOpacity>

            <TouchableOpacity style={styles.quickCard} onPress={() => navigation.navigate('Medications')}>
              <View style={[styles.quickIcon, { backgroundColor: '#dbeafe' }]}>
                <MaterialCommunityIcons name="pill" size={26} color="#2563eb" />
              </View>
              <Text style={styles.quickTitle}>Medicamentos</Text>
              <Text style={styles.quickSub}>Recetas activas</Text>
              {activeMedsCount > 0 ? (
                <Text style={styles.quickBadgeBlue}>{activeMedsCount} recetas</Text>
              ) : (
                <Text style={[styles.quickBadgeBlue, { color: '#94a3b8' }]}>Sin recetas</Text>
              )}
            </TouchableOpacity>
          </View>
          </Animated.View>

          {/* Recordatorios */}
          <Animated.View style={fadeSlide(remindAnim)}>
          <Text style={styles.sectionTitle}>Recordatorios de Hoy</Text>
          {reminders.length === 0 ? (
            <View style={styles.reminderEmpty}>
              <MaterialCommunityIcons name="pill-off" size={32} color="#cbd5e1" />
              <Text style={styles.reminderEmptyText}>No tienes medicamentos registrados</Text>
            </View>
          ) : (
            reminders.map((r) => (
              <View key={r.id} style={[styles.reminderCard, r.taken && { opacity: 0.6 }]}>
                <View style={[styles.reminderIcon, r.taken && { backgroundColor: '#dcfce7' }]}>
                  {r.taken
                    ? <Ionicons name="checkmark-circle" size={22} color="#16a34a" />
                    : <MaterialCommunityIcons name="pill" size={22} color="#f97316" />
                  }
                </View>
                <View style={styles.reminderInfo}>
                  <Text style={[styles.reminderName, r.taken && { textDecorationLine: 'line-through', color: '#94a3b8' }]}>
                    {r.name}
                  </Text>
                  <Text style={styles.reminderDose}>{r.dose}</Text>
                  <Text style={styles.reminderTime}>Hora: {r.time}</Text>
                </View>
                {!r.taken ? (
                  <TouchableOpacity style={styles.marcarBtn} onPress={() => handleMarcar(r.id, r.name)}>
                    <Text style={styles.marcarText}>Marcar</Text>
                  </TouchableOpacity>
                ) : (
                  <View style={styles.tomadoBadge}>
                    <Text style={styles.tomadoText}>✓ Tomado</Text>
                  </View>
                )}
              </View>
            ))
          )}

          <View style={{ height: 16 }} />
          </Animated.View>
        </View>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f8fafc' },
  header: { paddingTop: 52, paddingHorizontal: 20, paddingBottom: 24 },
  headerTop: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 12 },
  welcomeSmall: { fontSize: 13, color: '#bfdbfe' },
  welcomeName: { fontSize: 20, fontWeight: 'bold', color: '#fff' },
  headerRight: { flexDirection: 'row', alignItems: 'center', gap: 12 },
  bellBtn: { position: 'relative' },
  badge: {
    position: 'absolute', top: -4, right: -4,
    backgroundColor: '#ef4444', borderRadius: 8, width: 16, height: 16,
    alignItems: 'center', justifyContent: 'center',
  },
  badgeText: { fontSize: 10, color: '#fff', fontWeight: 'bold' },
  avatar: {
    width: 40, height: 40, borderRadius: 20,
    backgroundColor: '#1e3a8a', alignItems: 'center', justifyContent: 'center',
    borderWidth: 2, borderColor: 'rgba(255,255,255,0.3)',
  },
  avatarText: { fontSize: 15, fontWeight: 'bold', color: '#fff' },
  epsChip: {
    alignSelf: 'flex-start', backgroundColor: 'rgba(255,255,255,0.2)',
    paddingHorizontal: 12, paddingVertical: 4, borderRadius: 20, marginBottom: 16,
  },
  epsChipText: { color: '#fff', fontSize: 13, fontWeight: '500' },
  newAppCard: {
    backgroundColor: 'rgba(255,255,255,0.15)', borderRadius: 14,
    padding: 16, flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between',
  },
  newAppTitle: { fontSize: 15, fontWeight: '700', color: '#fff', marginBottom: 2 },
  newAppSub: { fontSize: 13, color: '#bfdbfe' },
  plusBtn: {
    width: 44, height: 44, borderRadius: 22,
    backgroundColor: '#2563eb', alignItems: 'center', justifyContent: 'center',
  },
  body: { paddingHorizontal: 16, paddingTop: 20 },
  sectionHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 },
  sectionTitle: { fontSize: 17, fontWeight: '700', color: '#1e293b', marginBottom: 12 },
  sectionLink: { fontSize: 14, color: '#2563eb', fontWeight: '600' },
  appointmentCard: {
    flexDirection: 'row', alignItems: 'center',
    backgroundColor: '#fff', borderRadius: 14, marginBottom: 12,
    overflow: 'hidden',
    shadowColor: '#000', shadowOffset: { width: 0, height: 1 }, shadowOpacity: 0.06, shadowRadius: 6, elevation: 2,
  },
  cardBorder: { width: 4, alignSelf: 'stretch' },
  cardContent: { flex: 1, padding: 14 },
  cardTags: { flexDirection: 'row', gap: 8, marginBottom: 6 },
  specialtyTag: { paddingHorizontal: 8, paddingVertical: 3, borderRadius: 6 },
  specialtyText: { fontSize: 12, fontWeight: '600' },
  statusTag: { paddingHorizontal: 8, paddingVertical: 3, borderRadius: 6 },
  statusText: { fontSize: 12, fontWeight: '600' },
  doctorName: { fontSize: 15, fontWeight: '700', color: '#1e293b', marginBottom: 6 },
  cardMeta: { flexDirection: 'row', alignItems: 'center', gap: 4, marginBottom: 3 },
  metaText: { fontSize: 12, color: '#64748b' },
  quickGrid: { flexDirection: 'row', gap: 12, marginBottom: 20 },
  quickCard: {
    flex: 1, backgroundColor: '#fff', borderRadius: 14, padding: 16,
    shadowColor: '#000', shadowOffset: { width: 0, height: 1 }, shadowOpacity: 0.06, shadowRadius: 6, elevation: 2,
  },
  quickIcon: { width: 48, height: 48, borderRadius: 12, alignItems: 'center', justifyContent: 'center', marginBottom: 10 },
  quickTitle: { fontSize: 14, fontWeight: '700', color: '#1e293b', marginBottom: 2 },
  quickSub: { fontSize: 12, color: '#64748b', marginBottom: 8 },
  quickBadge: { backgroundColor: '#ef4444', paddingHorizontal: 8, paddingVertical: 3, borderRadius: 8, alignSelf: 'flex-start' },
  quickBadgeText: { fontSize: 11, color: '#fff', fontWeight: '700' },
  quickBadgeBlue: { fontSize: 12, color: '#2563eb', fontWeight: '600' },
  reminderCard: {
    flexDirection: 'row', alignItems: 'center',
    backgroundColor: '#fff', borderRadius: 14, padding: 14, marginBottom: 10,
    borderLeftWidth: 4, borderLeftColor: '#f97316',
    shadowColor: '#000', shadowOffset: { width: 0, height: 1 }, shadowOpacity: 0.06, shadowRadius: 6, elevation: 2,
  },
  reminderIcon: {
    width: 44, height: 44, borderRadius: 12,
    backgroundColor: '#fff7ed', alignItems: 'center', justifyContent: 'center', marginRight: 12,
  },
  reminderInfo: { flex: 1 },
  reminderName: { fontSize: 14, fontWeight: '700', color: '#1e293b', marginBottom: 2 },
  reminderDose: { fontSize: 13, color: '#64748b' },
  reminderTime: { fontSize: 12, color: '#f97316', fontWeight: '600', marginTop: 2 },
  marcarBtn: { borderWidth: 1.5, borderColor: '#f97316', borderRadius: 8, paddingHorizontal: 12, paddingVertical: 6 },
  marcarText: { fontSize: 13, color: '#f97316', fontWeight: '600' },
  tomadoBadge: { backgroundColor: '#dcfce7', borderRadius: 8, paddingHorizontal: 10, paddingVertical: 6 },
  tomadoText: { fontSize: 12, color: '#16a34a', fontWeight: '600' },
  reminderEmpty: { alignItems: 'center', paddingVertical: 24, gap: 8 },
  reminderEmptyText: { fontSize: 14, color: '#94a3b8', textAlign: 'center' },
});
