import React, { useState, useEffect } from 'react';
import {
  View, Text, StyleSheet, ScrollView,
  TouchableOpacity, StatusBar, Switch, Alert,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons, MaterialIcons, MaterialCommunityIcons } from '@expo/vector-icons';
import { useAuth } from '@medical-app/shared/hooks/useAuth';
import { useAppContext } from '../../src/context/AppContext';
import { fetchProfile, Profile } from '../../src/lib/db';

// ─── Reusable row with icon + label + value + chevron ────────────────────────

function InfoRow({
  icon, iconBg, label, value, onPress, last = false,
}: {
  icon: React.ReactNode; iconBg: string;
  label: string; value: string;
  onPress?: () => void; last?: boolean;
}) {
  return (
    <TouchableOpacity
      style={[styles.row, last && styles.rowLast]}
      onPress={onPress ?? (() => Alert.alert(label, 'Edición próximamente disponible.'))}
      activeOpacity={0.65}
    >
      <View style={[styles.rowIcon, { backgroundColor: iconBg }]}>{icon}</View>
      <View style={styles.rowText}>
        <Text style={styles.rowLabel}>{label}</Text>
        <Text style={styles.rowValue}>{value}</Text>
      </View>
      <Ionicons name="chevron-forward" size={16} color="#cbd5e1" />
    </TouchableOpacity>
  );
}

// ─── Main Screen ─────────────────────────────────────────────────────────────

