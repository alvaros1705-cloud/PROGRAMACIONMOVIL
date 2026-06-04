import { useState, useEffect, useCallback } from 'react';
import * as WebBrowser from 'expo-web-browser';
import * as Linking from 'expo-linking';
import { makeRedirectUri } from 'expo-auth-session';
import { supabase } from '../lib/supabase';
import type { Session } from '@supabase/supabase-js';

// Dismiss any leftover browser session from a previous OAuth attempt
WebBrowser.maybeCompleteAuthSession();

// ─── Parse tokens/code from the deep-link callback URL ───────────────────────
function parseAuthUrl(url: string): Record<string, string> {
  const result: Record<string, string> = {};
  const decode = (str: string) =>
    str.split('&').filter(Boolean).forEach(pair => {
      const idx = pair.indexOf('=');
      if (idx > 0)
        result[pair.slice(0, idx)] = decodeURIComponent(
          pair.slice(idx + 1).replace(/\+/g, ' ')
        );
    });
  const hashIdx  = url.indexOf('#');
  const queryIdx = url.indexOf('?');
  if (hashIdx  > -1) decode(url.slice(hashIdx + 1));
  if (queryIdx > -1) decode(url.slice(queryIdx + 1, hashIdx > queryIdx ? hashIdx : undefined));
  return result;
}

// ─── Exchange tokens/code for a Supabase session ─────────────────────────────
async function applyAuthUrl(url: string): Promise<void> {
  const params = parseAuthUrl(url);
  console.log('[OAuth] callback params:', Object.keys(params));

  if (params.access_token && params.refresh_token) {
    // Implicit flow
    const { error } = await supabase.auth.setSession({
      access_token:  params.access_token,
      refresh_token: params.refresh_token,
    });
    if (error) throw error;

  } else if (params.code) {
    // PKCE flow (preferred for mobile)
    const { error } = await supabase.auth.exchangeCodeForSession(params.code);
    if (error) throw error;

  } else {
    console.warn('[OAuth] no tokens in callback URL:', url);
  }
}

// ─── Hook ─────────────────────────────────────────────────────────────────────
export function useAuth() {
  const [session, setSession] = useState<Session | null>(null);
  const [loading, setLoading]  = useState(true);
  const [error, setError]      = useState<string | null>(null);

  useEffect(() => {
    // 1. Restore persisted session
    supabase.auth.getSession().then(({ data: { session }, error }) => {
      if (error) setError(error.message);
      setSession(session);
      setLoading(false);
    });

    // 2. React to auth events (login, logout, token refresh)
    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session);
      setLoading(false);
    });

    // 3a. Handle OAuth URL when Expo Go was LAUNCHED FRESH by the deep-link
    Linking.getInitialURL().then(url => {
      if (!url) return;
      console.log('[Linking] initial URL:', url.slice(0, 100));
      const isAuth = url.includes('access_token') || url.includes('code=') || url.includes('auth/callback');
      if (isAuth) applyAuthUrl(url).catch(e => console.error('[OAuth] initial URL error:', e));
    });

    // 3b. Handle OAuth deep-link when the app is ALREADY open
    //    (Android fires this when it re-opens the app via exp:// intent)
    const linkSub = Linking.addEventListener('url', ({ url }) => {
      if (!url) return;
      console.log('[Linking] url received:', url.slice(0, 100));
      const isAuthCallback =
        url.includes('access_token') ||
        url.includes('refresh_token') ||
        url.includes('code=')         ||
        url.includes('auth/callback');
      if (isAuthCallback) {
        console.log('[OAuth] processing callback...');
        applyAuthUrl(url).catch(e => setError(e?.message ?? 'OAuth error'));
      }
    });

    return () => {
      subscription?.unsubscribe();
      linkSub.remove();
    };
  }, []);

  // ── Email sign-up ──
  const signUp = useCallback(async (email: string, password: string, metadata?: any) => {
    setLoading(true); setError(null);
    try {
      const { error } = await supabase.auth.signUp({ email, password, options: { data: metadata } });
      if (error) throw error;
    } catch (err) {
      const msg = err instanceof Error ? err.message : 'Error al registrarse';
      setError(msg); throw err;
    } finally { setLoading(false); }
  }, []);

  // ── Email sign-in ──
  const signIn = useCallback(async (email: string, password: string) => {
    setLoading(true); setError(null);
    try {
      const { error } = await supabase.auth.signInWithPassword({ email, password });
      if (error) throw error;
    } catch (err) {
      const msg = err instanceof Error ? err.message : 'Error al iniciar sesión';
      setError(msg); throw err;
    } finally { setLoading(false); }
  }, []);

  // ── Sign-out ──
  const signOut = useCallback(async () => {
    setLoading(true);
    try {
      const { error } = await supabase.auth.signOut();
      if (error) throw error;
      setSession(null);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Error al cerrar sesión');
      throw err;
    } finally { setLoading(false); }
  }, []);

  // ── Google OAuth ──────────────────────────────────────────────────────────
  const signInWithGoogle = useCallback(async () => {
    setError(null);

    // In a Dev Build / production the app registers "medicitas://" natively,
    // so the OS intercepts the redirect and openAuthSessionAsync gets type:"success".
    // This does NOT work in Expo Go (which only registers exp://).
    const redirectUri = makeRedirectUri({
      scheme: 'medicitas',
      path: 'auth/callback',
    });
    console.log('[OAuth] redirectUri →', redirectUri);

    try {
      // Ask Supabase for the Google login page URL (without opening browser yet)
      const { data, error } = await supabase.auth.signInWithOAuth({
        provider: 'google',
        options: {
          redirectTo: redirectUri,
          skipBrowserRedirect: true,
        },
      });

      if (error) throw error;
      if (!data.url) throw new Error('No se obtuvo la URL de autenticación de Google');

      console.log('[OAuth] Supabase URL (primeros 120):', data.url.slice(0, 120));
      console.log('[OAuth] opening browser...');

      // KEY TRICK: monitor the auth.expo.io URL itself as the redirect prefix.
      // When Supabase redirects to:
      //   https://auth.expo.io/@johanp19/medical-appointment#access_token=xxx
      // openAuthSessionAsync intercepts it BEFORE auth.expo.io loads.
      // We get the full URL with tokens directly — no proxy needed.
      const result = await WebBrowser.openAuthSessionAsync(data.url, redirectUri);

      console.log('[OAuth] result type:', result.type);
      if (result.type === 'success') {
        console.log('[OAuth] result URL:', result.url.slice(0, 120));
        await applyAuthUrl(result.url);
      }

    } catch (err) {
      const msg = err instanceof Error ? err.message : 'Error con Google';
      setError(msg);
      throw err;
    }
  }, []);

  return {
    session,
    loading,
    error,
    signUp,
    signIn,
    signOut,
    signInWithGoogle,
    signInWithOAuth: signInWithGoogle, // legacy alias
  };
}
