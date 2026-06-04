import React, { useEffect, useRef } from 'react';
import { View, Text, StyleSheet, Animated, Easing } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons } from '@expo/vector-icons';

interface Props {
  onFinish: () => void;
}

export default function SplashAnimScreen({ onFinish }: Props) {
  const logoScale    = useRef(new Animated.Value(0.3)).current;
  const logoOpacity  = useRef(new Animated.Value(0)).current;
  const heartScale   = useRef(new Animated.Value(1)).current;
  const textOpacity  = useRef(new Animated.Value(0)).current;
  const textTransY   = useRef(new Animated.Value(24)).current;
  const taglineOp    = useRef(new Animated.Value(0)).current;
  const ringScale    = useRef(new Animated.Value(1)).current;
  const ringOpacity  = useRef(new Animated.Value(0.5)).current;
  const screenOpacity = useRef(new Animated.Value(1)).current;

  // Dot opacities — declared at top level (no loops)
  const dot0 = useRef(new Animated.Value(0.3)).current;
  const dot1 = useRef(new Animated.Value(0.3)).current;
  const dot2 = useRef(new Animated.Value(0.3)).current;

  useEffect(() => {
    // 1. Logo entra con spring
    Animated.parallel([
      Animated.spring(logoScale,   { toValue: 1, friction: 5, tension: 80, useNativeDriver: true }),
      Animated.timing(logoOpacity, { toValue: 1, duration: 400, useNativeDriver: true }),
    ]).start();

    // 2. Heartbeat loop
    Animated.loop(
      Animated.sequence([
        Animated.timing(heartScale, { toValue: 1.2,  duration: 300, easing: Easing.out(Easing.quad), useNativeDriver: true }),
        Animated.timing(heartScale, { toValue: 1,    duration: 300, easing: Easing.in(Easing.quad),  useNativeDriver: true }),
        Animated.timing(heartScale, { toValue: 1.12, duration: 200, useNativeDriver: true }),
        Animated.timing(heartScale, { toValue: 1,    duration: 200, useNativeDriver: true }),
        Animated.delay(800),
      ])
    ).start();

    // 3. Ripple ring
    Animated.loop(
      Animated.sequence([
        Animated.parallel([
          Animated.timing(ringScale,   { toValue: 2.4, duration: 1200, easing: Easing.out(Easing.ease), useNativeDriver: true }),
          Animated.timing(ringOpacity, { toValue: 0,   duration: 1200, useNativeDriver: true }),
        ]),
        Animated.parallel([
          Animated.timing(ringScale,   { toValue: 1,   duration: 0, useNativeDriver: true }),
          Animated.timing(ringOpacity, { toValue: 0.5, duration: 0, useNativeDriver: true }),
        ]),
      ])
    ).start();

    // 4. Texto sube
    Animated.sequence([
      Animated.delay(350),
      Animated.parallel([
        Animated.timing(textOpacity, { toValue: 1, duration: 450, useNativeDriver: true }),
        Animated.timing(textTransY,  { toValue: 0, duration: 450, easing: Easing.out(Easing.quad), useNativeDriver: true }),
      ]),
    ]).start();

    // 5. Tagline
    Animated.sequence([
      Animated.delay(650),
      Animated.timing(taglineOp, { toValue: 1, duration: 400, useNativeDriver: true }),
    ]).start();

    // 6. Dots animados
    const animateDot = (dot: Animated.Value, delay: number) =>
      Animated.loop(
        Animated.sequence([
          Animated.delay(delay),
          Animated.timing(dot, { toValue: 1,   duration: 300, useNativeDriver: true }),
          Animated.timing(dot, { toValue: 0.3, duration: 300, useNativeDriver: true }),
          Animated.delay(600),
        ])
      ).start();

    animateDot(dot0, 0);
    animateDot(dot1, 200);
    animateDot(dot2, 400);

    // 7. Fade out y callback
    Animated.sequence([
      Animated.delay(2700),
      Animated.timing(screenOpacity, { toValue: 0, duration: 400, useNativeDriver: true }),
    ]).start(() => onFinish());
  }, []);

  return (
    <Animated.View style={[styles.wrapper, { opacity: screenOpacity }]}>
      <LinearGradient
        colors={['#1e3a8a', '#1e40af', '#0891b2']}
        start={{ x: 0, y: 0 }} end={{ x: 1, y: 1 }}
        style={StyleSheet.absoluteFill}
      />

      <View style={styles.bgCircle1} />
      <View style={styles.bgCircle2} />

      <View style={styles.center}>
        {/* Ripple */}
        <Animated.View style={[styles.ring, { transform: [{ scale: ringScale }], opacity: ringOpacity }]} />

        {/* Logo */}
        <Animated.View style={[styles.logoCircle, { opacity: logoOpacity, transform: [{ scale: logoScale }] }]}>
          <Animated.View style={{ transform: [{ scale: heartScale }] }}>
            <Ionicons name="heart" size={48} color="#fff" />
          </Animated.View>
        </Animated.View>

        {/* Nombre */}
        <Animated.Text style={[styles.appName, { opacity: textOpacity, transform: [{ translateY: textTransY }] }]}>
          MediCitas
        </Animated.Text>

        {/* Tagline */}
        <Animated.Text style={[styles.tagline, { opacity: taglineOp }]}>
          Tu salud, siempre a tiempo
        </Animated.Text>
      </View>

      {/* Dots */}
      <View style={styles.dotsRow}>
        <Animated.View style={[styles.dot, { opacity: dot0 }]} />
        <Animated.View style={[styles.dot, { opacity: dot1 }]} />
        <Animated.View style={[styles.dot, { opacity: dot2 }]} />
      </View>
    </Animated.View>
  );
}

const styles = StyleSheet.create({
  wrapper:    { flex: 1, alignItems: 'center', justifyContent: 'center' },
  bgCircle1:  { position: 'absolute', width: 400, height: 400, borderRadius: 200, backgroundColor: 'rgba(255,255,255,0.04)', top: -80, right: -100 },
  bgCircle2:  { position: 'absolute', width: 280, height: 280, borderRadius: 140, backgroundColor: 'rgba(255,255,255,0.04)', bottom: 20, left: -70 },
  center:     { alignItems: 'center', justifyContent: 'center' },
  ring:       { position: 'absolute', width: 140, height: 140, borderRadius: 70, borderWidth: 2, borderColor: 'rgba(255,255,255,0.45)' },
  logoCircle: {
    width: 110, height: 110, borderRadius: 55,
    backgroundColor: 'rgba(255,255,255,0.15)',
    alignItems: 'center', justifyContent: 'center',
    borderWidth: 2, borderColor: 'rgba(255,255,255,0.3)',
    marginBottom: 28,
  },
  appName:    { fontSize: 42, fontWeight: '800', color: '#fff', letterSpacing: 1, marginBottom: 8 },
  tagline:    { fontSize: 15, color: 'rgba(255,255,255,0.75)' },
  dotsRow:    { position: 'absolute', bottom: 60, flexDirection: 'row', gap: 10 },
  dot:        { width: 9, height: 9, borderRadius: 5, backgroundColor: 'rgba(255,255,255,0.85)' },
});
