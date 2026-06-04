import { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
export function useAuth() {
    const [session, setSession] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    useEffect(() => {
        // Verificar sesión existente
        supabase.auth.getSession().then(({ data: { session }, error }) => {
            if (error) {
                setError(error.message);
            }
            setSession(session);
            setLoading(false);
        });
        // Escuchar cambios en autenticación
        const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
            setSession(session);
            setLoading(false);
        });
        return () => subscription?.unsubscribe();
    }, []);
    const signUp = async (email, password, metadata) => {
        setLoading(true);
        setError(null);
        try {
            const { error } = await supabase.auth.signUp({
                email,
                password,
                options: {
                    data: metadata,
                },
            });
            if (error)
                throw error;
        }
        catch (err) {
            setError(err instanceof Error ? err.message : 'Error signing up');
            throw err;
        }
        finally {
            setLoading(false);
        }
    };
    const signIn = async (email, password) => {
        setLoading(true);
        setError(null);
        try {
            const { error } = await supabase.auth.signInWithPassword({
                email,
                password,
            });
            if (error)
                throw error;
        }
        catch (err) {
            setError(err instanceof Error ? err.message : 'Error signing in');
            throw err;
        }
        finally {
            setLoading(false);
        }
    };
    const signOut = async () => {
        setLoading(true);
        setError(null);
        try {
            const { error } = await supabase.auth.signOut();
            if (error)
                throw error;
            setSession(null);
        }
        catch (err) {
            setError(err instanceof Error ? err.message : 'Error signing out');
            throw err;
        }
        finally {
            setLoading(false);
        }
    };
    const signInWithOAuth = async (provider, options) => {
        setLoading(true);
        setError(null);
        try {
            const res = await supabase.auth.signInWithOAuth({ provider: provider, options: options });
            // return the URL to open in a browser (React Native will open it)
            return res;
        }
        catch (err) {
            setError(err instanceof Error ? err.message : 'Error signing in with OAuth');
            throw err;
        }
        finally {
            setLoading(false);
        }
    };
    return {
        session,
        loading,
        error,
        signUp,
        signIn,
        signOut,
        signInWithOAuth,
    };
}
//# sourceMappingURL=useAuth.js.map