import React, { useState } from 'react';
import {
  View, TextInput, TouchableOpacity, Text, StyleSheet,
  Alert, ActivityIndicator, ScrollView, StatusBar,
} from 'react-native';
import { Ionicons, MaterialIcons, MaterialCommunityIcons } from '@expo/vector-icons';
import { useAuth } from '@medical-app/shared/hooks/useAuth';
import { validateEmail, validatePassword } from '@medical-app/shared/utils';

const EPS_OPTIONS = ['EPS Sura', 'Compensar', 'Sanitas', 'Nueva EPS', 'Famisanar', 'Salud Total', 'Otra'];

export default function RegisterScreen({ navigation }: any) {
  const [fullName, setFullName] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [eps, setEps] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [acceptTerms, setAcceptTerms] = useState(false);
  const [showEpsPicker, setShowEpsPicker] = useState(false);
  const [loading, setLoading]             = useState(false);
  const [googleLoading, setGoogleLoading] = useState(false);
  const { signUp, signInWithGoogle }      = useAuth();

  const handleRegister = async () => {
    if (!fullName.trim() || !email.trim() || !password.trim()) {
      Alert.alert('Error', 'Por favor completa los campos obligatorios');
      return;
    }
    if (!validateEmail(email)) {
      Alert.alert('Error', 'Ingresa un email válido');
      return;
    }
    if (!validatePassword(password)) {
      Alert.alert('Error', 'La contraseña debe tener al menos 6 caracteres');
      return;
    }
    if (password !== confirmPassword) {
      Alert.alert('Error', 'Las contraseñas no coinciden');
      return;
    }
    if (!acceptTerms) {
      Alert.alert('Error', 'Debes aceptar los términos y condiciones');
      return;
    }
    setLoading(true);
    try {
      await signUp(email, password, { full_name: fullName, phone, eps });
      Alert.alert('¡Cuenta creada!', 'Ya puedes iniciar sesión', [
        { text: 'OK', onPress: () => navigation.navigate('Login') },
      ]);
    } catch (error) {
      Alert.alert('Error', error instanceof Error ? error.message : 'Error desconocido');
    } finally {
      setLoading(false);
    }
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content} keyboardShouldPersistTaps="handled">
      <StatusBar barStyle="dark-content" backgroundColor="#eff6ff" />

      <View style={styles.logoContainer}>
        <View style={styles.logoCircle}>
          <Ionicons name="heart" size={34} color="#fff" />
        </View>
        <Text style={styles.appName}>Crear Cuenta</Text>
        <Text style={styles.tagline}>Comienza a gestionar tu salud hoy</Text>
      </View>

      <View style={styles.card}>
        {/* Google */}
        <TouchableOpacity
          style={[styles.googleBtn, googleLoading && { opacity: 0.7 }]}
          disabled={googleLoading || loading}
          onPress={async () => {
            setGoogleLoading(true);
            try {
              await signInWithGoogle();
            } catch (e: any) {
              const msg = e?.message ?? 'Error con Google';
              if (!msg.includes('cancelled') && !msg.includes('cancel')) {
                Alert.alert('Error', msg);
              }
            } finally {
              setGoogleLoading(false);
            }
          }}
        >
          {googleLoading
            ? <ActivityIndicator size="small" color="#4285f4" />
            : <>
                <Text style={styles.googleG}>G</Text>
                <Text style={styles.googleBtnText}>Registrarse con Google</Text>
              </>
          }
        </TouchableOpacity>

        <View style={styles.divider}>
          <View style={styles.dividerLine} />
          <Text style={styles.dividerText}>o regístrate con email</Text>
          <View style={styles.dividerLine} />
        </View>

        {/* Nombre */}
        <Text style={styles.label}>Nombre completo</Text>
        <View style={styles.inputRow}>
          <Ionicons name="person-outline" size={20} color="#9ca3af" style={styles.inputIcon} />
          <TextInput style={styles.input} placeholder="Juan Pérez García" placeholderTextColor="#9ca3af"
            value={fullName} onChangeText={setFullName} editable={!loading} />
        </View>

        {/* Email */}
        <Text style={styles.label}>Correo electrónico</Text>
        <View style={styles.inputRow}>
          <MaterialIcons name="email" size={20} color="#9ca3af" style={styles.inputIcon} />
          <TextInput style={styles.input} placeholder="usuario@ejemplo.com" placeholderTextColor="#9ca3af"
            value={email} onChangeText={setEmail} keyboardType="email-address" autoCapitalize="none" editable={!loading} />
        </View>

        {/* Teléfono */}
        <Text style={styles.label}>Teléfono</Text>
        <View style={styles.inputRow}>
          <Ionicons name="call-outline" size={20} color="#9ca3af" style={styles.inputIcon} />
          <TextInput style={styles.input} placeholder="+57 300 123 4567" placeholderTextColor="#9ca3af"
            value={phone} onChangeText={setPhone} keyboardType="phone-pad" editable={!loading} />
        </View>

        {/* EPS */}
        <Text style={styles.label}>EPS</Text>
        <TouchableOpacity style={styles.inputRow} onPress={() => setShowEpsPicker(!showEpsPicker)}>
          <MaterialCommunityIcons name="office-building-outline" size={20} color="#9ca3af" style={styles.inputIcon} />
          <Text style={[styles.input, { color: eps ? '#1e293b' : '#9ca3af', paddingVertical: 2 }]}>
            {eps || 'Selecciona tu EPS'}
          </Text>
          <Ionicons name="chevron-down" size={18} color="#9ca3af" />
        </TouchableOpacity>
        {showEpsPicker && (
          <View style={styles.epsList}>
            {EPS_OPTIONS.map((item) => (
              <TouchableOpacity key={item} style={styles.epsItem}
                onPress={() => { setEps(item); setShowEpsPicker(false); }}>
                <Text style={styles.epsItemText}>{item}</Text>
              </TouchableOpacity>
            ))}
          </View>
        )}

        {/* Contraseña */}
        <Text style={styles.label}>Contraseña</Text>
        <View style={styles.inputRow}>
          <MaterialIcons name="lock" size={20} color="#9ca3af" style={styles.inputIcon} />
          <TextInput style={styles.input} placeholder="Mínimo 8 caracteres" placeholderTextColor="#9ca3af"
            value={password} onChangeText={setPassword} secureTextEntry={!showPassword} editable={!loading} />
          <TouchableOpacity onPress={() => setShowPassword(!showPassword)}>
            <Ionicons name={showPassword ? 'eye-off-outline' : 'eye-outline'} size={20} color="#9ca3af" />
          </TouchableOpacity>
        </View>

        {/* Confirmar */}
        <Text style={styles.label}>Confirmar contraseña</Text>
        <View style={styles.inputRow}>
          <MaterialIcons name="lock" size={20} color="#9ca3af" style={styles.inputIcon} />
          <TextInput style={styles.input} placeholder="Repite tu contraseña" placeholderTextColor="#9ca3af"
            value={confirmPassword} onChangeText={setConfirmPassword} secureTextEntry editable={!loading} />
        </View>

        {/* Terms */}
        <TouchableOpacity style={styles.termsRow} onPress={() => setAcceptTerms(!acceptTerms)}>
          <View style={[styles.checkbox, acceptTerms && styles.checkboxChecked]}>
            {acceptTerms && <Ionicons name="checkmark" size={12} color="#fff" />}
          </View>
          <Text style={styles.termsText}>
            Acepto los{' '}
            <Text style={styles.termsLink}>términos y condiciones</Text>
            {' '}y la{' '}
            <Text style={styles.termsLink}>política de privacidad</Text>
          </Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={[styles.primaryBtn, loading && { opacity: 0.7 }]}
          onPress={handleRegister} disabled={loading}>
          {loading ? <ActivityIndicator color="#fff" /> : <Text style={styles.primaryBtnText}>Crear Cuenta</Text>}
        </TouchableOpacity>

        <TouchableOpacity onPress={() => navigation.navigate('Login')} style={styles.loginRow}>
          <Text style={styles.loginText}>
            ¿Ya tienes cuenta? <Text style={styles.loginLink}>Inicia sesión</Text>
          </Text>
        </TouchableOpacity>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#eff6ff' },
  content: { padding: 24, paddingBottom: 40 },
  logoContainer: { alignItems: 'center', marginTop: 24, marginBottom: 24 },
  logoCircle: {
    width: 72, height: 72, borderRadius: 36,
    backgroundColor: '#2563eb', alignItems: 'center', justifyContent: 'center', marginBottom: 12,
    shadowColor: '#2563eb', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.3, shadowRadius: 8, elevation: 6,
  },
  appName: { fontSize: 24, fontWeight: 'bold', color: '#1e3a8a', marginBottom: 4 },
  tagline: { fontSize: 14, color: '#64748b' },
  card: {
    backgroundColor: '#fff', borderRadius: 20, padding: 24,
    shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.08, shadowRadius: 12, elevation: 4,
  },
  googleBtn: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'center',
    borderWidth: 1.5, borderColor: '#e2e8f0', borderRadius: 10,
    paddingVertical: 12, marginBottom: 16, backgroundColor: '#fff',
  },
  googleG: { fontSize: 17, fontWeight: 'bold', color: '#4285f4', marginRight: 8 },
  googleBtnText: { fontSize: 15, color: '#374151', fontWeight: '500' },
  divider: { flexDirection: 'row', alignItems: 'center', marginBottom: 16 },
  dividerLine: { flex: 1, height: 1, backgroundColor: '#e2e8f0' },
  dividerText: { marginHorizontal: 10, fontSize: 12, color: '#94a3b8' },
  label: { fontSize: 13, fontWeight: '600', color: '#374151', marginBottom: 6 },
  inputRow: {
    flexDirection: 'row', alignItems: 'center',
    borderWidth: 1.5, borderColor: '#e2e8f0', borderRadius: 10,
    paddingHorizontal: 12, paddingVertical: 10, marginBottom: 14, backgroundColor: '#f8fafc',
  },
  inputIcon: { marginRight: 8 },
  input: { flex: 1, fontSize: 15, color: '#1e293b' },
  epsList: {
    borderWidth: 1, borderColor: '#e2e8f0', borderRadius: 10,
    marginTop: -10, marginBottom: 14, backgroundColor: '#fff', overflow: 'hidden',
  },
  epsItem: { paddingVertical: 12, paddingHorizontal: 16, borderBottomWidth: 1, borderBottomColor: '#f1f5f9' },
  epsItemText: { fontSize: 15, color: '#374151' },
  termsRow: { flexDirection: 'row', alignItems: 'flex-start', marginBottom: 20, gap: 10 },
  checkbox: {
    width: 18, height: 18, borderRadius: 4, borderWidth: 2, borderColor: '#cbd5e1',
    alignItems: 'center', justifyContent: 'center', marginTop: 2,
  },
  checkboxChecked: { backgroundColor: '#2563eb', borderColor: '#2563eb' },
  termsText: { flex: 1, fontSize: 13, color: '#64748b', lineHeight: 20 },
  termsLink: { color: '#2563eb', fontWeight: '600' },
  primaryBtn: {
    backgroundColor: '#2563eb', borderRadius: 10, paddingVertical: 14,
    alignItems: 'center', marginBottom: 16,
  },
  primaryBtnText: { color: '#fff', fontSize: 16, fontWeight: '700' },
  loginRow: { alignItems: 'center' },
  loginText: { fontSize: 14, color: '#64748b' },
  loginLink: { color: '#2563eb', fontWeight: '700' },
});
