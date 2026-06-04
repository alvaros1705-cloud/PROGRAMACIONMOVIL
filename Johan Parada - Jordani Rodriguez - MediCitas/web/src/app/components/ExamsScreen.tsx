import { FileText, Download, Eye, Calendar, TrendingUp, TrendingDown, Minus, ChevronLeft, Search } from "lucide-react";
import { Button } from "./ui/button";
import { Card, CardContent } from "./ui/card";
import { Badge } from "./ui/badge";
import { Input } from "./ui/input";
import { useState } from "react";
import BottomNav from "./BottomNav";

interface ExamsScreenProps {
  onNavigate: (screen: string) => void;
}

export default function ExamsScreen({ onNavigate }: ExamsScreenProps) {
  const [selectedExam, setSelectedExam] = useState<number | null>(null);

  const exams = [
    {
      id: 1,
      name: "Hemograma Completo",
      date: "15 Abr, 2026",
      doctor: "Dr. Carlos Rodríguez",
      status: "available",
      type: "Sangre",
      results: [
        { parameter: "Glóbulos Rojos", value: "4.8", unit: "millones/µL", range: "4.5 - 5.5", status: "normal" },
        { parameter: "Glóbulos Blancos", value: "7.2", unit: "miles/µL", range: "4.0 - 11.0", status: "normal" },
        { parameter: "Hemoglobina", value: "14.5", unit: "g/dL", range: "13.5 - 17.5", status: "normal" },
        { parameter: "Plaquetas", value: "245", unit: "miles/µL", range: "150 - 400", status: "normal" }
      ]
    },
    {
      id: 2,
      name: "Perfil Lipídico",
      date: "10 Abr, 2026",
      doctor: "Dra. María González",
      status: "available",
      type: "Sangre",
      results: [
        { parameter: "Colesterol Total", value: "215", unit: "mg/dL", range: "< 200", status: "high" },
        { parameter: "HDL (Colesterol Bueno)", value: "55", unit: "mg/dL", range: "> 40", status: "normal" },
        { parameter: "LDL (Colesterol Malo)", value: "140", unit: "mg/dL", range: "< 100", status: "high" },
        { parameter: "Triglicéridos", value: "165", unit: "mg/dL", range: "< 150", status: "high" }
      ]
    },
    {
      id: 3,
      name: "Glucosa en Ayunas",
      date: "5 Abr, 2026",
      doctor: "Dr. Carlos Rodríguez",
      status: "available",
      type: "Sangre",
      results: [
        { parameter: "Glucosa", value: "92", unit: "mg/dL", range: "70 - 100", status: "normal" }
      ]
    },
    {
      id: 4,
      name: "Radiografía de Tórax",
      date: "28 Mar, 2026",
      doctor: "Dr. Luis Martínez",
      status: "available",
      type: "Imagen",
      results: []
    },
    {
      id: 5,
      name: "Examen de Orina",
      date: "20 May, 2026",
      doctor: "Dra. Ana Ramírez",
      status: "pending",
      type: "Orina",
      results: []
    }
  ];

  if (selectedExam !== null) {
    const exam = exams.find(e => e.id === selectedExam);
    if (!exam) return null;

    return (
      <div className="min-h-screen bg-gray-50">
        {/* Header */}
        <div className="bg-gradient-to-r from-green-600 to-emerald-600 text-white px-6 py-6 sticky top-0 z-10">
          <div className="flex items-center justify-between mb-4">
            <button onClick={() => setSelectedExam(null)} className="flex items-center space-x-2">
              <ChevronLeft className="w-6 h-6" />
              <span className="font-semibold">Volver</span>
            </button>
            <Button size="sm" variant="outline" className="bg-white text-green-600 border-white">
              <Download className="w-4 h-4 mr-1" />
              Descargar
            </Button>
          </div>
          <h1 className="text-xl font-semibold">{exam.name}</h1>
          <p className="text-sm text-white/90 mt-1">{exam.date} · {exam.doctor}</p>
        </div>

        <div className="p-6 space-y-4">
          {exam.type === "Imagen" ? (
            <Card>
              <CardContent className="p-6">
                <div className="aspect-video bg-gray-100 rounded-lg flex items-center justify-center mb-4">
                  <div className="text-center">
                    <FileText className="w-16 h-16 text-gray-400 mx-auto mb-2" />
                    <p className="text-gray-600">Imagen médica disponible</p>
                    <Button className="mt-4 bg-green-600 hover:bg-green-700">
                      <Eye className="w-4 h-4 mr-2" />
                      Ver Imagen
                    </Button>
                  </div>
                </div>
                <div className="border-t pt-4">
                  <h3 className="font-semibold mb-2">Observaciones</h3>
                  <p className="text-sm text-gray-700">
                    Campos pulmonares con adecuada expansión y transparencia.
                    No se observan infiltrados ni consolidaciones. Silueta cardíaca
                    dentro de límites normales. Estructuras óseas sin alteraciones.
                  </p>
                </div>
              </CardContent>
            </Card>
          ) : (
            <>
              {exam.results.map((result, index) => (
                <Card key={index}>
                  <CardContent className="p-4">
                    <div className="flex items-start justify-between">
                      <div className="flex-1">
                        <h3 className="font-semibold text-gray-900 mb-1">{result.parameter}</h3>
                        <p className="text-sm text-gray-600">Rango normal: {result.range}</p>
                      </div>
                      {result.status === 'normal' && (
                        <Badge className="bg-green-100 text-green-700">
                          <Minus className="w-3 h-3 mr-1" />
                          Normal
                        </Badge>
                      )}
                      {result.status === 'high' && (
                        <Badge className="bg-red-100 text-red-700">
                          <TrendingUp className="w-3 h-3 mr-1" />
                          Elevado
                        </Badge>
                      )}
                      {result.status === 'low' && (
                        <Badge className="bg-orange-100 text-orange-700">
                          <TrendingDown className="w-3 h-3 mr-1" />
                          Bajo
                        </Badge>
                      )}
                    </div>
                    <div className="mt-3 flex items-baseline space-x-2">
                      <span className="text-3xl font-bold text-gray-900">{result.value}</span>
                      <span className="text-gray-600">{result.unit}</span>
                    </div>
                  </CardContent>
                </Card>
              ))}

              <Card className="bg-blue-50 border-blue-200">
                <CardContent className="p-4">
                  <h3 className="font-semibold text-gray-900 mb-2">Interpretación General</h3>
                  <p className="text-sm text-gray-700">
                    {exam.id === 1 && "Los valores del hemograma se encuentran dentro de los rangos normales. No se observan alteraciones significativas."}
                    {exam.id === 2 && "Se observan niveles elevados de colesterol total, LDL y triglicéridos. Se recomienda seguimiento con nutrición y evaluación médica."}
                    {exam.id === 3 && "Nivel de glucosa en ayunas dentro de parámetros normales. Mantener hábitos saludables."}
                  </p>
                </CardContent>
              </Card>
            </>
          )}
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 pb-24">
      {/* Header */}
      <div className="bg-gradient-to-r from-green-600 to-emerald-600 text-white px-6 py-6 sticky top-0 z-10">
        <h1 className="text-2xl font-semibold mb-6">Mis Exámenes</h1>

        {/* Búsqueda */}
        <div className="relative">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
          <Input
            placeholder="Buscar exámenes..."
            className="pl-10 bg-white/20 border-white/30 text-white placeholder:text-white/70"
          />
        </div>
      </div>

      {/* Resumen */}
      <div className="px-6 py-4">
        <div className="grid grid-cols-2 gap-4">
          <Card>
            <CardContent className="p-4 text-center">
              <p className="text-3xl font-bold text-green-600">4</p>
              <p className="text-sm text-gray-600 mt-1">Disponibles</p>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="p-4 text-center">
              <p className="text-3xl font-bold text-orange-600">1</p>
              <p className="text-sm text-gray-600 mt-1">Pendientes</p>
            </CardContent>
          </Card>
        </div>
      </div>

      {/* Filtros */}
      <div className="px-6 py-2">
        <div className="flex items-center space-x-2 overflow-x-auto pb-2">
          <Button variant="outline" size="sm" className="border-green-600 text-green-600 bg-green-50">
            Todos
          </Button>
          <Button variant="outline" size="sm">
            Sangre
          </Button>
          <Button variant="outline" size="sm">
            Orina
          </Button>
          <Button variant="outline" size="sm">
            Imágenes
          </Button>
        </div>
      </div>

      {/* Lista de Exámenes */}
      <div className="px-6 py-4 space-y-4">
        <h2 className="font-semibold text-gray-900">Resultados Recientes</h2>

        {exams.map((exam) => (
          <Card key={exam.id} className="cursor-pointer hover:shadow-md transition-shadow">
            <CardContent className="p-4" onClick={() => exam.status === 'available' && setSelectedExam(exam.id)}>
              <div className="flex items-start justify-between mb-3">
                <div className="flex items-start space-x-3 flex-1">
                  <div className="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center flex-shrink-0">
                    <FileText className="w-6 h-6 text-green-600" />
                  </div>
                  <div className="flex-1">
                    <h3 className="font-semibold text-gray-900">{exam.name}</h3>
                    <div className="flex items-center space-x-2 mt-1">
                      <Badge variant="outline" className="text-xs">{exam.type}</Badge>
                      {exam.status === 'available' ? (
                        <Badge className="bg-green-100 text-green-700 text-xs">Disponible</Badge>
                      ) : (
                        <Badge className="bg-orange-100 text-orange-700 text-xs">Pendiente</Badge>
                      )}
                    </div>
                  </div>
                </div>
              </div>

              <div className="text-sm text-gray-600 space-y-1">
                <div className="flex items-center">
                  <Calendar className="w-4 h-4 mr-2" />
                  <span>{exam.date}</span>
                </div>
                <p className="text-xs">Ordenado por: {exam.doctor}</p>
              </div>

              {exam.status === 'available' && (
                <div className="flex items-center space-x-2 mt-4 pt-4 border-t">
                  <Button variant="outline" size="sm" className="flex-1">
                    <Eye className="w-4 h-4 mr-1" />
                    Ver Resultados
                  </Button>
                  <Button variant="outline" size="sm">
                    <Download className="w-4 h-4" />
                  </Button>
                </div>
              )}
            </CardContent>
          </Card>
        ))}
      </div>

      <BottomNav currentScreen="exams" onNavigate={onNavigate} />
    </div>
  );
}
