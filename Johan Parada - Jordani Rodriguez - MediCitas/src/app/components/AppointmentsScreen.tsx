import { Calendar, Clock, MapPin, Search, Filter, Plus, ChevronLeft, X } from "lucide-react";
import { Button } from "./ui/button";
import { Card, CardContent } from "./ui/card";
import { Badge } from "./ui/badge";
import { Input } from "./ui/input";
import { useState, useEffect } from "react";
import BottomNav from "./BottomNav";
import NewAppointmentForm from "./NewAppointmentForm";

interface AppointmentsScreenProps {
  onNavigate: (screen: string) => void;
  openNew?: boolean;
  onCloseNew?: () => void;
}

export default function AppointmentsScreen({ onNavigate, openNew = false, onCloseNew }: AppointmentsScreenProps) {
  const [showNewAppointment, setShowNewAppointment] = useState(openNew);
  const [selectedAppointment, setSelectedAppointment] = useState<number | null>(null);
  const [appointments, setAppointments] = useState(() => [
    {
      id: 1,
      specialty: "Medicina General",
      doctor: "Dr. Carlos Rodríguez",
      date: "25 Abr, 2026",
      time: "10:30 AM",
      location: "Clínica del Norte, Piso 3",
      status: "confirmed",
      color: "blue"
    },
    {
      id: 2,
      specialty: "Cardiología",
      doctor: "Dra. María González",
      date: "2 May, 2026",
      time: "3:00 PM",
      location: "Hospital Central, Consultorio 205",
      status: "pending",
      color: "purple"
    },
    {
      id: 3,
      specialty: "Dermatología",
      doctor: "Dr. Luis Martínez",
      date: "8 May, 2026",
      time: "11:00 AM",
      location: "Centro Médico Sur, Piso 2",
      status: "confirmed",
      color: "pink"
    },
    {
      id: 4,
      specialty: "Oftalmología",
      doctor: "Dra. Ana Ramírez",
      date: "15 Abr, 2026",
      time: "2:00 PM",
      location: "Clínica Visual, Consultorio 101",
      status: "completed",
      color: "green"
    }
  ]);

  const handleCloseForm = () => {
    setShowNewAppointment(false);
    if (onCloseNew) {
      onCloseNew();
    }
  };

  const handleSuccess = () => {
    console.log("Cita agendada exitosamente");
  };

  const handleCancelAppointment = (id: number) => {
    setAppointments((prev) =>
      prev.map((appointment) =>
        appointment.id === id ? { ...appointment, status: 'cancelled' } : appointment
      )
    );
    setSelectedAppointment(null);
  };

  const selectedAppointmentData = selectedAppointment
    ? appointments.find((appointment) => appointment.id === selectedAppointment)
    : null;

  if (showNewAppointment) {
    return <NewAppointmentForm onClose={handleCloseForm} onSuccess={handleSuccess} />;
  }

  if (selectedAppointmentData) {
    return (
      <div className="min-h-screen bg-gray-50 pb-24">
        <div className="bg-gradient-to-r from-blue-600 to-cyan-600 text-white px-6 py-6 sticky top-0 z-10">
          <button
            className="flex items-center space-x-2 mb-4"
            onClick={() => setSelectedAppointment(null)}
          >
            <ChevronLeft className="w-6 h-6" />
            <span>Volver a citas</span>
          </button>
          <h1 className="text-2xl font-semibold">Detalle de Cita</h1>
        </div>

        <div className="px-6 py-6">
          <Card className="border-l-4 border-l-blue-600">
            <CardContent className="p-6">
              <div className="flex items-start justify-between">
                <div>
                  <h2 className="text-xl font-semibold text-gray-900">{selectedAppointmentData.specialty}</h2>
                  <p className="text-sm text-gray-600 mt-2">{selectedAppointmentData.doctor}</p>
                </div>
                <Badge
                  className={`${
                    selectedAppointmentData.status === 'cancelled' ? 'bg-gray-100 text-gray-700' : 'bg-blue-100 text-blue-700'
                  }`}
                >
                  {selectedAppointmentData.status === 'cancelled'
                    ? 'Cancelada'
                    : selectedAppointmentData.status === 'confirmed'
                    ? 'Confirmada'
                    : 'Pendiente'}
                </Badge>
              </div>

              <div className="mt-6 space-y-3 text-gray-700">
                <p>
                  <strong>Fecha:</strong> {selectedAppointmentData.date}
                </p>
                <p>
                  <strong>Hora:</strong> {selectedAppointmentData.time}
                </p>
                <p>
                  <strong>Ubicación:</strong> {selectedAppointmentData.location}
                </p>
                <p>
                  <strong>Médico:</strong> {selectedAppointmentData.doctor}
                </p>
              </div>

              <div className="flex flex-col gap-3 mt-6 md:flex-row">
                {selectedAppointmentData.status !== 'completed' && (
                  <Button
                    className="flex-1 bg-red-600 hover:bg-red-700"
                    onClick={() => handleCancelAppointment(selectedAppointmentData.id)}
                  >
                    Cancelar cita
                  </Button>
                )}
                <Button
                  variant="outline"
                  className="flex-1"
                  onClick={() => setSelectedAppointment(null)}
                >
                  Volver
                </Button>
              </div>
            </CardContent>
          </Card>
        </div>

        <BottomNav currentScreen="appointments" onNavigate={onNavigate} />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 pb-24">
      {/* Header */}
      <div className="bg-gradient-to-r from-blue-600 to-cyan-600 text-white px-6 py-6 sticky top-0 z-10">
        <div className="flex items-center justify-between mb-6">
          <h1 className="text-2xl font-semibold">Mis Citas</h1>
          <Button
            onClick={() => {
              setShowNewAppointment(true);
            }}
            className="bg-white text-blue-600 hover:bg-blue-50 rounded-full h-10 px-4"
          >
            <Plus className="w-5 h-5 mr-1" />
            Nueva
          </Button>
        </div>

        {/* Búsqueda */}
        <div className="relative">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
          <Input
            placeholder="Buscar citas..."
            className="pl-10 bg-white/20 border-white/30 text-white placeholder:text-white/70"
          />
        </div>
      </div>

      {/* Filtros */}
      <div className="px-6 py-4 bg-white border-b">
        <div className="flex items-center space-x-2 overflow-x-auto">
          <Button variant="outline" size="sm" className="border-blue-600 text-blue-600 bg-blue-50">
            Todas
          </Button>
          <Button variant="outline" size="sm">
            Próximas
          </Button>
          <Button variant="outline" size="sm">
            Completadas
          </Button>
          <Button variant="outline" size="sm">
            Canceladas
          </Button>
        </div>
      </div>

      {/* Lista de Citas */}
      <div className="px-6 py-4 space-y-4">
        {appointments.map((appointment) => (
          <Card key={appointment.id} className={`border-l-4 border-l-${appointment.color}-600`}>
            <CardContent className="p-4">
              <div className="flex items-start justify-between mb-3">
                <div className="flex-1">
                  <div className="flex items-center space-x-2 mb-2">
                    <Badge className={`bg-${appointment.color}-100 text-${appointment.color}-700 hover:bg-${appointment.color}-100`}>
                      {appointment.specialty}
                    </Badge>
                    {appointment.status === 'confirmed' && (
                      <Badge variant="outline" className="text-green-600 border-green-600">Confirmada</Badge>
                    )}
                    {appointment.status === 'pending' && (
                      <Badge variant="outline" className="text-orange-600 border-orange-600">Pendiente</Badge>
                    )}
                    {appointment.status === 'completed' && (
                      <Badge variant="outline" className="text-gray-600 border-gray-600">Completada</Badge>
                    )}
                  </div>
                  <h3 className="font-semibold text-gray-900 text-lg">{appointment.doctor}</h3>
                </div>
              </div>

              <div className="space-y-2">
                <div className="flex items-center text-sm text-gray-600">
                  <Calendar className="w-4 h-4 mr-2" />
                  <span>{appointment.date}</span>
                  <Clock className="w-4 h-4 ml-4 mr-2" />
                  <span>{appointment.time}</span>
                </div>
                <div className="flex items-center text-sm text-gray-600">
                  <MapPin className="w-4 h-4 mr-2" />
                  <span>{appointment.location}</span>
                </div>
              </div>

              <div className="flex items-center space-x-2 mt-4 pt-4 border-t">
                <Button
                  variant="outline"
                  size="sm"
                  className="flex-1"
                  onClick={() => setSelectedAppointment(appointment.id)}
                >
                  Ver Detalles
                </Button>
                {appointment.status !== 'completed' && (
                  <Button
                    variant="outline"
                    size="sm"
                    className="text-red-600 border-red-600"
                    onClick={() => handleCancelAppointment(appointment.id)}
                  >
                    Cancelar
                  </Button>
                )}
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      <BottomNav currentScreen="appointments" onNavigate={onNavigate} />
    </div>
  );
}
