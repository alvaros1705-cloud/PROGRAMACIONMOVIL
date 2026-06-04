import { createClient } from "@supabase/supabase-js";
// ⚠️ IMPORTANTE: Usa variables de entorno en producción
// Para desarrollo local, estos valores están configurados en Supabase
const projectId = (typeof import.meta !== "undefined" && import.meta.env?.VITE_SUPABASE_PROJECT_ID) ||
    process.env.VITE_SUPABASE_PROJECT_ID ||
    "xvltrvxudrmcleaafscc";
const publicAnonKey = (typeof import.meta !== "undefined" && import.meta.env?.VITE_SUPABASE_ANON_KEY) ||
    process.env.VITE_SUPABASE_ANON_KEY ||
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh2bHRydnh1ZHJtY2xlYWFmc2NjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkyMjY5OTAsImV4cCI6MjA5NDgwMjk5MH0.DMcHnPlEDppgZdVYfpOh4GxCjqsx-QHXmuf6YC5VNww";
export const supabase = createClient(`https://${projectId}.supabase.co`, publicAnonKey);
export default supabase;
//# sourceMappingURL=supabase.js.map