export default function ProfileScreen() {
  const { session, signOut }        = useAuth();
  const { appointments, exams, medications } = useAppContext();
  const [profile, setProfile]       = useState<Profile | null>(null);
  const [notifEnabled, setNotifEnabled] = useState(true);

  useEffect(() => {
    if (session?.user?.id) {
      fetchProfile(session.user.id).then(setProfile);
    }
  }, [session?.user?.id]);

  const email    = session?.user?.email ?? '';
  const name     = profile?.full_name ?? session?.user?.user_metadata?.full_name ?? email.split('@')[0];
  const phone    = profile?.phone ?? session?.user?.user_metadata?.phone ?? 'No registrado';
  const eps      = profile?.eps  ?? session?.user?.user_metadata?.eps  ?? 'EPS Sura';
  const bloodType = profile?.blood_type ?? 'O+';
  const allergies = (profile?.allergies && profile.allergies.length > 0)
    ? profile.allergies
    : ['Sin alergias registradas'];
  const initials = name.split(' ').map((n: string) => n[0]).join('').toUpperCase().slice(0, 2);

  const citasCount   = appointments.length;
  const examCount    = exams.length;
  const recetasCount = medications.filter(m => m.status === 'Activo').length;

  const handleLogout = () => {
    Alert.alert(
      'Cerrar sesión',
      '¿Estás seguro que deseas salir de tu cuenta?',
      [
        { text: 'Cancelar', style: 'cancel' },
        { text: 'Salir', style: 'destructive', onPress: signOut },
      ]
    );
  };

  return (
    <View style={styles.container}>
      <StatusBar barStyle="light-content" backgroundColor="#7c3aed" />
      <ScrollView showsVerticalScrollIndicator={false}>

        {/* ── Gradient Header ── */}
        <LinearGradient colors={['#7c3aed', '#ec4899']} style={styles.header}>
          <View style={styles.avatarWrapper}>
            <View style={styles.avatar}>
              <Text style={styles.avatarText}>{initials}</Text>
            </View>
            <TouchableOpacity
              style={styles.cameraBtn}
              onPress={() => Alert.alert('Foto de perfil', 'Cambio de foto próximamente.')}
            >
              <Ionicons name="camera" size={12} color="#fff" />
            </TouchableOpacity>
          </View>
          <Text style={styles.headerName}>{name}</Text>
          <Text style={styles.headerEmail}>{email}</Text>
          <View style={styles.roleBadge}>
            <Text style={styles.roleText}>Paciente</Text>
          </View>
        </LinearGradient>

        <View style={styles.body}>

          {/* ── Información Personal ── */}
          <View style={styles.section}>
            <View style={styles.sectionHeaderRow}>
              <Text style={styles.sectionTitle}>Información Personal</Text>
              <TouchableOpacity
                onPress={() => Alert.alert('Editar perfil', 'Formulario de edición próximamente.')}
              >
                <MaterialIcons name="edit" size={20} color="#7c3aed" />
              </TouchableOpacity>
            </View>

            <InfoRow
              icon={<Ionicons name="person-outline" size={18} color="#7c3aed" />}
              iconBg="#f3e8ff"
              label="Nombre completo"
              value={name}
            />
            <InfoRow
              icon={<MaterialIcons name="email" size={18} color="#2563eb" />}
              iconBg="#dbeafe"
              label="Correo electrónico"
              value={email}
            />
            <InfoRow
              icon={<Ionicons name="call-outline" size={18} color="#16a34a" />}
              iconBg="#dcfce7"
              label="Teléfono"
              value={phone}
            />
            <InfoRow
              icon={<Ionicons name="calendar-outline" size={18} color="#f97316" />}
              iconBg="#fff7ed"
              label="Fecha de nacimiento"
              value="15 de Marzo, 1990"
              last
            />
          </View>

          {/* ── Información Médica ── */}
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Información Médica</Text>

            <InfoRow
              icon={<MaterialCommunityIcons name="office-building-outline" size={18} color="#0891b2" />}
              iconBg="#cffafe"
              label="EPS"
              value={eps}
            />
            <InfoRow
              icon={<Ionicons name="water-outline" size={18} color="#dc2626" />}
              iconBg="#fee2e2"
              label="Tipo de sangre"
              value={bloodType}
              last
            />

            {/* Alergias — chips */}
            <View style={styles.allergyBlock}>
              <Text style={styles.allergyLabel}>Alergias conocidas</Text>
              <View style={styles.allergyChips}>
                {allergies.map(a => (
                  <View key={a} style={styles.allergyChip}>
                    <Text style={styles.allergyChipTxt}>{a}</Text>
                  </View>
                ))}
                <TouchableOpacity
                  style={styles.allergyAdd}
                  onPress={() => Alert.alert('Agregar alergia', 'Próximamente disponible.')}
                >
                  <Ionicons name="add" size={14} color="#7c3aed" />
                </TouchableOpacity>
              </View>
            </View>
          </View>

          {/* ── Configuración ── */}
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Configuración</Text>

            {/* Notifications toggle */}
            <View style={[styles.row, styles.rowToggle]}>
              <View style={[styles.rowIcon, { backgroundColor: '#fef3c7' }]}>
                <Ionicons name="notifications-outline" size={18} color="#d97706" />
              </View>
              <View style={styles.rowText}>
                <Text style={styles.rowValue}>Notificaciones</Text>
                <Text style={styles.rowLabel}>Recordatorios de citas y medicamentos</Text>
              </View>
              <Switch
                value={notifEnabled}
                onValueChange={v => {
                  setNotifEnabled(v);
                  Alert.alert(
                    v ? 'Notificaciones activadas' : 'Notificaciones desactivadas',
                    v
                      ? 'Recibirás recordatorios de citas y medicamentos.'
                      : 'No recibirás notificaciones.'
                  );
                }}
                trackColor={{ false: '#e2e8f0', true: '#2563eb' }}
                thumbColor="#fff"
              />
            </View>

            {/* Change password */}
            <TouchableOpacity
              style={[styles.row, styles.rowLast]}
              onPress={() => Alert.alert('Cambiar contraseña', 'Se enviará un correo a ' + email + ' con instrucciones para cambiar tu contraseña.')}
              activeOpacity={0.65}
            >
              <View style={[styles.rowIcon, { backgroundColor: '#fee2e2' }]}>
                <Ionicons name="lock-closed-outline" size={18} color="#dc2626" />
              </View>
              <View style={styles.rowText}>
                <Text style={styles.rowValue}>Cambiar contraseña</Text>
                <Text style={styles.rowLabel}>Actualiza tu contraseña</Text>
              </View>
              <Ionicons name="chevron-forward" size={16} color="#cbd5e1" />
            </TouchableOpacity>
          </View>

          {/* ── Estadísticas ── */}
          <View style={[styles.section, styles.statsSection]}>
            <Text style={styles.sectionTitle}>Estadísticas</Text>
            <View style={styles.statsRow}>
              <View style={styles.statItem}>
                <Text style={[styles.statNum, { color: '#7c3aed' }]}>{citasCount}</Text>
                <Text style={styles.statLbl}>Citas</Text>
              </View>
              <View style={styles.statDivider} />
              <View style={styles.statItem}>
                <Text style={[styles.statNum, { color: '#16a34a' }]}>{examCount}</Text>
                <Text style={styles.statLbl}>Exámenes</Text>
              </View>
              <View style={styles.statDivider} />
              <View style={styles.statItem}>
                <Text style={[styles.statNum, { color: '#2563eb' }]}>{recetasCount}</Text>
                <Text style={styles.statLbl}>Recetas</Text>
              </View>
            </View>
          </View>

          {/* ── Logout ── */}
          <TouchableOpacity style={styles.logoutBtn} onPress={handleLogout}>
            <Ionicons name="log-out-outline" size={20} color="#dc2626" />
            <Text style={styles.logoutTxt}>Cerrar Sesión</Text>
          </TouchableOpacity>

          <View style={{ height: 32 }} />
        </View>
      </ScrollView>
    </View>
  );
}

