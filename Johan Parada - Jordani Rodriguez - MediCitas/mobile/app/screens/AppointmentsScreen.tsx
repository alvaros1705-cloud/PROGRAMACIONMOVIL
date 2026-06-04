import React, { useState } from 'react';
import {
  View, Text, StyleSheet, ScrollView, TouchableOpacity,
  TextInput, StatusBar, Alert,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons } from '@expo/vector-icons';
import { useAppContext, Appointment } from '../../src/context/AppContext';

const FILTERS = ['Todas', 'Próximas', 'Completadas', 'Canceladas'];

function filterApts(apts: Appointment[], filter: string, search: string) {
  return apts.filter(a => {
    const matchSearch =
      a.doctor.toLowerCase().includes(search.toLowerCase()) ||
      a.specialty.toLowerCase().includes(search.toLowerCase());
    let matchFilter = true;
    if (filter === 'Próximas')    matchFilter = a.status === 'Confirmada' || a.status === 'Pendiente';
    if (filter === 'Completadas') matchFilter = a.status === 'Completada';
    if (filter === 'Canceladas')  matchFilter = a.status === 'Cancelada';
    return matchSearch && matchFilter;
  });
}

const STATUS_STYLE: Record<string, { bg: string; text: string }> = {
  Confirmada: { bg: '#dcfce7', text: '#16a34a' },
  Pendiente:  { bg: '#fff7ed', text: '#ea580c' },
  Completada: { bg: '#dbeafe', text: '#2563eb' },
  Cancelada:  { bg: '#fee2e2', text: '#dc2626' },
};

