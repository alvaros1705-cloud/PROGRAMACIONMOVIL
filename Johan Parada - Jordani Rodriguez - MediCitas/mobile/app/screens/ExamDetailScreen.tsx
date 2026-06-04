import React from 'react';
import {
  View, Text, StyleSheet, ScrollView,
  TouchableOpacity, StatusBar, Alert, ActivityIndicator, Share,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';

// ─── Types ────────────────────────────────────────────────────────────────────

type StatusKey = 'Normal' | 'Alto' | 'Bajo' | 'Anormal';

interface Parameter {
  name: string;
  range: string;
  value: string;
  unit: string;
  status: StatusKey;
}

interface ImageFinding {
  finding: string;
  result: string;
  status?: StatusKey;
}

interface ExamData {
  name: string;
  date: string;
  doctor: string;
  interpretation: string;
  parameters?: Parameter[];
  isImage?: boolean;
  imageFindings?: ImageFinding[];
}

// ─── Status badge config ──────────────────────────────────────────────────────

const STATUS_BADGE: Record<StatusKey, { bg: string; text: string; icon: string }> = {
  Normal:  { bg: '#dcfce7', text: '#16a34a', icon: '—' },
  Alto:    { bg: '#fff7ed', text: '#ea580c', icon: '↑' },
  Bajo:    { bg: '#dbeafe', text: '#2563eb', icon: '↓' },
  Anormal: { bg: '#fee2e2', text: '#dc2626', icon: '!' },
};

// ─── Data por NOMBRE (cubre todos los exámenes auto-generados) ───────────────

export const EXAM_DATA_BY_NAME: Record<string, Omit<ExamData, 'name' | 'date' | 'doctor'>> = {
  'Hemograma Completo': {
    interpretation: 'Los valores del hemograma se encuentran dentro de los rangos normales. No se observan alteraciones significativas en las series roja, blanca ni plaquetaria.',
    parameters: [
      { name: 'Glóbulos Rojos',   range: '4.5 – 5.5',   value: '4.8',  unit: 'millones/uL', status: 'Normal' },
      { name: 'Glóbulos Blancos', range: '4.0 – 11.0',  value: '7.2',  unit: 'miles/uL',    status: 'Normal' },
      { name: 'Hemoglobina',      range: '13.5 – 17.5', value: '14.5', unit: 'g/dL',        status: 'Normal' },
      { name: 'Hematocrito',      range: '41 – 53',     value: '44',   unit: '%',           status: 'Normal' },
      { name: 'Plaquetas',        range: '150 – 400',   value: '245',  unit: 'miles/uL',    status: 'Normal' },
    ],
  },
  'Glucosa en Ayunas': {
    interpretation: 'La glucosa en ayunas se encuentra dentro del rango normal. No se evidencia riesgo de prediabetes ni diabetes. Continuar con hábitos saludables.',
    parameters: [
      { name: 'Glucosa basal', range: '70 – 99',    value: '95',  unit: 'mg/dL',   status: 'Normal' },
      { name: 'Insulina',      range: '2.6 – 24.9', value: '8.4', unit: 'uUI/mL',  status: 'Normal' },
      { name: 'Indice HOMA',   range: '< 2.5',      value: '1.9', unit: 'unidades',status: 'Normal' },
    ],
  },
  'Perfil Lipídico': {
    interpretation: 'El perfil lipídico muestra valores en su mayoría normales. Los triglicéridos se encuentran ligeramente elevados. Se recomienda dieta baja en grasas saturadas y actividad física.',
    parameters: [
      { name: 'Colesterol Total', range: '< 200',  value: '185', unit: 'mg/dL', status: 'Normal' },
      { name: 'HDL (Bueno)',      range: '> 40',   value: '55',  unit: 'mg/dL', status: 'Normal' },
      { name: 'LDL (Malo)',       range: '< 130',  value: '120', unit: 'mg/dL', status: 'Normal' },
      { name: 'Trigliceridos',    range: '< 150',  value: '165', unit: 'mg/dL', status: 'Alto'   },
      { name: 'VLDL',             range: '2 – 30', value: '33',  unit: 'mg/dL', status: 'Alto'   },
    ],
  },
  'Electrocardiograma': {
    interpretation: 'Ritmo sinusal normal. Frecuencia cardiaca de 72 lpm. Eje eléctrico normal. No se evidencian alteraciones del segmento ST ni cambios en la onda T. Intervalo QT dentro de límites normales.',
    isImage: true,
    imageFindings: [
      { finding: 'Ritmo cardiaco',     result: 'Sinusal regular, 72 lpm',              status: 'Normal' },
      { finding: 'Eje eléctrico',      result: 'Normal, +60 grados',                   status: 'Normal' },
      { finding: 'Segmento ST',        result: 'Sin elevaciones ni depresiones',        status: 'Normal' },
      { finding: 'Onda T',             result: 'Morfología normal en todas derivaciones', status: 'Normal' },
      { finding: 'Intervalo QT',       result: 'QTc 420 ms (normal < 450 ms)',          status: 'Normal' },
    ],
  },
  'Examen de Piel': {
    interpretation: 'Piel con textura y coloración normales para la edad del paciente. No se observan lesiones sospechosas, cambios pigmentarios anormales ni signos de patología dermatológica activa.',
    isImage: true,
    imageFindings: [
      { finding: 'Coloracion',       result: 'Homogenea, sin manchas ni eritema generalizado', status: 'Normal' },
      { finding: 'Textura',          result: 'Normal, sin descamacion ni hiperqueratosis',     status: 'Normal' },
      { finding: 'Lesiones',         result: 'Sin lesiones malignas ni sospechosas',           status: 'Normal' },
      { finding: 'Hidratacion',      result: 'Adecuada, sin signos de xerosis',                status: 'Normal' },
    ],
  },
  'Agudeza Visual': {
    interpretation: 'Agudeza visual bilateral dentro de parámetros normales. No se requiere corrección óptica adicional. Fondo de ojo sin hallazgos patológicos.',
    isImage: true,
    imageFindings: [
      { finding: 'Ojo derecho (OD)',   result: '20/20 - Vision normal sin correccion',    status: 'Normal' },
      { finding: 'Ojo izquierdo (OI)', result: '20/25 - Vision normal',                   status: 'Normal' },
      { finding: 'Fondo de ojo',       result: 'Sin edema de papila ni lesiones retinales', status: 'Normal' },
      { finding: 'Presion intraocular',result: 'OD: 14 mmHg / OI: 15 mmHg (normal)',      status: 'Normal' },
    ],
  },
  'Hemograma Pediátrico': {
    interpretation: 'Hemograma pediátrico con valores acordes a la edad del paciente. Series hematológicas sin alteraciones. No se evidencia anemia ni proceso infeccioso activo.',
    parameters: [
      { name: 'Glóbulos Rojos',   range: '4.0 – 5.2',   value: '4.5',  unit: 'millones/uL', status: 'Normal' },
      { name: 'Hemoglobina',      range: '11.5 – 15.5', value: '12.8', unit: 'g/dL',        status: 'Normal' },
      { name: 'Glóbulos Blancos', range: '5.0 – 13.0',  value: '8.1',  unit: 'miles/uL',    status: 'Normal' },
      { name: 'Plaquetas',        range: '150 – 400',   value: '312',  unit: 'miles/uL',    status: 'Normal' },
    ],
  },
  'Citología Cervical': {
    interpretation: 'Citología cervical (Papanicolaou) sin alteraciones epiteliales ni signos de lesión intraepitelial. Resultado NEGATIVO para malignidad. Control en 12 meses.',
    isImage: true,
    imageFindings: [
      { finding: 'Calidad de muestra',     result: 'Satisfactoria para evaluacion',            status: 'Normal' },
      { finding: 'Celulas escamosas',       result: 'Sin lesion intraepitelial ni malignidad',  status: 'Normal' },
      { finding: 'Celulas glandulares',     result: 'Dentro de limites normales',               status: 'Normal' },
      { finding: 'Microorganismos',         result: 'Flora normal, sin infeccion evidente',     status: 'Normal' },
    ],
  },
  'Ecografía Pélvica': {
    interpretation: 'Ecografía pélvica transvaginal sin hallazgos patológicos. Útero y ovarios de morfología y tamaño normales. No se observan masas ni colecciones.',
    isImage: true,
    imageFindings: [
      { finding: 'Utero',          result: 'Tamano y morfologia normal, 7.2 x 4.1 cm',   status: 'Normal' },
      { finding: 'Ovario derecho', result: 'Normal, sin lesiones quísticas',               status: 'Normal' },
      { finding: 'Ovario izquierdo',result: 'Normal, foliculo dominante 1.4 cm',          status: 'Normal' },
      { finding: 'Endometrio',     result: '8 mm, aspecto proliferativo normal',           status: 'Normal' },
    ],
  },
  'Radiografía Ósea': {
    interpretation: 'Estudio radiológico óseo sin evidencia de fracturas, luxaciones ni lesiones líticas. Densidad ósea conservada. Espacios articulares normales.',
    isImage: true,
    imageFindings: [
      { finding: 'Alineacion osea',    result: 'Correcta, sin desviaciones ni subluxaciones', status: 'Normal' },
      { finding: 'Densidad osea',      result: 'Conservada, sin signos de osteoporosis',       status: 'Normal' },
      { finding: 'Espacios articulares', result: 'Normales, sin estrechamiento',               status: 'Normal' },
      { finding: 'Tejidos blandos',    result: 'Sin edema ni calcificaciones patologicas',     status: 'Normal' },
    ],
  },
  'Examen General': {
    interpretation: 'Examen general dentro de parámetros normales. No se observan hallazgos que requieran intervención inmediata. Se recomienda control periódico.',
    parameters: [
      { name: 'Parametro 1', range: 'Normal', value: 'Normal', unit: '', status: 'Normal' },
      { name: 'Parametro 2', range: 'Normal', value: 'Normal', unit: '', status: 'Normal' },
    ],
  },
};

// ─── Lookup helper: por ID primero, luego por nombre ─────────────────────────

function resolveExamData(
  examId: string | undefined,
  examName: string | undefined,
  examDate: string | undefined,
  examDoctor: string | undefined,
): ExamData | null {
  // Busca por nombre (cubre todos los exámenes generados dinámicamente)
  const name = examName ?? '';
  const byName = EXAM_DATA_BY_NAME[name];
  if (byName) {
    return {
      name,
      date:   examDate  ?? '',
      doctor: examDoctor ?? '',
      ...byName,
    };
  }
  return null;
}

// ─── Legacy IDs (compatibilidad hacia atrás) ──────────────────────────────────

export const EXAM_DETAILS: Record<string, ExamData> = {
  '1': { name: 'Hemograma Completo', date: '15 Abr, 2026', doctor: 'Dr. Carlos Rodriguez', ...EXAM_DATA_BY_NAME['Hemograma Completo']! },
  '2': { name: 'Perfil Lipidico',    date: '10 Abr, 2026', doctor: 'Dra. Maria Gonzalez',  ...EXAM_DATA_BY_NAME['Perfil Lipídico']!   },
  '3': { name: 'Glucosa en Ayunas',  date: '5 Abr, 2026',  doctor: 'Dr. Carlos Rodriguez', ...EXAM_DATA_BY_NAME['Glucosa en Ayunas']!  },
  '5': { name: 'Radiografia Osea',   date: '28 Mar, 2026', doctor: 'Dr. Luis Martinez',    ...EXAM_DATA_BY_NAME['Radiografía Ósea']!  },
};

// ─── Screen ───────────────────────────────────────────────────────────────────

export default function ExamDetailScreen({ route, navigation }: any) {
  const { examId, examName, examDate, examDoctor, examStatus } = route.params ?? {};
  const [downloading, setDownloading] = React.useState(false);

  // Busca por nombre primero (exámenes dinámicos), luego por ID (legacy)
  const data: ExamData | null =
    resolveExamData(examId, examName, examDate, examDoctor) ??
    EXAM_DETAILS[examId as string] ??
    null;

  const handleDownload = async () => {
    const d = data;
    const name = examName ?? d?.name ?? 'Examen';

    if (!d) {
      Alert.alert('Sin datos', 'No hay resultados disponibles para este examen.');
      return;
    }

    setDownloading(true);
    try {
      // Build text content for the report
      let content = `=========================================\n`;
      content += `   RESULTADO DE EXAMEN - MEDICITAS\n`;
      content += `=========================================\n\n`;
      content += `Examen:  ${d.name}\n`;
      content += `Fecha:   ${d.date}\n`;
      content += `Médico:  ${d.doctor}\n`;
      content += `-----------------------------------------\n\n`;

      if (d.parameters && d.parameters.length > 0) {
        content += `PARÁMETROS\n\n`;
        d.parameters.forEach(p => {
          content += `${p.name}\n`;
          content += `  Valor:         ${p.value} ${p.unit}\n`;
          content += `  Rango normal:  ${p.range}\n`;
          content += `  Estado:        ${p.status}\n\n`;
        });
      }

      if (d.isImage && d.imageFindings) {
        content += `HALLAZGOS RADIOLÓGICOS\n\n`;
        d.imageFindings.forEach(f => {
          content += `${f.finding}:\n`;
          content += `  ${f.result}\n`;
          content += `  Estado: ${f.status ?? 'Normal'}\n\n`;
        });
      }

      content += `-----------------------------------------\n\n`;
      content += `INTERPRETACIÓN MÉDICA\n\n${d.interpretation}\n\n`;
      content += `=========================================\n`;
      content += `Generado por MediCitas © 2026\n`;
      content += `Este documento es informativo.\n`;
      content += `=========================================\n`;

      await Share.share({
        title: `Resultado de ${name}`,
        message: content,
      });
    } catch (e) {
      Alert.alert('Error', 'No se pudo generar el archivo. Intenta nuevamente.');
    } finally {
      setDownloading(false);
    }
  };

  // ── Pending state — solo si NO hay datos disponibles ──
  if (examStatus === 'Pendiente' && !data) {
    return (
      <View style={styles.container}>
        <StatusBar barStyle="light-content" backgroundColor="#16a34a" />
        <View style={styles.header}>
          <View style={styles.headerTop}>
            <TouchableOpacity style={styles.backBtn} onPress={() => navigation.goBack()}>
              <Ionicons name="chevron-back" size={20} color="#fff" />
              <Text style={styles.backTxt}>Volver</Text>
            </TouchableOpacity>
          </View>
          <Text style={styles.examTitle}>{examName}</Text>
          <Text style={styles.examMeta}>{examDate}  ·  {examDoctor}</Text>
        </View>
        <View style={styles.pendingBox}>
          <View style={styles.pendingIcon}>
            <Ionicons name="time-outline" size={36} color="#94a3b8" />
          </View>
          <Text style={styles.pendingTitle}>Resultados pendientes</Text>
          <Text style={styles.pendingSub}>
            Los resultados de este examen aún no están disponibles. Te notificaremos cuando estén listos.
          </Text>
        </View>
      </View>
    );
  }

  // ── No data fallback ──
  if (!data) {
    return (
      <View style={styles.container}>
        <TouchableOpacity onPress={() => navigation.goBack()} style={styles.fallbackBack}>
          <Ionicons name="chevron-back" size={22} color="#1e293b" />
          <Text style={{ fontSize: 15, color: '#1e293b' }}>Volver</Text>
        </TouchableOpacity>
        <View style={styles.pendingBox}>
          <Ionicons name="document-outline" size={48} color="#cbd5e1" />
          <Text style={styles.pendingTitle}>Sin datos disponibles</Text>
        </View>
      </View>
    );
  }

  // ── Main detail view ──
  return (
    <View style={styles.container}>
      <StatusBar barStyle="light-content" backgroundColor="#16a34a" />

      {/* Header */}
      <View style={styles.header}>
        <View style={styles.headerTop}>
          <TouchableOpacity style={styles.backBtn} onPress={() => navigation.goBack()}>
            <Ionicons name="chevron-back" size={20} color="#fff" />
            <Text style={styles.backTxt}>Volver</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.downloadBtn, downloading && { opacity: 0.6 }]}
            onPress={handleDownload}
            disabled={downloading}
          >
            {downloading
              ? <ActivityIndicator size="small" color="#fff" style={{ marginRight: 6 }} />
              : <Ionicons name="download-outline" size={15} color="#fff" />
            }
            <Text style={styles.downloadTxt}>{downloading ? 'Guardando...' : 'Descargar'}</Text>
          </TouchableOpacity>
        </View>
        <Text style={styles.examTitle}>{data.name}</Text>
        <Text style={styles.examMeta}>{data.date}  ·  {data.doctor}</Text>
      </View>

      <ScrollView style={styles.body} showsVerticalScrollIndicator={false}>

        {/* ── Radiology: findings list ── */}
        {data.isImage && data.imageFindings && (
          <>
            <Text style={styles.sectionTitle}>Hallazgos radiológicos</Text>
            {data.imageFindings.map((f, i) => {
              const st = STATUS_BADGE[f.status ?? 'Normal'];
              return (
                <View key={i} style={styles.findingCard}>
                  <View style={{ flex: 1 }}>
                    <Text style={styles.findingName}>{f.finding}</Text>
                    <Text style={styles.findingResult}>{f.result}</Text>
                  </View>
                  <View style={[styles.statusBadge, { backgroundColor: st.bg }]}>
                    <Text style={[styles.statusTxt, { color: st.text }]}>
                      {st.icon} {f.status ?? 'Normal'}
                    </Text>
                  </View>
                </View>
              );
            })}
          </>
        )}

        {/* ── Lab: parameter cards ── */}
        {!data.isImage && data.parameters?.map((p, i) => {
          const st = STATUS_BADGE[p.status];
          return (
            <View key={i} style={styles.paramCard}>
              <View style={styles.paramTop}>
                <Text style={styles.paramName}>{p.name}</Text>
                <View style={[styles.statusBadge, { backgroundColor: st.bg }]}>
                  <Text style={[styles.statusTxt, { color: st.text }]}>
                    {st.icon} {p.status}
                  </Text>
                </View>
              </View>
              <Text style={styles.paramRange}>Rango normal: {p.range}</Text>
              <Text style={styles.paramValue}>
                {p.value}
                <Text style={styles.paramUnit}> {p.unit}</Text>
              </Text>
            </View>
          );
        })}

        {/* ── Interpretación General ── */}
        <View style={styles.interpretCard}>
          <Text style={styles.interpretTitle}>Interpretación General</Text>
          <Text style={styles.interpretTxt}>{data.interpretation}</Text>
        </View>

        <View style={{ height: 36 }} />
      </ScrollView>
    </View>
  );
}

