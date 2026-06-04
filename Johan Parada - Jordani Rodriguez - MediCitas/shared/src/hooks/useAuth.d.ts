import type { Session } from '@supabase/supabase-js';
export declare function useAuth(): {
    session: Session | null;
    loading: boolean;
    error: string | null;
    signUp: (email: string, password: string, metadata?: any) => Promise<void>;
    signIn: (email: string, password: string) => Promise<void>;
    signOut: () => Promise<void>;
    signInWithOAuth: (provider: string, options?: {
        redirectTo?: string;
    }) => Promise<import("@supabase/supabase-js").OAuthResponse>;
};
//# sourceMappingURL=useAuth.d.ts.map