-- ════════════════════════════════════════════════════════
--  MediCitas – Migración completa
--  Ejecutar en: Supabase Dashboard → SQL Editor
-- ════════════════════════════════════════════════════════

-- ── 1. Perfiles de usuario ───────────────────────────────
CREATE TABLE IF NOT EXISTS profiles (
  id          UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  full_name   TEXT,
  phone       TEXT,
  eps         TEXT    DEFAULT 'EPS Sura',
  blood_type  TEXT    DEFAULT 'O+',
  allergies   TEXT[]  DEFAULT ARRAY[]::TEXT[],
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ── 2. Citas médicas ─────────────────────────────────────
CREATE TABLE IF NOT EXISTS appointments (
  id        UUID    DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id   UUID    REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  specialty TEXT    NOT NULL,
  doctor    TEXT    NOT NULL,
  date      TEXT    NOT NULL,   -- "25 Abr, 2026"
  time      TEXT    NOT NULL,   -- "10:30 AM"
  location  TEXT    NOT NULL,
  color     TEXT    NOT NULL DEFAULT '#2563eb',
  status    TEXT    NOT NULL DEFAULT 'Confirmada'
              CHECK (status IN ('Confirmada','Pendiente','Cancelada','Completada')),
  notes     TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── 3. Exámenes / resultados ─────────────────────────────
CREATE TABLE IF NOT EXISTS exams (
  id        UUID   DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id   UUID   REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name      TEXT   NOT NULL,
  type      TEXT   NOT NULL,   -- 'Sangre' | 'Orina' | 'Imagen'
  date      TEXT   NOT NULL,   -- "15 Abr, 2026"
  doctor    TEXT   NOT NULL,
  status    TEXT   NOT NULL DEFAULT 'Pendiente'
              CHECK (status IN ('Pendiente','Disponible')),
  result    TEXT,
  notes     TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── 4. Medicamentos / recetas ────────────────────────────
CREATE TABLE IF NOT EXISTS medications (
  id          UUID    DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id     UUID    REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name        TEXT    NOT NULL,
  description TEXT    DEFAULT '',
  frequency   TEXT    NOT NULL,
  hours       TEXT    NOT NULL,
  duration    TEXT    NOT NULL DEFAULT 'Continuo',
  doctor      TEXT    NOT NULL,
  date        TEXT    NOT NULL,  -- "10 Ene, 2026"
  status      TEXT    NOT NULL DEFAULT 'Activo'
                CHECK (status IN ('Activo','Inactivo')),
  adherence   INTEGER DEFAULT 0 CHECK (adherence BETWEEN 0 AND 3),
  color       TEXT    DEFAULT '#2563eb',
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ════════════════════════════════════════════════════════
--  Row Level Security
-- ════════════════════════════════════════════════════════

ALTER TABLE profiles    ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE exams        ENABLE ROW LEVEL SECURITY;
ALTER TABLE medications  ENABLE ROW LEVEL SECURITY;

-- profiles
CREATE POLICY "profiles_select" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "profiles_insert" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "profiles_update" ON profiles FOR UPDATE USING (auth.uid() = id);

-- appointments
CREATE POLICY "appointments_select" ON appointments FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "appointments_insert" ON appointments FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "appointments_update" ON appointments FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "appointments_delete" ON appointments FOR DELETE USING (auth.uid() = user_id);

-- exams
CREATE POLICY "exams_select" ON exams FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "exams_insert" ON exams FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "exams_update" ON exams FOR UPDATE USING (auth.uid() = user_id);

-- medications
CREATE POLICY "medications_select" ON medications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "medications_insert" ON medications FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "medications_update" ON medications FOR UPDATE USING (auth.uid() = user_id);

-- ════════════════════════════════════════════════════════
--  Auto-crear perfil al registrarse
-- ════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1))
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