// ─── Styles ───────────────────────────────────────────────────────────────────

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f8fafc' },

  // Header
  header:      { backgroundColor: '#16a34a', paddingTop: 52, paddingHorizontal: 20, paddingBottom: 22 },
  headerTop:   { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 16 },
  backBtn:     { flexDirection: 'row', alignItems: 'center', gap: 4 },
  backTxt:     { color: '#fff', fontSize: 15, fontWeight: '600' },
  downloadBtn: {
    flexDirection: 'row', alignItems: 'center', gap: 6,
    borderWidth: 1.5, borderColor: 'rgba(255,255,255,0.65)',
    borderRadius: 20, paddingHorizontal: 14, paddingVertical: 7,
  },
  downloadTxt: { color: '#fff', fontSize: 13, fontWeight: '600' },
  examTitle:   { fontSize: 22, fontWeight: 'bold', color: '#fff', marginBottom: 6 },
  examMeta:    { fontSize: 13, color: 'rgba(255,255,255,0.80)' },

  // Body
  body:          { flex: 1, paddingHorizontal: 16 },
  sectionTitle:  { fontSize: 17, fontWeight: '700', color: '#1e293b', marginTop: 20, marginBottom: 12 },

  // Parameter cards (lab)
  paramCard:    {
    backgroundColor: '#fff', borderRadius: 14, padding: 16, marginTop: 12,
    shadowColor: '#000', shadowOffset: { width: 0, height: 1 }, shadowOpacity: 0.07, shadowRadius: 6, elevation: 2,
  },
  paramTop:     { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 6 },
  paramName:    { fontSize: 15, fontWeight: '700', color: '#1e293b', flex: 1, marginRight: 10 },
  paramRange:   { fontSize: 12, color: '#94a3b8', marginBottom: 10 },
  paramValue:   { fontSize: 32, fontWeight: 'bold', color: '#1e293b' },
  paramUnit:    { fontSize: 15, fontWeight: '400', color: '#64748b' },

  // Status badge (shared)
  statusBadge:  { paddingHorizontal: 10, paddingVertical: 5, borderRadius: 8, flexShrink: 0 },
  statusTxt:    { fontSize: 12, fontWeight: '700' },

  // Finding cards (radiology)
  findingCard:  {
    flexDirection: 'row', alignItems: 'center', gap: 12,
    backgroundColor: '#fff', borderRadius: 14, padding: 14, marginBottom: 10,
    shadowColor: '#000', shadowOffset: { width: 0, height: 1 }, shadowOpacity: 0.06, shadowRadius: 4, elevation: 1,
  },
  findingName:  { fontSize: 14, fontWeight: '700', color: '#1e293b', marginBottom: 3 },
  findingResult:{ fontSize: 13, color: '#64748b' },

  // Interpretation
  interpretCard: {
    backgroundColor: '#eff6ff', borderRadius: 14, padding: 16, marginTop: 16,
  },
  interpretTitle:{ fontSize: 15, fontWeight: '700', color: '#1e40af', marginBottom: 8 },
  interpretTxt:  { fontSize: 13, color: '#1e40af', lineHeight: 21 },

  // Pending / empty states
  pendingBox:   { flex: 1, alignItems: 'center', justifyContent: 'center', padding: 36, gap: 14 },
  pendingIcon:  {
    width: 80, height: 80, borderRadius: 40, backgroundColor: '#f1f5f9',
    alignItems: 'center', justifyContent: 'center',
  },
  pendingTitle: { fontSize: 20, fontWeight: '700', color: '#1e293b' },
  pendingSub:   { fontSize: 14, color: '#94a3b8', textAlign: 'center', lineHeight: 22 },
  fallbackBack: { flexDirection: 'row', alignItems: 'center', padding: 16, paddingTop: 52, gap: 4 },
});
