import React, { useState, useEffect, useRef } from 'react';
import {
  View, TextInput, TouchableOpacity, Text, StyleSheet,
  Alert, ActivityIndicator, ScrollView, StatusBar, Animated, Easing,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons, MaterialIcons } from '@expo/vector-icons';
import { useAuth } from '@medical-app/shared/hooks/useAuth';
import { validateEmail } from '@medical-app/shared/utils';

export default function LoginScreen({ navigation }: any) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading]       = useState(false);
  const [googleLoading, setGoogleLoading] = useState(false);
  const { signIn, signInWithGoogle } = useAuth();

  // ── Animations ──────────────────────────────────────────────────────────────
  const logoScale   = useRef(new Animated.Value(0.5)).current;
  const logoOpacity = useRef(new Animated.Value(0)).current;
  const heartPulse  = useRef(new Animated.Value(1)).current;
  const cardTransY  = useRef(new Animated.Value(60)).current;
  const cardOpacity = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    // Logo bounces in
    Animated.parallel([
      Animated.spring(logoScale,   { toValue: 1, friction: 5, tension: 80, useNativeDriver: true }),
      Animated.timing(logoOpacity, { toValue: 1, duration: 400, useNativeDriver: true }),
    ]).start();

    // Card slides up
    Animated.sequence([
      Animated.delay(200),
      Animated.parallel([
        Animated.timing(cardTransY,  { toValue: 0,  duration: 500, easing: Easing.out(Easing.quad), useNativeDriver: true }),
        Animated.timing(cardOpacity, { toValue: 1,  duration: 500, useNativeDriver: true }),
      ]),
    ]).start();

    // Heartbeat loop
    Animated.loop(
      Animated.sequence([
        Animated.timing(heartPulse, { toValue: 1.2, duration: 300, easing: Easing.out(Easing.quad), useNativeDriver: true }),
        Animated.timing(heartPulse, { toValue: 1,   duration: 300, easing: Easing.in(Easing.quad),  useNativeDriver: true }),
        Animated.timing(heartPulse, { toValue: 1.1, duration: 200, useNativeDriver: true }),
        Animated.timing(heartPulse, { toValue: 1,   duration: 200, useNativeDriver: true }),
        Animated.delay(1200),
      ])
    ).start();
  }, []);

  const handleLogin = async () => {
    if (!email.trim() || !password.trim()) {
      Alert.alert('Error', 'Por favor completa todos los campos');
      return;
    }
    if (!validateEmail(email)) {
      Alert.alert('Error', 'Ingresa un email válido');
      return;
    }
    setLoading(true);
    try {
      await signIn(email, password);
    } catch (error) {
      Alert.alert('Error', error instanceof Error ? error.message : 'Error desconocido');
    } finally {
      setLoading(false);
    }
  };

  return (
    <View style={styles.container}>
      <StatusBar barStyle="light-content" backgroundColor="#1e3a8a" />
      <LinearGradient
        colors={['#1e3a8a', '#1e40af', '#0ea5e9']}
        start={{ x: 0, y: 0 }} end={{ x: 1, y: 1 }}
        style={styles.gradientBg}
      />

      {/* Decorative bg circles */}
      <View style={styles.bgCircle1} />
      <View style={styles.bgCircle2} />

    <ScrollView contentContainerStyle={styles.content} keyboardShouldPersistTaps="handled" showsVerticalScrollIndicator={false}>

      {/* Logo animado */}
      <Animated.View style={[styles.logoContainer, { opacity: logoOpacity, transform: [{ scale: logoScale }] }]}>
        <View style={styles.logoCircle}>
          <Animated.View style={{ transform: [{ scale: heartPulse }] }}>
            <Ionicons name="heart" size={38} color="#fff" />
          </Animated.View>
        </View>
        <Text style={styles.appName}>MediCitas</Text>
        <Text style={styles.tagline}>Tu salud, siempre a tiempo</Text>
      </Animated.View>

      {/* Card animada */}
      <Animated.View style={[styles.card, { opacity: cardOpacity, transform: [{ translateY: cardTransY }] }]}>
        <Text style={styles.cardTitle}>Iniciar Sesión</Text>
        <Text style={styles.cardSubtitle}>Accede a tu cuenta</Text>

        <Text style={styles.label}>Correo electrónico</Text>
        <View style={styles.inputRow}>
          <MaterialIcons name="email" size={20} color="#9ca3af" style={styles.inputIcon} />
          <TextInput
            style={styles.input}
            placeholder="usuario@ejemplo.com"
            placeholderTextColor="#9ca3af"
            value={email}
            onChangeText={setEmail}
            keyboardType="email-address"
            autoCapitalize="none"
            editable={!loading}
          />
        </View>

        <Text style={styles.label}>Contraseña</Text>
        <View style={styles.inputRow}>
          <MaterialIcons name="lock" size={20} color="#9ca3af" style={styles.inputIcon} />
          <TextInput
            style={styles.input}
            placeholder="••••••••"
            placeholderTextColor="#9ca3af"
            value={password}
            onChangeText={setPassword}
            secureTextEntry={!showPassword}
            editable={!loading}
          />
          <TouchableOpacity onPress={() => setShowPassword(!showPassword)}>
            <Ionicons name={showPassword ? 'eye-off-outline' : 'eye-outline'} size={20} color="#9ca3af" />
          </TouchableOpacity>
        </View>

        <TouchableOpacity style={styles.forgotRow}>
          <Text style={styles.forgotText}>¿Olvidaste tu contraseña?</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={[styles.primaryBtn, loading && { opacity: 0.7 }]}
          onPress={handleLogin}
          disabled={loading}
        >
          {loading ? <ActivityIndicator color="#fff" /> : <Text style={styles.primaryBtnText}>Iniciar Sesión</Text>}
        </TouchableOpacity>

        <View style={styles.divider}>
          <View style={styles.dividerLine} />
          <Text style={styles.dividerText}>o continúa con</Text>
          <View style={styles.dividerLine} />
        </View>

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
                <Text style={styles.googleBtnText}>Continuar con Google</Text>
              </>
          }
        </TouchableOpacity>

        <TouchableOpacity onPress={() => navigation.navigate('Register')} style={styles.registerRow}>
          <Text style={styles.registerText}>
            ¿No tienes una cuenta?{' '}
            <Text style={styles.registerLink}>Regístrate aquí</Text>
          </Text>
        </TouchableOpacity>
      </Animated.View>

      <Text style={styles.footer}>© 2026 MediCitas. Todos los derechos reservados.</Text>
    </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container:   { flex: 1 },
  gradientBg:  { ...StyleSheet.absoluteFillObject },
  bgCircle1:   {
    position: 'absolute', width: 350, height: 350, borderRadius: 175,
    backgroundColor: 'rgba(255,255,255,0.05)', top: -80, right: -80,
  },
  bgCircle2:   {
    position: 'absolute', width: 250, height: 250, borderRadius: 125,
    backgroundColor: 'rgba(255,255,255,0.04)', bottom: 100, left: -60,
  },
  content: { padding: 24, paddingBottom: 40 },
  logoContainer: { alignItems: 'center', marginTop: 52, marginBottom: 28 },
  logoCircle: {
    width: 80, height: 80, borderRadius: 40,
    backgroundColor: 'rgba(255,255,255,0.18)',
    alignItems: 'center', justifyContent: 'center',
    marginBottom: 14,
    borderWidth: 2, borderColor: 'rgba(255,255,255,0.3)',
    shadowColor: '#fff', shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0.15, shadowRadius: 16, elevation: 8,
  },
  appName: { fontSize: 32, fontWeight: '800', color: '#fff', marginBottom: 4, letterSpacing: 0.5 },
  tagline: { fontSize: 14, color: 'rgba(255,255,255,0.75)' },
  card: {
    backgroundColor: '#fff', borderRadius: 20, padding: 24,
    shadowColor: '#000', shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08, shadowRadius: 12, elevation: 4,
  },
  cardTitle: { fontSize: 22, fontWeight: 'bold', color: '#1e293b', marginBottom: 4 },
  cardSubtitle: { fontSize: 14, color: '#64748b', marginBottom: 20 },
  label: { fontSize: 13, fontWeight: '600', color: '#374151', marginBottom: 6 },
  inputRow: {
    flexDirection: 'row', alignItems: 'center',
    borderWidth: 1.5, borderColor: '#e2e8f0', borderRadius: 10,
    paddingHorizontal: 12, paddingVertical: 10, marginBottom: 14,
    backgroundColor: '#f8fafc',
  },
  inputIcon: { marginRight: 8 },
  input: { flex: 1, fontSize: 15, color: '#1e293b' },
  forgotRow: { alignItems: 'flex-end', marginBottom: 20, marginTop: -6 },
  forgotText: { fontSize: 13, color: '#2563eb', fontWeight: '500' },
  primaryBtn: {
    backgroundColor: '#2563eb', borderRadius: 10, paddingVertical: 14,
    alignItems: 'center', marginBottom: 16,
  },
  primaryBtnText: { color: '#fff', fontSize: 16, fontWeight: '700' },
  divider: { flexDirection: 'row', alignItems: 'center', marginBottom: 16 },
  dividerLine: { flex: 1, height: 1, backgroundColor: '#e2e8f0' },
  dividerText: { marginHorizontal: 12, fontSize: 13, color: '#94a3b8' },
  googleBtn: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'center',
    borderWidth: 1.5, borderColor: '#e2e8f0', borderRadius: 10,
    paddingVertical: 12, marginBottom: 20, backgroundColor: '#fff',
  },
  googleG: { fontSize: 17, fontWeight: 'bold', color: '#4285f4', marginRight: 8 },
  googleBtnText: { fontSize: 15, color: '#374151', fontWeight: '500' },
  registerRow: { alignItems: 'center' },
  registerText: { fontSize: 14, color: '#64748b' },
  registerLink: { color: '#2563eb', fontWeight: '700' },
  footer: { textAlign: 'center', marginTop: 24, fontSize: 12, color: '#94a3b8' },
});
