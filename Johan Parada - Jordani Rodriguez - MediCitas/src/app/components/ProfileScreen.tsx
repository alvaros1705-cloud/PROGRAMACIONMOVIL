import { useState, useEffect } from "react";
import { User, Mail, Phone, Building2, Calendar, MapPin, Bell, Lock, LogOut, ChevronRight, Edit, Camera } from "lucide-react";
import { Button } from "./ui/button";
import { Card, CardContent } from "./ui/card";
import { Avatar, AvatarFallback, AvatarImage } from "./ui/avatar";
import { Badge } from "./ui/badge";
import { Switch } from "./ui/switch";
import { Input } from "./ui/input";
import BottomNav from "./BottomNav";

interface ProfileScreenProps {
  onNavigate: (screen: string) => void;
  onSignOut: () => void;
  user: { full_name?: string; email?: string; phone?: string; eps?: string } | null;
}

export default function ProfileScreen({ onNavigate, onSignOut, user }: ProfileScreenProps) {
  const [editMode, setEditMode] = useState(false);
  const [fullName, setFullName] = useState(user?.full_name || '');
  const [email, setEmail] = useState(user?.email || '');
  const [phone, setPhone] = useState(user?.phone || '');
  const [eps, setEps] = useState(user?.eps || '');

  useEffect(() => {
    setFullName(user?.full_name || '');
    setEmail(user?.email || '');
    setPhone(user?.phone || '');
    setEps(user?.eps || '');
  }, [user]);

  const handleSave = () => {
    setEditMode(false);
  };

  return (
    <div className="min-h-screen bg-gray-50 pb-24">
      {/* Header con perfil */}
      <div className="bg-gradient-to-r from-purple-600 to-pink-600 text-white px-6 pt-12 pb-20 rounded-b-3xl">
        <div className="text-center">
          <div className="relative inline-block mb-4">
            <Avatar className="h-24 w-24 border-4 border-white">
              <AvatarImage src="" />
              <AvatarFallback className="bg-purple-800 text-2xl">
                {fullName?.charAt(0) ?? 'U'}
              </AvatarFallback>
            </Avatar>
            <button
              className="absolute bottom-0 right-0 w-8 h-8 bg-white rounded-full flex items-center justify-center shadow-lg"
              onClick={() => setEditMode(true)}
            >
              <Camera className="w-4 h-4 text-purple-600" />
            </button>
          </div>
          <h1 className="text-2xl font-semibold">{fullName || 'Usuario'}</h1>
          <p className="text-sm opacity-90 mt-1">{email || 'Sin correo registrado'}</p>
          <Badge className="mt-3 bg-white/20 border-white/30">Paciente</Badge>
        </div>
      </div>

      {/* Información Personal */}
      <div className="px-6 -mt-10 space-y-4">
        <Card>
          <CardContent className="p-0">
            <div className="p-4 border-b flex items-center justify-between">
              <h2 className="font-semibold text-gray-900">Información Personal</h2>
              <Button
                variant="ghost"
                size="sm"
                className="text-purple-600"
                onClick={() => setEditMode(!editMode)}
              >
                <Edit className="w-4 h-4" />
              </Button>
            </div>

            {editMode ? (
              <div className="px-4 py-4 space-y-4">
                <Input
                  value={fullName}
                  onChange={(e) => setFullName(e.target.value)}
                  placeholder="Nombre completo"
                />
                <Input
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="Correo electrónico"
                />
                <Input
                  value={phone}
                  onChange={(e) => setPhone(e.target.value)}
                  placeholder="Teléfono"
                />
                <Input
                  value={eps}
                  onChange={(e) => setEps(e.target.value)}
                  placeholder="EPS"
                />
                <div className="flex justify-end gap-2">
                  <Button variant="outline" size="sm" onClick={() => setEditMode(false)}>
                    Cancelar
                  </Button>
                  <Button size="sm" onClick={handleSave}>
                    Guardar
                  </Button>
                </div>
              </div>
            ) : (
              <div className="divide-y">
                <div className="p-4 flex items-center justify-between">
                  <div className="flex items-center space-x-3">
                    <div className="w-10 h-10 bg-purple-100 rounded-lg flex items-center justify-center">
                      <User className="w-5 h-5 text-purple-600" />
                    </div>
                    <div>
                      <p className="text-sm text-gray-600">Nombre completo</p>
                      <p className="font-medium text-gray-900">{fullName || 'No disponible'}</p>
                    </div>
                  </div>
                  <ChevronRight className="w-5 h-5 text-gray-400" />
                </div>

                <div className="p-4 flex items-center justify-between">
                  <div className="flex items-center space-x-3">
                    <div className="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
                      <Mail className="w-5 h-5 text-blue-600" />
                    </div>
                    <div>
                      <p className="text-sm text-gray-600">Correo electrónico</p>
                      <p className="font-medium text-gray-900">{email || 'No disponible'}</p>
                    </div>
                  </div>
                  <ChevronRight className="w-5 h-5 text-gray-400" />
                </div>

                <div className="p-4 flex items-center justify-between">
                  <div className="flex items-center space-x-3">
                    <div className="w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center">
                      <Phone className="w-5 h-5 text-green-600" />
                    </div>
                    <div>
                      <p className="text-sm text-gray-600">Teléfono</p>
                      <p className="font-medium text-gray-900">{phone || 'No disponible'}</p>
                    </div>
                  </div>
                  <ChevronRight className="w-5 h-5 text-gray-400" />
                </div>

                <div className="p-4 flex items-center justify-between">
                  <div className="flex items-center space-x-3">
                    <div className="w-10 h-10 bg-orange-100 rounded-lg flex items-center justify-center">
                      <Calendar className="w-5 h-5 text-orange-600" />
                    </div>
                    <div>
                      <p className="text-sm text-gray-600">EPS</p>
                      <p className="font-medium text-gray-900">{eps || 'No disponible'}</p>
                    </div>
                  </div>
                  <ChevronRight className="w-5 h-5 text-gray-400" />
                </div>
              </div>
            )}
          </CardContent>
        </Card>

        {/* Información Médica */}
        <Card>
          <CardContent className="p-0">
            <div className="p-4 border-b">
              <h2 className="font-semibold text-gray-900">Información Médica</h2>
            </div>

            <div className="divide-y">
              <div className="p-4 flex items-center justify-between">
                <div className="flex items-center space-x-3">
                  <div className="w-10 h-10 bg-cyan-100 rounded-lg flex items-center justify-center">
                    <Building2 className="w-5 h-5 text-cyan-600" />
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">EPS</p>
                    <p className="font-medium text-gray-900">EPS Sura</p>
                  </div>
                </div>
                <ChevronRight className="w-5 h-5 text-gray-400" />
              </div>

              <div className="p-4 flex items-center justify-between">
                <div className="flex items-center space-x-3">
                  <div className="w-10 h-10 bg-pink-100 rounded-lg flex items-center justify-center">
                    <MapPin className="w-5 h-5 text-pink-600" />
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">Tipo de sangre</p>
                    <p className="font-medium text-gray-900">O+</p>
                  </div>
                </div>
                <ChevronRight className="w-5 h-5 text-gray-400" />
              </div>

              <div className="p-4">
                <p className="text-sm text-gray-600 mb-2">Alergias conocidas</p>
                <div className="flex flex-wrap gap-2">
                  <Badge variant="outline">Penicilina</Badge>
                  <Badge variant="outline">Mariscos</Badge>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Configuración */}
        <Card>
          <CardContent className="p-0">
            <div className="p-4 border-b">
              <h2 className="font-semibold text-gray-900">Configuración</h2>
            </div>

            <div className="divide-y">
              <div className="p-4 flex items-center justify-between">
                <div className="flex items-center space-x-3">
                  <div className="w-10 h-10 bg-yellow-100 rounded-lg flex items-center justify-center">
                    <Bell className="w-5 h-5 text-yellow-600" />
                  </div>
                  <div>
                    <p className="font-medium text-gray-900">Notificaciones</p>
                    <p className="text-sm text-gray-600">Recordatorios de citas y medicamentos</p>
                  </div>
                </div>
                <Switch defaultChecked />
              </div>

              <div className="p-4 flex items-center justify-between">
                <div className="flex items-center space-x-3">
                  <div className="w-10 h-10 bg-red-100 rounded-lg flex items-center justify-center">
                    <Lock className="w-5 h-5 text-red-600" />
                  </div>
                  <div>
                    <p className="font-medium text-gray-900">Cambiar contraseña</p>
                    <p className="text-sm text-gray-600">Actualiza tu contraseña</p>
                  </div>
                </div>
                <ChevronRight className="w-5 h-5 text-gray-400" />
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Estadísticas */}
        <Card>
          <CardContent className="p-0">
            <div className="p-4 border-b">
              <h2 className="font-semibold text-gray-900">Estadísticas</h2>
            </div>

            <div className="p-4 grid grid-cols-3 gap-4">
              <div className="text-center">
                <p className="text-2xl font-bold text-purple-600">12</p>
                <p className="text-xs text-gray-600 mt-1">Citas</p>
              </div>
              <div className="text-center border-l border-r">
                <p className="text-2xl font-bold text-green-600">8</p>
                <p className="text-xs text-gray-600 mt-1">Exámenes</p>
              </div>
              <div className="text-center">
                <p className="text-2xl font-bold text-blue-600">5</p>
                <p className="text-xs text-gray-600 mt-1">Recetas</p>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Cerrar Sesión */}
        <Button
          onClick={onSignOut}
          variant="outline"
          className="w-full border-red-600 text-red-600 hover:bg-red-50"
        >
          <LogOut className="w-5 h-5 mr-2" />
          Cerrar Sesión
        </Button>

        <div className="text-center pt-4 pb-8">
          <p className="text-sm text-gray-500">Versión 1.0.0</p>
          <p className="text-xs text-gray-400 mt-1">© 2026 MediCitas</p>
        </div>
      </div>

      <BottomNav currentScreen="profile" onNavigate={onNavigate} />
    </div>
  );
}