// ─── Styles ───────────────────────────────────────────────────────────────────

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f8fafc' },

  // Header
  header:      { paddingTop: 60, paddingBottom: 32, alignItems: 'center' },
  avatarWrapper: { position: 'relative', marginBottom: 14 },
  avatar:      {
    width: 84, height: 84, borderRadius: 42,
    backgroundColor: '#4c1d95',
    alignItems: 'center', justifyContent: 'center',
    borderWidth: 3, borderColor: 'rgba(255,255,255,0.35)',
  },
  avatarText:  { fontSize: 30, fontWeight: 'bold', color: '#fff' },
  cameraBtn:   {
    position: 'absolute', bottom: 0, right: 2,
    width: 28, height: 28, borderRadius: 14,
    backgroundColor: '#7c3aed', alignItems: 'center', justifyContent: 'center',
    borderWidth: 2.5, borderColor: '#fff',
  },
  headerName:  { fontSize: 22, fontWeight: 'bold', color: '#fff', marginBottom: 4 },
  headerEmail: { fontSize: 13, color: 'rgba(255,255,255,0.78)', marginBottom: 12 },
  roleBadge:   {
    backgroundColor: 'rgba(255,255,255,0.22)', paddingHorizontal: 18,
    paddingVertical: 5, borderRadius: 20,
  },
  roleText:    { color: '#fff', fontSize: 13, fontWeight: '600' },

  // Body
  body: { padding: 16 },

  // Section card
  section:       {
    backgroundColor: '#fff', borderRadius: 18, marginBottom: 16, padding: 16,
    shadowColor: '#000', shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.07, shadowRadius: 6, elevation: 2,
  },
  statsSection:  { paddingBottom: 20 },
  sectionHeaderRow: {
    flexDirection: 'row', justifyContent: 'space-between',
    alignItems: 'center', marginBottom: 12,
  },
  sectionTitle:  { fontSize: 16, fontWeight: '700', color: '#1e293b', marginBottom: 12 },

  // Row
  row:           {
    flexDirection: 'row', alignItems: 'center',
    paddingVertical: 11, borderBottomWidth: 1, borderBottomColor: '#f1f5f9',
  },
  rowLast:       { borderBottomWidth: 0 },
  rowToggle:     { borderBottomWidth: 1, borderBottomColor: '#f1f5f9' },
  rowIcon:       {
    width: 38, height: 38, borderRadius: 11,
    alignItems: 'center', justifyContent: 'center', marginRight: 12,
  },
  rowText:       { flex: 1 },
  rowLabel:      { fontSize: 12, color: '#94a3b8', marginTop: 2 },
  rowValue:      { fontSize: 14, fontWeight: '600', color: '#1e293b' },

  // Allergies
  allergyBlock:  { paddingTop: 12 },
  allergyLabel:  { fontSize: 13, color: '#94a3b8', marginBottom: 8 },
  allergyChips:  { flexDirection: 'row', flexWrap: 'wrap', gap: 8 },
  allergyChip:   {
    backgroundColor: '#f1f5f9', paddingHorizontal: 12, paddingVertical: 5,
    borderRadius: 20, borderWidth: 1, borderColor: '#e2e8f0',
  },
  allergyChipTxt:{ fontSize: 13, color: '#475569', fontWeight: '500' },
  allergyAdd:    {
    width: 28, height: 28, borderRadius: 14,
    backgroundColor: '#f3e8ff', alignItems: 'center', justifyContent: 'center',
    borderWidth: 1, borderColor: '#e9d5ff',
  },

  // Stats
  statsRow:     { flexDirection: 'row', alignItems: 'center', marginTop: 4 },
  statItem:     { flex: 1, alignItems: 'center', paddingVertical: 8 },
  statNum:      { fontSize: 28, fontWeight: 'bold', marginBottom: 4 },
  statLbl:      { fontSize: 13, color: '#64748b', fontWeight: '500' },
  statDivider:  { width: 1, height: 44, backgroundColor: '#f1f5f9' },

  // Logout
  logoutBtn:    {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 8,
    backgroundColor: '#fff', borderRadius: 14, paddingVertical: 15,
    borderWidth: 1.5, borderColor: '#fecaca',
    shadowColor: '#000', shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.06, shadowRadius: 4, elevation: 2,
  },
  logoutTxt:    { fontSize: 16, color: '#dc2626', fontWeight: '700' },
});
