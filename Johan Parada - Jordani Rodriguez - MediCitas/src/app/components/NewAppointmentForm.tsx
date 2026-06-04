import { ChevronLeft, Calendar as CalendarIcon, Clock, User, MapPin, Check } from "lucide-react";
import { Button } from "./ui/button";
import { Card, CardContent } from "./ui/card";
import { Badge } from "./ui/badge";
import { toast } from "sonner";
import { useState } from "react";

interface NewAppointmentFormProps {
  onClose: () => void;
  onSuccess: () => void;
}

export default function NewAppointmentForm({ onClose, onSuccess }: NewAppointmentFormProps) {
  const [step, setStep] = useState(1);
  const [selectedSpecialty, setSelectedSpecialty] = useState("");
  const [selectedDoctor, setSelectedDoctor] = useState("");
  const [selectedDate, setSelectedDate] = useState("");
  const [selectedTime, setSelectedTime] = useState("");
  const [selectedLocation, setSelectedLocation] = useState("");

  const specialties = [
    { name: "Medicina General", icon: "🩺", color: "blue" },
    { name: "Cardiología", icon: "❤️", color: "red" },
    { name: "Dermatología", icon: "✨", color: "pink" },
    { name: "Oftalmología", icon: "👁️", color: "purple" },
    { name: "Pediatría", icon: "👶", color: "green" },
    { name: "Ginecología", icon: "🌸", color: "rose" },
    { name: "Traumatología", icon: "🦴", color: "orange" },
    { name: "Psiquiatría", icon: "🧠", color: "indigo" }
  ];

  const doctors = {
    "Medicina General": [
      { name: "Dr. Carlos Rodríguez", rating: 4.8, experience: "15 años", available: true },
      { name: "Dra. Patricia López", rating: 4.9, experience: "12 años", available: true },
      { name: "Dr. Roberto Sánchez", rating: 4.7, experience: "10 años", available: false }
    ],
    "Cardiología": [
      { name: "Dra. María González", rating: 4.9, experience: "20 años", available: true },
      { name: "Dr. Roberto Sánchez", rating: 4.8, experience: "18 años", available: true }
    ],
    "Dermatología": [
      { name: "Dr. Luis Martínez", rating: 4.7, experience: "14 años", available: true },
      { name: "Dra. Carmen Díaz", rating: 4.9, experience: "16 años", available: true }
    ],
    "Oftalmología": [
      { name: "Dra. Ana Ramírez", rating: 4.8, experience: "13 años", available: true },
      { name: "Dr. Jorge Castro", rating: 4.6, experience: "11 años", available: true }
    ]
  };

  const locations: Record<string, string[]> = {
    "Dr. Carlos Rodríguez": ["Clínica del Norte - Piso 3", "Centro Médico Sur - Consultorio 201"],
    "Dra. Patricia López": ["Clínica del Norte - Piso 2", "Hospital San José - Consultorio 105"],
    "Dr. Roberto Sánchez": ["Centro Médico Sur - Piso 1", "Clínica Central - Consultorio 302"],
    "Dra. María González": ["Hospital Central - Consultorio 205", "Clínica Cardio - Piso 2"],
    "Dr. Luis Martínez": ["Centro Médico Sur - Piso 2", "Clínica Derma - Consultorio 301"],
    "Dra. Carmen Díaz": ["Clínica Derma - Piso 3", "Hospital Central - Consultorio 410"],
    "Dra. Ana Ramírez": ["Clínica Visual - Consultorio 101", "Centro Médico Visión - Piso 2"],
    "Dr. Jorge Castro": ["Clínica Visual - Consultorio 103", "Hospital San José - Oftalmología"]
  };

  // Generate next 14 days
  const generateAvailableDates = () => {
    const dates = [];
    const today = new Date();
    for (let i = 1; i <= 14; i++) {
      const date = new Date(today);
      date.setDate(today.getDate() + i);
      // Skip Sundays (day 0)
      if (date.getDay() !== 0) {
        dates.push(date);
      }
    }
    return dates;
  };

  const availableDates = generateAvailableDates();

  // Generate time slots based on selected date
  const generateTimeSlots = (date: string) => {
    if (!date) return [];

    const selectedDay = new Date(date).getDay();
    const isSaturday = selectedDay === 6;

    const morningSlots = ["8:00 AM", "9:00 AM", "10:00 AM", "11:00 AM"];
    const afternoonSlots = isSaturday ? [] : ["2:00 PM", "3:00 PM", "4:00 PM", "5:00 PM"];

    // Simulate some occupied slots
    const occupiedSlots = ["10:00 AM", "3:00 PM"];

    return [...morningSlots, ...afternoonSlots].map(time => ({
      time,
      available: !occupiedSlots.includes(time)
    }));
  };

  const timeSlots = generateTimeSlots(selectedDate);

  const handleConfirm = () => {
    toast.success("¡Cita agendada exitosamente!", {
      description: `Tu cita con ${selectedDoctor} está confirmada para el ${new Date(selectedDate).toLocaleDateString('es-ES', { day: 'numeric', month: 'long' })} a las ${selectedTime}`,
      duration: 4000,
    });
    onSuccess();
    setTimeout(() => {
      onClose();
    }, 500);
  };

  const formatDate = (date: Date) => {
    return date.toLocaleDateString('es-ES', {
      weekday: 'short',
      day: 'numeric',
      month: 'short'
    });
  };

  const isDateSelected = (date: Date) => {
    return selectedDate === date.toISOString().split('T')[0];
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-gradient-to-r from-blue-600 to-cyan-600 text-white px-6 py-6 sticky top-0 z-10">
        <div className="flex items-center justify-between mb-4">
          <button onClick={onClose} className="flex items-center space-x-2">
            <ChevronLeft className="w-6 h-6" />
            <span className="font-semibold">Volver</span>
          </button>
          <div className="flex items-center space-x-2">
            <div className={`w-8 h-8 rounded-full flex items-center justify-center ${
              step >= 1 ? 'bg-white text-blue-600' : 'bg-white/30 text-white'
            }`}>
              {step > 1 ? <Check className="w-4 h-4" /> : '1'}
            </div>
            <div className={`w-8 h-1 ${step >= 2 ? 'bg-white' : 'bg-white/30'}`}></div>
            <div className={`w-8 h-8 rounded-full flex items-center justify-center ${
              step >= 2 ? 'bg-white text-blue-600' : 'bg-white/30 text-white'
            }`}>
              {step > 2 ? <Check className="w-4 h-4" /> : '2'}
            </div>
            <div className={`w-8 h-1 ${step >= 3 ? 'bg-white' : 'bg-white/30'}`}></div>
            <div className={`w-8 h-8 rounded-full flex items-center justify-center ${
              step >= 3 ? 'bg-white text-blue-600' : 'bg-white/30 text-white'
            }`}>
              {step > 3 ? <Check className="w-4 h-4" /> : '3'}
            </div>
          </div>
        </div>
        <h1 className="text-xl font-semibold">
          {step === 1 && "Selecciona la especialidad"}
          {step === 2 && "Elige tu médico"}
          {step === 3 && "Fecha y hora"}
          {step === 4 && "Confirmar cita"}
        </h1>
      </div>

      <div className="p-6 space-y-4">
        {/* Step 1: Specialty Selection */}
        {step === 1 && (
          <div className="grid grid-cols-2 gap-3">
            {specialties.map((specialty) => (
              <button
                key={specialty.name}
                onClick={() => {
                  setSelectedSpecialty(specialty.name);
                  setSelectedDoctor("");
                  setStep(2);
                }}
                className={`p-4 rounded-xl border-2 text-left transition-all hover:shadow-md ${
                  selectedSpecialty === specialty.name
                    ? 'border-blue-600 bg-blue-50'
                    : 'border-gray-200 hover:border-blue-300 bg-white'
                }`}
              >
                <div className="text-3xl mb-2">{specialty.icon}</div>
                <p className="font-medium text-gray-900 text-sm">{specialty.name}</p>
              </button>
            ))}
          </div>
        )}

        {/* Step 2: Doctor Selection */}
        {step === 2 && selectedSpecialty && (
          <div className="space-y-3">
            {doctors[selectedSpecialty as keyof typeof doctors]?.map((doctor) => (
              <Card
                key={doctor.name}
                className={`cursor-pointer transition-all ${
                  !doctor.available ? 'opacity-50' : 'hover:shadow-md'
                } ${selectedDoctor === doctor.name ? 'border-2 border-blue-600 bg-blue-50' : ''}`}
                onClick={() => {
                  if (doctor.available) {
                    setSelectedDoctor(doctor.name);
                  }
                }}
              >
                <CardContent className="p-4">
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <div className="flex items-center space-x-2 mb-1">
                        <h3 className="font-semibold text-gray-900">{doctor.name}</h3>
                        {doctor.available ? (
                          <Badge className="bg-green-100 text-green-700">Disponible</Badge>
                        ) : (
                          <Badge variant="outline" className="text-gray-500">No disponible</Badge>
                        )}
                      </div>
                      <p className="text-sm text-gray-600 mb-2">{selectedSpecialty}</p>
                      <div className="flex items-center space-x-4 text-xs text-gray-500">
                        <div className="flex items-center space-x-1">
                          <span className="text-yellow-500">⭐</span>
                          <span>{doctor.rating}</span>
                        </div>
                        <div>{doctor.experience} de experiencia</div>
                      </div>
                    </div>
                    {selectedDoctor === doctor.name && (
                      <div className="w-6 h-6 bg-blue-600 rounded-full flex items-center justify-center">
                        <Check className="w-4 h-4 text-white" />
                      </div>
                    )}
                  </div>
                </CardContent>
              </Card>
            ))}

            {selectedDoctor && (
              <Button
                onClick={() => setStep(3)}
                className="w-full bg-blue-600 hover:bg-blue-700 h-12"
              >
                Continuar
              </Button>
            )}
          </div>
        )}

        {/* Step 3: Date and Time Selection */}
        {step === 3 && (
          <div className="space-y-6">
            {/* Date Selection */}
            <div>
              <label className="block text-sm font-semibold text-gray-700 mb-3">
                Selecciona el día
              </label>
              <div className="grid grid-cols-4 gap-2">
                {availableDates.map((date, index) => (
                  <button
                    key={index}
                    onClick={() => {
                      setSelectedDate(date.toISOString().split('T')[0]);
                      setSelectedTime("");
                    }}
                    className={`p-3 rounded-lg border-2 text-center transition-all ${
                      isDateSelected(date)
                        ? 'border-blue-600 bg-blue-600 text-white'
                        : 'border-gray-200 hover:border-blue-300 bg-white'
                    }`}
                  >
                    <div className="text-xs opacity-70">
                      {date.toLocaleDateString('es-ES', { weekday: 'short' })}
                    </div>
                    <div className="text-lg font-semibold mt-1">
                      {date.getDate()}
                    </div>
                    <div className="text-xs opacity-70">
                      {date.toLocaleDateString('es-ES', { month: 'short' })}
                    </div>
                  </button>
                ))}
              </div>
            </div>

            {/* Time Selection */}
            {selectedDate && (
              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-3">
                  Selecciona la hora
                </label>
                <div className="grid grid-cols-4 gap-2">
                  {timeSlots.map((slot) => (
                    <button
                      key={slot.time}
                      onClick={() => slot.available && setSelectedTime(slot.time)}
                      disabled={!slot.available}
                      className={`p-3 rounded-lg border-2 text-sm font-medium transition-all ${
                        !slot.available
                          ? 'border-gray-200 bg-gray-100 text-gray-400 cursor-not-allowed'
                          : selectedTime === slot.time
                          ? 'border-blue-600 bg-blue-600 text-white'
                          : 'border-gray-200 hover:border-blue-300 bg-white text-gray-700'
                      }`}
                    >
                      {slot.time}
                    </button>
                  ))}
                </div>
                {timeSlots.some(s => !s.available) && (
                  <p className="text-xs text-gray-500 mt-2">
                    Los horarios en gris no están disponibles
                  </p>
                )}
              </div>
            )}

            {/* Location Selection */}
            {selectedTime && (
              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-3">
                  Selecciona la ubicación
                </label>
                <div className="space-y-2">
                  {locations[selectedDoctor as keyof typeof locations]?.map((location) => (
                    <button
                      key={location}
                      onClick={() => {
                        setSelectedLocation(location);
                        setStep(4);
                      }}
                      className={`w-full p-4 rounded-lg border-2 text-left transition-all ${
                        selectedLocation === location
                          ? 'border-blue-600 bg-blue-50'
                          : 'border-gray-200 hover:border-blue-300 bg-white'
                      }`}
                    >
                      <div className="flex items-center space-x-3">
                        <MapPin className="w-5 h-5 text-gray-400" />
                        <span className="text-sm font-medium text-gray-900">{location}</span>
                      </div>
                    </button>
                  ))}
                </div>
              </div>
            )}
          </div>
        )}

        {/* Step 4: Confirmation */}
        {step === 4 && (
          <div className="space-y-6">
            <Card className="border-2 border-blue-200">
              <CardContent className="p-6">
                <div className="text-center mb-6">
                  <div className="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-3">
                    <CalendarIcon className="w-8 h-8 text-blue-600" />
                  </div>
                  <h2 className="text-xl font-semibold text-gray-900 mb-2">Confirma tu cita</h2>
                  <p className="text-sm text-gray-600">Revisa los detalles antes de confirmar</p>
                </div>

                <div className="space-y-4">
                  <div className="flex items-start space-x-3 p-4 bg-gray-50 rounded-lg">
                    <div className="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center flex-shrink-0">
                      <User className="w-5 h-5 text-blue-600" />
                    </div>
                    <div>
                      <p className="text-xs text-gray-600">Médico</p>
                      <p className="font-semibold text-gray-900">{selectedDoctor}</p>
                      <p className="text-sm text-gray-600">{selectedSpecialty}</p>
                    </div>
                  </div>

                  <div className="flex items-start space-x-3 p-4 bg-gray-50 rounded-lg">
                    <div className="w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center flex-shrink-0">
                      <CalendarIcon className="w-5 h-5 text-green-600" />
                    </div>
                    <div>
                      <p className="text-xs text-gray-600">Fecha y hora</p>
                      <p className="font-semibold text-gray-900">
                        {new Date(selectedDate).toLocaleDateString('es-ES', {
                          weekday: 'long',
                          day: 'numeric',
                          month: 'long',
                          year: 'numeric'
                        })}
                      </p>
                      <p className="text-sm text-gray-600">{selectedTime}</p>
                    </div>
                  </div>

                  <div className="flex items-start space-x-3 p-4 bg-gray-50 rounded-lg">
                    <div className="w-10 h-10 bg-purple-100 rounded-lg flex items-center justify-center flex-shrink-0">
                      <MapPin className="w-5 h-5 text-purple-600" />
                    </div>
                    <div>
                      <p className="text-xs text-gray-600">Ubicación</p>
                      <p className="font-semibold text-gray-900">{selectedLocation}</p>
                    </div>
                  </div>
                </div>

                <div className="mt-6 p-4 bg-blue-50 rounded-lg border border-blue-200">
                  <p className="text-sm text-gray-700">
                    <span className="font-semibold">Recordatorio:</span> Por favor llega 15 minutos antes de tu cita.
                    Trae tu documento de identidad y carnet de la EPS.
                  </p>
                </div>
              </CardContent>
            </Card>

            <div className="flex space-x-3">
              <Button
                onClick={() => setStep(3)}
                variant="outline"
                className="flex-1"
              >
                Regresar
              </Button>
              <Button
                onClick={handleConfirm}
                className="flex-1 bg-blue-600 hover:bg-blue-700 h-12"
              >
                Confirmar Cita
              </Button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
