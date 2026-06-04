import { Calendar, FileText, Pill, User, Bell, Plus, Clock, MapPin, ChevronRight, Network } from "lucide-react";
import { Button } from "./ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";
import { Avatar, AvatarFallback, AvatarImage } from "./ui/avatar";
import { Badge } from "./ui/badge";
import BottomNav from "./BottomNav";

interface DashboardScreenProps {
  onNavigate: (screen: string) => void;
  user: { full_name?: string; email?: string; eps?: string } | null;
}

export default function DashboardScreen({ onNavigate, user }: DashboardScreenProps) {
  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-gradient-to-r from-blue-600 to-cyan-600 text-white px-6 pt-12 pb-32 rounded-b-3xl">
        <div className="flex items-center justify-between mb-8">
          <div className="flex items-center space-x-3">
            <Avatar className="h-12 w-12 border-2 border-white">
              <AvatarImage src="" />
              <AvatarFallback className="bg-blue-800">{user?.full_name?.charAt(0) ?? 'U'}</AvatarFallback>
            </Avatar>
            <div>
              <p className="text-sm opacity-90">Bienvenido de nuevo</p>
              <h1 className="text-xl font-semibold">{user?.full_name || user?.email || 'Usuario'}</h1>
            </div>
          </div>
          <button className="relative">
            <Bell className="w-6 h-6" />
            <span className="absolute -top-1 -right-1 bg-red-500 text-white text-xs rounded-full w-5 h-5 flex items-center justify-center">
              3
            </span>
          </button>
        </div>

        <div className="flex items-center justify-between text-sm">
          <div className="flex items-center space-x-2">
            <div className="bg-white/20 px-3 py-1 rounded-full">
              <span>EPS: Sura</span>
            </div>
          </div>
        </div>
      </div>

      {/* Quick Action Card - Positioned to overlap header */}
      <div className="px-6 -mt-20 mb-6">
        <Card className="bg-white shadow-lg">
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <h3 className="font-semibold text-gray-900 mb-1">¿Necesitas atención médica?</h3>
                <p className="text-sm text-gray-600">Agenda tu cita en segundos</p>
              </div>
              <Button
                onClick={() => onNavigate('appointments?new=true')}
                className="bg-blue-600 hover:bg-blue-700 rounded-full h-14 w-14 p-0"
              >
                <Plus className="w-6 h-6" />
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Main Content */}
      <div className="px-6 pb-24">
        {/* Próximas Citas */}
        <div className="mb-6">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold text-gray-900">Próximas Citas</h2>
            <button
              className="text-blue-600 text-sm font-medium"
              onClick={() => onNavigate('appointments')}
            >
              Ver todas
            </button>
          </div>

          <div className="space-y-3">
            <Card className="border-l-4 border-l-blue-600">
              <CardContent className="p-4">
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <div className="flex items-center space-x-2 mb-2">
                      <Badge className="bg-blue-100 text-blue-700 hover:bg-blue-100">Medicina General</Badge>
                      <Badge variant="outline" className="text-green-600 border-green-600">Confirmada</Badge>
                    </div>
                    <h3 className="font-semibold text-gray-900">Dr. Carlos Rodríguez</h3>
                    <div className="flex items-center text-sm text-gray-600 mt-2 space-x-4">
                      <div className="flex items-center space-x-1">
                        <Calendar className="w-4 h-4" />
                        <span>25 Abr, 2026</span>
                      </div>
                      <div className="flex items-center space-x-1">
                        <Clock className="w-4 h-4" />
                        <span>10:30 AM</span>
                      </div>
                    </div>
                    <div className="flex items-center text-sm text-gray-600 mt-1">
                      <MapPin className="w-4 h-4 mr-1" />
                      <span>Clínica del Norte, Piso 3</span>
                    </div>
                  </div>
                  <ChevronRight className="w-5 h-5 text-gray-400" />
                </div>
              </CardContent>
            </Card>

            <Card className="border-l-4 border-l-purple-600">
              <CardContent className="p-4">
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <div className="flex items-center space-x-2 mb-2">
                      <Badge className="bg-purple-100 text-purple-700 hover:bg-purple-100">Cardiología</Badge>
                      <Badge variant="outline" className="text-orange-600 border-orange-600">Pendiente</Badge>
                    </div>
                    <h3 className="font-semibold text-gray-900">Dra. María González</h3>
                    <div className="flex items-center text-sm text-gray-600 mt-2 space-x-4">
                      <div className="flex items-center space-x-1">
                        <Calendar className="w-4 h-4" />
                        <span>2 May, 2026</span>
                      </div>
                      <div className="flex items-center space-x-1">
                        <Clock className="w-4 h-4" />
                        <span>3:00 PM</span>
                      </div>
                    </div>
                    <div className="flex items-center text-sm text-gray-600 mt-1">
                      <MapPin className="w-4 h-4 mr-1" />
                      <span>Hospital Central, Consultorio 205</span>
                    </div>
                  </div>
                  <ChevronRight className="w-5 h-5 text-gray-400" />
                </div>
              </CardContent>
            </Card>
          </div>
        </div>

        {/* Accesos Rápidos */}
        <div className="mb-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Accesos Rápidos</h2>
          <div className="grid grid-cols-2 gap-4">
            <Card
              className="cursor-pointer hover:shadow-md transition-shadow"
              onClick={() => onNavigate('exams')}
            >
              <CardContent className="p-4 text-center">
                <div className="inline-flex items-center justify-center w-14 h-14 bg-green-100 rounded-2xl mb-3">
                  <FileText className="w-7 h-7 text-green-600" />
                </div>
                <h3 className="font-semibold text-gray-900 mb-1">Exámenes</h3>
                <p className="text-xs text-gray-600">Ver resultados</p>
                <Badge className="mt-2 bg-red-500">2 nuevos</Badge>
              </CardContent>
            </Card>

            <Card
              className="cursor-pointer hover:shadow-md transition-shadow"
              onClick={() => onNavigate('medications')}
            >
              <CardContent className="p-4 text-center">
                <div className="inline-flex items-center justify-center w-14 h-14 bg-blue-100 rounded-2xl mb-3">
                  <Pill className="w-7 h-7 text-blue-600" />
                </div>
                <h3 className="font-semibold text-gray-900 mb-1">Medicamentos</h3>
                <p className="text-xs text-gray-600">Recetas activas</p>
                <p className="text-xs text-blue-600 mt-2 font-medium">4 recetas</p>
              </CardContent>
            </Card>

            <Card
              className="cursor-pointer hover:shadow-md transition-shadow"
              onClick={() => onNavigate('discrete')}
            >
              <CardContent className="p-4 text-center">
                <div className="inline-flex items-center justify-center w-14 h-14 bg-purple-100 rounded-2xl mb-3">
                  <Network className="w-7 h-7 text-purple-600" />
                </div>
                <h3 className="font-semibold text-gray-900 mb-1">Matemáticas Discretas</h3>
                <p className="text-xs text-gray-600">Grafo de atención médica</p>
                <p className="text-xs text-purple-600 mt-2 font-medium">Conceptos aplicados</p>
              </CardContent>
            </Card>

            <Card
              className="cursor-pointer hover:shadow-md transition-shadow"
              onClick={() => onNavigate('profile')}
            >
              <CardContent className="p-4 text-center">
                <div className="inline-flex items-center justify-center w-14 h-14 bg-cyan-100 rounded-2xl mb-3">
                  <User className="w-7 h-7 text-cyan-600" />
                </div>
                <h3 className="font-semibold text-gray-900 mb-1">Perfil</h3>
                <p className="text-xs text-gray-600">Tus datos y configuración</p>
                <p className="text-xs text-cyan-600 mt-2 font-medium">Ver perfil</p>
              </CardContent>
            </Card>
          </div>
        </div>

        {/* Recordatorios de Medicamentos */}
        <div>
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Recordatorios de Hoy</h2>
          <Card className="bg-gradient-to-r from-orange-50 to-amber-50 border-orange-200">
            <CardContent className="p-4">
              <div className="flex items-center space-x-4">
                <div className="flex-shrink-0 w-12 h-12 bg-orange-500 rounded-xl flex items-center justify-center">
                  <Pill className="w-6 h-6 text-white" />
                </div>
                <div className="flex-1">
                  <h3 className="font-semibold text-gray-900">Losartán 50mg</h3>
                  <p className="text-sm text-gray-600">Tomar 1 tableta</p>
                  <p className="text-xs text-orange-600 font-medium mt-1">Próxima dosis: 8:00 PM</p>
                </div>
                <Button size="sm" variant="outline" className="border-orange-600 text-orange-600">
                  Marcar
                </Button>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>

      <BottomNav currentScreen="dashboard" onNavigate={onNavigate} />
    </div>
  );
}
