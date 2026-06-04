export type Screen = 'login' | 'register' | 'dashboard' | 'appointments' | 'exams' | 'profile' | 'medications';
export interface User {
    id: string;
    email: string;
    full_name?: string;
    phone?: string;
    date_of_birth?: string;
    created_at: string;
}
export interface Appointment {
    id: string;
    user_id: string;
    doctor_name: string;
    specialty: string;
    date: string;
    time: string;
    location: string;
    notes?: string;
    status: 'scheduled' | 'completed' | 'cancelled';
    created_at: string;
}
export interface Exam {
    id: string;
    user_id: string;
    exam_name: string;
    exam_type: string;
    date: string;
    result?: string;
    notes?: string;
    status: 'pending' | 'completed' | 'reviewed';
    created_at: string;
}
export interface Medication {
    id: string;
    user_id: string;
    name: string;
    dosage: string;
    frequency: string;
    start_date: string;
    end_date?: string;
    prescriptions?: string;
    created_at: string;
}
export interface AuthContext {
    session: any;
    loading: boolean;
    signUp: (email: string, password: string) => Promise<void>;
    signIn: (email: string, password: string) => Promise<void>;
    signOut: () => Promise<void>;
}
//# sourceMappingURL=index.d.ts.map