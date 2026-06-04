import { useState } from 'react';
import { Pill, Clock, Calendar, Bell, Plus, Check } from "lucide-react";
import { Button } from "./ui/button";
import { Card, CardContent } from "./ui/card";
import { Badge } from "./ui/badge";
import { Input } from "./ui/input";
import BottomNav from "./BottomNav";

interface MedicationsScreenProps {
  onNavigate: (screen: string) => void;
}

export default function MedicationsScreen({ onNavigate }: MedicationsScreenProps) {
  const [medications, setMedications] = useState([
    {
      id: 1,
      name: "Losartán",
      dosage: "50mg",
      frequency: "1 vez al día",
      times: ["8:00 AM"],
      duration: "Continuo",
      doctor: "Dra. María González",
      purpose: "Control de presión arterial",
      startDate: "10 Ene, 2026",
      active: true,
      taken: [true, false, false]
    },
    {
      id: 2,
      name: "Atorvastatina",
      dosage: "20mg",
      frequency: "1 vez al día",
      times: ["10:00 PM"],
      duration: "Continuo",
      doctor: "Dra. María González",
      purpose: "Control de colesterol",
      startDate: "10 Ene, 2026",
      active: true,
      taken: [true, true, false]
    },
    {
      id: 3,
      name: "Omeprazol",
      dosage: "20mg",
      frequency: "2 veces al día",
      times: ["8:00 AM", "8:00 PM"],
      duration: "30 días",
      doctor: "Dr. Carlos Rodríguez",
      purpose: "Protección gástrica",
      startDate: "1 May, 2026",
      endDate: "31 May, 2026",
      active: true,
      taken: [true, false, true]
    },
    {
      id: 4,
      name: "Ibuprofeno",
      dosage: "400mg",
      frequency: "Cada 8 horas si hay dolor",
      times: ["Según necesidad"],
      duration: "10 días",
      doctor: "Dr. Luis Martínez",
      purpose: "Antiinflamatorio",
      startDate: "3 May, 2026",
      endDate: "13 May, 2026",
      active: true,
      taken: [false, false, true]
    }
  ]);

  const [showAddForm, setShowAddForm] = useState(false);
  const [newName, setNewName] = useState("");
  const [newDosage, setNewDosage] = useState("");
  const [newFrequency, setNewFrequency] = useState("1 vez al día");
  const [newTime, setNewTime] = useState("");
  const [todaySchedule, setTodaySchedule] = useState([
    { id: 1, medication: "Losartán 50mg", time: "8:00 AM", taken: true },
    { id: 2, medication: "Omeprazol 20mg", time: "8:00 AM", taken: true },
    { id: 3, medication: "Omeprazol 20mg", time: "8:00 PM", taken: false },
    { id: 4, medication: "Atorvastatina 20mg", time: "10:00 PM", taken: false }
  ]);

  const handleAddMedication = () => {
    if (!newName.trim()) return;
    setMedications((prev) => [
      {
        id: prev.length + 1,
        name: newName.trim(),
        dosage: newDosage || "10mg",
        frequency: newFrequency,
        times: [newTime || "8:00 AM"],
        duration: "Continuo",
        doctor: "Equipo Médico",
        purpose: "Registro de medicamento",
        startDate: "Hoy",
        active: true,
        taken: [false]
      },
      ...prev,
    ]);
    setNewName("");
    setNewDosage("");
    setNewTime("");
    setShowAddForm(false);
  };

  const handleToggleTaken = (id: number, index: number) => {
    setMedications((prev) =>
      prev.map((med) => {
        if (med.id !== id) return med;
        const updatedTaken = [...med.taken];
        updatedTaken[index] = !updatedTaken[index];
        return { ...med, taken: updatedTaken };
      })
    );
  };

  const handleToggleScheduleTaken = (id: number) => {
    setTodaySchedule((prev) =>
      prev.map((entry) =>
        entry.id === id ? { ...entry, taken: !entry.taken } : entry
      )
    );
  };

  return (
    <div className="min-h-screen bg-gray-50 pb-24">
      {/* Header */}
      <div className="bg-gradient-to-r from-blue-600 to-purple-600 text-white px-6 py-6 sticky top-0 z-10">
        <div className="flex items-center justify-between mb-6">
          <h1 className="text-2xl font-semibold">Mis Medicamentos</h1>
          <Button
            className="bg-white text-blue-600 hover:bg-blue-50 rounded-full h-10 px-4"
            onClick={() => setShowAddForm((prev) => !prev)}
          >
            <Plus className="w-5 h-5 mr-1" />
            {showAddForm ? 'Cerrar' : 'Agregar'}
          </Button>
        </div>

        {showAddForm && (
          <div className="mb-6 bg-white/20 rounded-3xl p-4 text-black shadow-sm">
            <h2 className="text-lg font-semibold mb-4">Agregar medicamento</h2>
            <div className="grid gap-3">
              <Input
                value={newName}
                onChange={(e) => setNewName(e.target.value)}
                placeholder="Nombre del medicamento"
              />
              <Input
                value={newDosage}
                onChange={(e) => setNewDosage(e.target.value)}
                placeholder="Dosis (por ejemplo, 20mg)"
              />
              <Input
                value={newTime}
                onChange={(e) => setNewTime(e.target.value)}
                placeholder="Hora (por ejemplo, 8:00 AM)"
              />
              <Input
                value={newFrequency}
                onChange={(e) => setNewFrequency(e.target.value)}
                placeholder="Frecuencia"
              />
              <div className="flex justify-end gap-3">
                <Button variant="outline" className="border-white text-white" onClick={() => setShowAddForm(false)}>
                  Cancelar
                </Button>
                <Button onClick={handleAddMedication}>Guardar</Button>
              </div>
            </div>
          </div>
        )}

        {/* Estadísticas */}
        <div className="grid grid-cols-3 gap-3">
          <div className="bg-white/20 backdrop-blur-sm rounded-xl p-3 text-center">
            <p className="text-2xl font-bold">{medications.length}</p>
            <p className="text-xs opacity-90 mt-1">Activos</p>
          </div>
          <div className="bg-white/20 backdrop-blur-sm rounded-xl p-3 text-center">
            <p className="text-2xl font-bold">{todaySchedule.filter((item) => item.taken).length}</p>
            <p className="text-xs opacity-90 mt-1">Tomados hoy</p>
          </div>
          <div className="bg-white/20 backdrop-blur-sm rounded-xl p-3 text-center">
            <p className="text-2xl font-bold">{todaySchedule.filter((item) => !item.taken).length}</p>
            <p className="text-xs opacity-90 mt-1">Pendientes</p>
          </div>
        </div>
      </div>

      <div className="px-6 py-6 space-y-6">
        {/* Horario de Hoy */}
        <div>
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Horario de Hoy</h2>
          <div className="space-y-3">
            {todaySchedule.map((item, index) => (
              <Card key={index} className={item.taken ? 'bg-gray-50 border-gray-200' : ''}>
                <CardContent className="p-4">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center space-x-3 flex-1">
                      <div className={`w-12 h-12 rounded-xl flex items-center justify-center ${
                        item.taken ? 'bg-green-100' : 'bg-blue-100'
                      }`}>
                        {item.taken ? (
                          <Check className="w-6 h-6 text-green-600" />
                        ) : (
                          <Pill className="w-6 h-6 text-blue-600" />
                        )}
                      </div>
                      <div className="flex-1">
                        <h3 className={`font-semibold ${item.taken ? 'text-gray-500 line-through' : 'text-gray-900'}`}>
                          {item.medication}
                        </h3>
                        <div className="flex items-center text-sm text-gray-600 mt-1">
                          <Clock className="w-4 h-4 mr-1" />
                          <span>{item.time}</span>
                          {item.taken && (
                            <Badge className="ml-2 bg-green-100 text-green-700">
                              Tomado
                            </Badge>
                          )}
                        </div>
                      </div>
                    </div>
                    {!item.taken && (
                      <Button
                        size="sm"
                        className="bg-blue-600 hover:bg-blue-700"
                        onClick={() => handleToggleScheduleTaken(item.id)}
                      >
                        Marcar
                      </Button>
                    )}
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>

        {/* Mis Recetas Activas */}
        <div>
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold text-gray-900">Recetas Activas</h2>
            <button className="text-blue-600 text-sm font-medium">Ver todas</button>
          </div>

          <div className="space-y-4">
            {medications.map((med) => (
              <Card key={med.id} className="border-l-4 border-l-blue-600">
                <CardContent className="p-4">
                  <div className="flex items-start justify-between mb-3">
                    <div className="flex-1">
                      <div className="flex items-center space-x-2 mb-2">
                        <h3 className="text-lg font-semibold text-gray-900">
                          {med.name} {med.dosage}
                        </h3>
                        {med.active && (
                          <Badge className="bg-green-100 text-green-700">Activo</Badge>
                        )}
                      </div>
                      <p className="text-sm text-gray-600">{med.purpose}</p>
                    </div>
                  </div>

                  <div className="space-y-2 mb-4">
                    <div className="flex items-center text-sm text-gray-700">
                      <Clock className="w-4 h-4 mr-2 text-gray-400" />
                      <span className="font-medium mr-2">Frecuencia:</span>
                      <span>{med.frequency}</span>
                    </div>
                    <div className="flex items-center text-sm text-gray-700">
                      <Bell className="w-4 h-4 mr-2 text-gray-400" />
                      <span className="font-medium mr-2">Horarios:</span>
                      <span>{med.times.join(", ")}</span>
                    </div>
                    <div className="flex items-center text-sm text-gray-700">
                      <Calendar className="w-4 h-4 mr-2 text-gray-400" />
                      <span className="font-medium mr-2">Duración:</span>
                      <span>{med.duration}</span>
                    </div>
                  </div>

                  <div className="pt-3 border-t">
                    <p className="text-xs text-gray-600 mb-2">
                      Recetado por: {med.doctor} · {med.startDate}
                    </p>

                    {/* Progress bar */}
                    <div className="space-y-1">
                      <div className="flex items-center justify-between text-xs">
                        <span className="text-gray-600">Adherencia últimos 3 días</span>
                        <span className="font-medium text-gray-900">
                          {med.taken.filter(Boolean).length}/{med.taken.length}
                        </span>
                      </div>
                      <div className="flex items-center space-x-1">
                        {med.taken.map((taken, idx) => (
                          <div
                            key={idx}
                            className={`h-2 flex-1 rounded-full ${
                              taken ? 'bg-green-500' : 'bg-gray-200'
                            }`}
                          />
                        ))}
                      </div>
                    </div>
                  </div>

                  <div className="flex items-center space-x-2 mt-4 pt-4 border-t">
                    <Button variant="outline" size="sm" className="flex-1">
                      Ver Detalles
                    </Button>
                    <Button variant="outline" size="sm" className="text-blue-600 border-blue-600">
                      <Bell className="w-4 h-4 mr-1" />
                      Recordatorios
                    </Button>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>

        {/* Tips */}
        <Card className="bg-gradient-to-r from-blue-50 to-purple-50 border-blue-200">
          <CardContent className="p-4">
            <div className="flex items-start space-x-3">
              <div className="w-10 h-10 bg-blue-500 rounded-full flex items-center justify-center flex-shrink-0">
                <Bell className="w-5 h-5 text-white" />
              </div>
              <div>
                <h3 className="font-semibold text-gray-900 mb-1">Consejo del día</h3>
                <p className="text-sm text-gray-700">
                  Toma tus medicamentos a la misma hora todos los días para crear una rutina.
                  Esto ayuda a mejorar la adherencia al tratamiento.
                </p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      <BottomNav currentScreen="medications" onNavigate={onNavigate} />
    </div>
  );
}