export default function AppointmentsScreen({ navigation }: any) {
  const { appointments, cancelAppointment, showToast } = useAppContext();
  const [activeFilter, setActiveFilter] = useState('Todas');
  const [search, setSearch] = useState('');

  const displayed = filterApts(appointments, activeFilter, search);

  const handleCancel = (apt: Appointment) => {
    Alert.alert(
      'Cancelar cita',
      `¿Estás seguro de cancelar tu cita con ${apt.doctor}?`,
      [
        { text: 'No', style: 'cancel' },
        {
          text: 'Sí, cancelar',
          style: 'destructive',
          onPress: () => cancelAppointment(apt.id),
        },
      ]
    );
  };

  const handleDetails = (apt: Appointment) => {
    Alert.alert(
      apt.specialty,
      `Médico: ${apt.doctor}\nFecha: ${apt.date}\nHora: ${apt.time}\nUbicación: ${apt.location}\nEstado: ${apt.status}`,
      [{ text: 'Cerrar' }]
    );
  };

  return (
    <View style={styles.container}>
      <StatusBar barStyle="light-content" backgroundColor="#1e40af" />

      {/* Header */}
      <LinearGradient colors={['#1e40af', '#0891b2']} style={styles.header}>
        <View style={styles.headerTop}>
          <Text style={styles.headerTitle}>Mis Citas</Text>
          <TouchableOpacity
            style={styles.newBtn}
            onPress={() => navigation.navigate('BookAppointment')}
          >
            <Ionicons name="add" size={16} color="#2563eb" />
            <Text style={styles.newBtnTxt}>Nueva</Text>
          </TouchableOpacity>
        </View>
        <View style={styles.searchRow}>
          <Ionicons name="search-outline" size={17} color="#94a3b8" style={{ marginRight: 8 }} />
          <TextInput
            style={styles.searchInput}
            placeholder="Buscar citas..."
            placeholderTextColor="#94a3b8"
            value={search}
            onChangeText={setSearch}
          />
          {search.length > 0 && (
            <TouchableOpacity onPress={() => setSearch('')}>
              <Ionicons name="close-circle" size={18} color="#cbd5e1" />
            </TouchableOpacity>
          )}
        </View>
      </LinearGradient>

      {/* Filter tabs */}
      <View style={styles.tabsWrapper}>
        <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.tabs}>
          {FILTERS.map(f => (
            <TouchableOpacity
              key={f}
              style={[styles.tab, activeFilter === f && styles.tabActive]}
              onPress={() => setActiveFilter(f)}
            >
              <Text style={[styles.tabTxt, activeFilter === f && styles.tabTxtActive]}>{f}</Text>
            </TouchableOpacity>
          ))}
        </ScrollView>
      </View>

      {/* List */}
      <ScrollView
        style={styles.list}
        contentContainerStyle={styles.listContent}
        showsVerticalScrollIndicator={false}
      >
        {displayed.length === 0 ? (
          <View style={styles.empty}>
            <Ionicons name="calendar-outline" size={56} color="#cbd5e1" />
            <Text style={styles.emptyTitle}>No hay citas</Text>
            <Text style={styles.emptySub}>
              {search ? 'No se encontraron resultados para tu búsqueda.' : 'No tienes citas en esta categoría.'}
            </Text>
            <TouchableOpacity
              style={styles.emptyBtn}
              onPress={() => navigation.navigate('BookAppointment')}
            >
              <Text style={styles.emptyBtnTxt}>+ Agendar cita</Text>
            </TouchableOpacity>
          </View>
        ) : (
          displayed.map(apt => {
            const st = STATUS_STYLE[apt.status] ?? STATUS_STYLE.Pendiente;
            const canCancel = apt.status === 'Confirmada' || apt.status === 'Pendiente';
            return (
              <View key={apt.id} style={styles.card}>
                <View style={[styles.cardBorder, { backgroundColor: apt.color }]} />
                <View style={styles.cardBody}>
                  {/* Tags */}
                  <View style={styles.tagsRow}>
                    <View style={[styles.specialtyTag, { backgroundColor: apt.color + '18' }]}>
                      <Text style={[styles.specialtyTxt, { color: apt.color }]}>{apt.specialty}</Text>
                    </View>
                    <View style={[styles.statusTag, { backgroundColor: st.bg }]}>
                      <Text style={[styles.statusTxt, { color: st.text }]}>{apt.status}</Text>
                    </View>
                  </View>

                  <Text style={styles.doctor}>{apt.doctor}</Text>

                  <View style={styles.metaRow}>
                    <Ionicons name="calendar-outline" size={13} color="#64748b" />
                    <Text style={styles.metaTxt}>{apt.date}</Text>
                    <Ionicons name="time-outline" size={13} color="#64748b" style={{ marginLeft: 10 }} />
                    <Text style={styles.metaTxt}>{apt.time}</Text>
                  </View>
                  <View style={styles.metaRow}>
                    <Ionicons name="location-outline" size={13} color="#64748b" />
                    <Text style={styles.metaTxt}>{apt.location}</Text>
                  </View>

                  {/* Action buttons */}
                  <View style={styles.actionsRow}>
                    <TouchableOpacity style={styles.detailsBtn} onPress={() => handleDetails(apt)}>
                      <Text style={styles.detailsTxt}>Ver Detalles</Text>
                    </TouchableOpacity>
                    {canCancel && (
                      <TouchableOpacity style={styles.cancelBtn} onPress={() => handleCancel(apt)}>
                        <Text style={styles.cancelTxt}>Cancelar</Text>
                      </TouchableOpacity>
                    )}
                  </View>
                </View>
              </View>
            );
          })
        )}
        <View style={{ height: 24 }} />
      </ScrollView>

      {/* Toast */}
      {showToast && (
        <View style={styles.toast}>
          <View style={styles.toastIcon}>
            <Ionicons name="checkmark" size={18} color="#fff" />
          </View>
          <Text style={styles.toastTxt}>¡Cita agendada exitosamente!</Text>
        </View>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container:    { flex: 1, backgroundColor: '#f8fafc' },
  header:       { paddingTop: 52, paddingHorizontal: 20, paddingBottom: 20 },
  headerTop:    { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 },
  headerTitle:  { fontSize: 22, fontWeight: 'bold', color: '#fff' },
  newBtn:       {
    flexDirection: 'row', alignItems: 'center', gap: 4,
    backgroundColor: '#fff', borderRadius: 20,
    paddingHorizontal: 14, paddingVertical: 7,
  },
  newBtnTxt:    { fontSize: 14, color: '#2563eb', fontWeight: '700' },
  searchRow:    {
    flexDirection: 'row', alignItems: 'center',
    backgroundColor: '#fff', borderRadius: 10, paddingHorizontal: 14, paddingVertical: 10,
  },
  searchInput:  { flex: 1, fontSize: 15, color: '#1e293b' },
  tabsWrapper:  { backgroundColor: '#fff', borderBottomWidth: 1, borderBottomColor: '#f1f5f9' },
  tabs:         { paddingHorizontal: 16, paddingVertical: 10, gap: 8 },
  tab:          {
    paddingHorizontal: 16, paddingVertical: 7,
    borderRadius: 20, borderWidth: 1.5, borderColor: '#e2e8f0',
  },
  tabActive:    { backgroundColor: '#2563eb', borderColor: '#2563eb' },
  tabTxt:       { fontSize: 14, color: '#64748b', fontWeight: '500' },
  tabTxtActive: { color: '#fff', fontWeight: '700' },
  list:         { flex: 1 },
  listContent:  { padding: 16 },
  empty:        { alignItems: 'center', paddingTop: 60, gap: 8 },
  emptyTitle:   { fontSize: 18, fontWeight: '700', color: '#1e293b', marginTop: 8 },
  emptySub:     { fontSize: 14, color: '#94a3b8', textAlign: 'center', paddingHorizontal: 24 },
  emptyBtn:     {
    marginTop: 12, backgroundColor: '#2563eb', borderRadius: 10,
    paddingHorizontal: 24, paddingVertical: 12,
  },
  emptyBtnTxt:  { color: '#fff', fontSize: 15, fontWeight: '700' },
  card:         {
    flexDirection: 'row', backgroundColor: '#fff', borderRadius: 16,
    marginBottom: 12, overflow: 'hidden',
    shadowColor: '#000', shadowOffset: { width: 0, height: 1 }, shadowOpacity: 0.07, shadowRadius: 6, elevation: 2,
  },
  cardBorder:   { width: 4, alignSelf: 'stretch' },
  cardBody:     { flex: 1, padding: 14 },
  tagsRow:      { flexDirection: 'row', gap: 8, marginBottom: 8, flexWrap: 'wrap' },
  specialtyTag: { paddingHorizontal: 8, paddingVertical: 3, borderRadius: 6 },
  specialtyTxt: { fontSize: 12, fontWeight: '600' },
  statusTag:    { paddingHorizontal: 8, paddingVertical: 3, borderRadius: 6 },
  statusTxt:    { fontSize: 12, fontWeight: '600' },
  doctor:       { fontSize: 15, fontWeight: '700', color: '#1e293b', marginBottom: 8 },
  metaRow:      { flexDirection: 'row', alignItems: 'center', gap: 4, marginBottom: 4 },
  metaTxt:      { fontSize: 12, color: '#64748b' },
  actionsRow:   {
    flexDirection: 'row', gap: 10, marginTop: 12,
    paddingTop: 10, borderTopWidth: 1, borderTopColor: '#f1f5f9',
  },
  detailsBtn:   {
    flex: 1, borderWidth: 1.5, borderColor: '#e2e8f0', borderRadius: 8,
    paddingVertical: 8, alignItems: 'center',
  },
  detailsTxt:   { fontSize: 13, color: '#374151', fontWeight: '500' },
  cancelBtn:    {
    flex: 1, borderWidth: 1.5, borderColor: '#fecaca', borderRadius: 8,
    paddingVertical: 8, alignItems: 'center',
  },
  cancelTxt:    { fontSize: 13, color: '#dc2626', fontWeight: '600' },
  toast:        {
    position: 'absolute', bottom: 20, left: 20, right: 20,
    flexDirection: 'row', alignItems: 'center', gap: 10,
    backgroundColor: '#1e293b', borderRadius: 12,
    paddingVertical: 14, paddingHorizontal: 16,
    shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.2, shadowRadius: 10, elevation: 8,
  },
  toastIcon:    {
    width: 28, height: 28, borderRadius: 14,
    backgroundColor: '#16a34a', alignItems: 'center', justifyContent: 'center',
  },
  toastTxt:     { fontSize: 14, color: '#fff', fontWeight: '600', flex: 1 },
});
