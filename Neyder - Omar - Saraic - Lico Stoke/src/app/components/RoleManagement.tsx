import { useState, useEffect } from "react";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "./ui/card";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { Label } from "./ui/label";
import { Switch } from "./ui/switch";
import { Badge } from "./ui/badge";
import {
  Shield,
  Crown,
  TrendingUp,
  ShoppingBag,
  Eye,
  EyeOff,
  Lock,
  CheckCircle,
  Save
} from "lucide-react";
import { useTheme } from "../context/ThemeContext";
import { toast } from "sonner";
import { motion, AnimatePresence } from "motion/react";

interface RoleManagementProps {
  userId: string;
}

interface RoleConfig {
  enabled: boolean;
  pin: string;
  name: string;
}

interface SecurityConfig {
  ownerPin: string;
  managerRole: RoleConfig;
  workerRole: RoleConfig;
}

const DEFAULT_CONFIG: SecurityConfig = {
  ownerPin: "",
  managerRole: { enabled: false, pin: "", name: "" },
  workerRole: { enabled: false, pin: "", name: "" }
};

export function RoleManagement({ userId }: RoleManagementProps) {
  const { theme } = useTheme();
  const isDark = theme === "dark";

  const [config, setConfig] = useState<SecurityConfig>(DEFAULT_CONFIG);
  const [showOwnerPin, setShowOwnerPin] = useState(false);
  const [showManagerPin, setShowManagerPin] = useState(false);
  const [showWorkerPin, setShowWorkerPin] = useState(false);
  const [hasChanges, setHasChanges] = useState(false);

  useEffect(() => {
    const stored = localStorage.getItem(`licostoke_${userId}_security_config`);
    if (stored) {
      const parsed = JSON.parse(stored);
      // Migrate old config that may have email fields
      const clean: SecurityConfig = {
        ownerPin: parsed.ownerPin || "",
        managerRole: {
          enabled: parsed.managerRole?.enabled ?? false,
          pin: parsed.managerRole?.pin || "",
          name: parsed.managerRole?.name || ""
        },
        workerRole: {
          enabled: parsed.workerRole?.enabled ?? false,
          pin: parsed.workerRole?.pin || "",
          name: parsed.workerRole?.name || ""
        }
      };
      setConfig(clean);
    }
  }, [userId]);

  const persistConfig = (updated: SecurityConfig) => {
    localStorage.setItem(`licostoke_${userId}_security_config`, JSON.stringify(updated));
  };

  const handleRoleToggle = (role: "manager" | "worker", enabled: boolean) => {
    const updated = {
      ...config,
      ...(role === "manager"
        ? { managerRole: { ...config.managerRole, enabled } }
        : { workerRole: { ...config.workerRole, enabled } })
    };
    setConfig(updated);
    setHasChanges(true);
    // Persist switch state immediately so Lock Screen reflects it in real time
    persistConfig(updated);
    toast.info(
      enabled
        ? `Perfil ${role === "manager" ? "Gerente" : "Trabajador"} activado`
        : `Perfil ${role === "manager" ? "Gerente" : "Trabajador"} bloqueado`
    );
  };

  const handleRoleUpdate = (role: "manager" | "worker", updates: Partial<RoleConfig>) => {
    const updated = {
      ...config,
      ...(role === "manager"
        ? { managerRole: { ...config.managerRole, ...updates } }
        : { workerRole: { ...config.workerRole, ...updates } })
    };
    setConfig(updated);
    setHasChanges(true);
  };

  const handleOwnerPinChange = (value: string) => {
    const updated = { ...config, ownerPin: value };
    setConfig(updated);
    setHasChanges(true);
  };

  const isFormValid = () => {
    if (!config.ownerPin || config.ownerPin.length < 4) return false;
    if (config.managerRole.enabled) {
      if (!config.managerRole.pin || config.managerRole.pin.length < 4) return false;
      if (!config.managerRole.name) return false;
    }
    if (config.workerRole.enabled) {
      if (!config.workerRole.pin || config.workerRole.pin.length < 4) return false;
      if (!config.workerRole.name) return false;
    }
    return true;
  };

  const handleSave = () => {
    if (!config.ownerPin || config.ownerPin.length < 4) {
      toast.error("El PIN Maestro debe tener 4 dígitos");
      return;
    }
    if (config.managerRole.enabled) {
      if (!config.managerRole.pin || config.managerRole.pin.length < 4) {
        toast.error("El PIN del Gerente debe tener 4 dígitos");
        return;
      }
      if (!config.managerRole.name) {
        toast.error("Ingresa el nombre del Gerente");
        return;
      }
    }
    if (config.workerRole.enabled) {
      if (!config.workerRole.pin || config.workerRole.pin.length < 4) {
        toast.error("El PIN del Trabajador debe tener 4 dígitos");
        return;
      }
      if (!config.workerRole.name) {
        toast.error("Ingresa el nombre del Trabajador");
        return;
      }
    }

    persistConfig(config);
    setHasChanges(false);
    toast.success("✓ Configuración guardada");
  };

  const inputBase = isDark
    ? "bg-[#1f2937] border-[#3a4556] text-[#f1f5f9] placeholder:text-[#64748b] focus:border-[#C89B6D]"
    : "bg-white border-gray-300 text-[#0F172A] placeholder:text-gray-400 focus:border-[#C89B6D]";

  return (
    <div className={`p-3 md:p-6 min-h-full ${isDark ? "bg-[#1f2937]" : "bg-[#F8FAFC]"}`}>
      {/* Header */}
      <div className="mb-6">
        <div className="flex items-center gap-3 mb-2">
          <div className="p-3 rounded-xl bg-gradient-to-br from-[#C89B6D] to-[#B8895D] shadow-lg">
            <Shield className="h-7 w-7 text-white" />
          </div>
          <div>
            <h1 className={`text-2xl md:text-3xl font-bold ${isDark ? "text-[#f1f5f9]" : "text-[#0F172A]"}`}>
              Control de Accesos
            </h1>
            <p className={`text-sm ${isDark ? "text-[#94a3b8]" : "text-gray-600"}`}>
              Configura PINes de 4 dígitos para acceso rápido
            </p>
          </div>
        </div>
      </div>

      {/* Owner PIN */}
      <Card className={`mb-6 ${isDark ? "bg-gradient-to-r from-[#2c3545] to-[#1e293b] border-[#C89B6D]/50" : "bg-gradient-to-r from-white to-gray-50 border-[#C89B6D]/50"} shadow-lg`}>
        <CardHeader className="pb-3">
          <div className="flex items-center gap-3">
            <div className="p-2 rounded-full bg-[#C89B6D]/20">
              <Crown className="h-6 w-6 text-[#C89B6D]" />
            </div>
            <div>
              <CardTitle className={`text-lg ${isDark ? "text-[#f1f5f9]" : "text-[#0F172A]"}`}>
                Tu PIN Maestro de Acceso
              </CardTitle>
              <CardDescription className={isDark ? "text-[#94a3b8]" : "text-gray-600"}>
                Define tu PIN de 4 dígitos para entrar como Dueño
              </CardDescription>
            </div>
          </div>
        </CardHeader>
        <CardContent>
          <div className="max-w-md">
            <Label className={`text-sm font-medium ${isDark ? "text-[#f1f5f9]" : "text-[#0F172A]"}`}>
              PIN del Dueño (Administrador) *
            </Label>
            <div className="relative mt-2">
              <Input
                type={showOwnerPin ? "text" : "password"}
                placeholder="••••"
                value={config.ownerPin}
                onChange={(e) => handleOwnerPinChange(e.target.value.replace(/\D/g, "").slice(0, 4))}
                className={`${inputBase} pr-10 text-center text-2xl tracking-widest font-bold`}
                maxLength={4}
              />
              <button
                type="button"
                onClick={() => setShowOwnerPin(!showOwnerPin)}
                className={`absolute right-3 top-1/2 -translate-y-1/2 ${isDark ? "text-[#94a3b8] hover:text-[#f1f5f9]" : "text-gray-500 hover:text-gray-700"}`}
              >
                {showOwnerPin ? <EyeOff className="h-5 w-5" /> : <Eye className="h-5 w-5" />}
              </button>
            </div>
            <p className={`text-xs mt-2 ${isDark ? "text-[#C89B6D]" : "text-[#B8895D]"} font-medium`}>
              ⚡ Con este PIN accedes directamente desde la pantalla de perfiles
            </p>
          </div>
        </CardContent>
      </Card>

      {/* Roles Section */}
      <div className="mb-6">
        <h2 className={`text-xl font-bold mb-4 ${isDark ? "text-[#f1f5f9]" : "text-[#0F172A]"}`}>
          Perfiles del Equipo
        </h2>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {/* Manager Role */}
          <Card className={`${isDark ? "bg-[#2c3545] border-[#3a4556]" : "bg-white border-gray-200"}`}>
            <CardHeader className="pb-3">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className={`p-2 rounded-full ${config.managerRole.enabled ? "bg-green-500/20" : "bg-gray-500/20"}`}>
                    <TrendingUp className={`h-5 w-5 ${config.managerRole.enabled ? "text-green-500" : "text-gray-500"}`} />
                  </div>
                  <div>
                    <CardTitle className={`text-base ${isDark ? "text-[#f1f5f9]" : "text-[#0F172A]"}`}>
                      Perfil Gerente
                    </CardTitle>
                    <Badge
                      variant="outline"
                      className={`mt-1 text-xs ${config.managerRole.enabled ? "border-green-500/30 text-green-500 bg-green-500/10" : "border-gray-500/30 text-gray-500 bg-gray-500/10"}`}
                    >
                      {config.managerRole.enabled ? (
                        <><CheckCircle className="h-3 w-3 mr-1" />Activo</>
                      ) : (
                        <><Lock className="h-3 w-3 mr-1" />Bloqueado</>
                      )}
                    </Badge>
                  </div>
                </div>
                <Switch
                  checked={config.managerRole.enabled}
                  onCheckedChange={(checked) => handleRoleToggle("manager", checked)}
                />
              </div>
            </CardHeader>

            <AnimatePresence>
              {config.managerRole.enabled && (
                <motion.div
                  initial={{ height: 0, opacity: 0 }}
                  animate={{ height: "auto", opacity: 1 }}
                  exit={{ height: 0, opacity: 0 }}
                  transition={{ duration: 0.3 }}
                >
                  <CardContent className="space-y-4">
                    <div>
                      <Label className={`text-sm ${isDark ? "text-[#f1f5f9]" : "text-[#0F172A]"}`}>
                        Nombre del Gerente *
                      </Label>
                      <Input
                        value={config.managerRole.name}
                        onChange={(e) => handleRoleUpdate("manager", { name: e.target.value })}
                        placeholder="Ej: Carlos Mendoza"
                        className={`mt-1 ${inputBase}`}
                      />
                    </div>
                    <div>
                      <Label className={`text-sm ${isDark ? "text-[#f1f5f9]" : "text-[#0F172A]"}`}>
                        PIN de Acceso (4 dígitos) *
                      </Label>
                      <div className="relative mt-1">
                        <Input
                          type={showManagerPin ? "text" : "password"}
                          placeholder="••••"
                          value={config.managerRole.pin}
                          onChange={(e) => handleRoleUpdate("manager", { pin: e.target.value.replace(/\D/g, "").slice(0, 4) })}
                          className={`${inputBase} pr-10 text-center tracking-widest font-bold`}
                          maxLength={4}
                        />
                        <button
                          type="button"
                          onClick={() => setShowManagerPin(!showManagerPin)}
                          className={`absolute right-3 top-1/2 -translate-y-1/2 ${isDark ? "text-[#94a3b8] hover:text-[#f1f5f9]" : "text-gray-500 hover:text-gray-700"}`}
                        >
                          {showManagerPin ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                        </button>
                      </div>
                    </div>
                  </CardContent>
                </motion.div>
              )}
            </AnimatePresence>
          </Card>

          {/* Worker Role */}
          <Card className={`${isDark ? "bg-[#2c3545] border-[#3a4556]" : "bg-white border-gray-200"}`}>
            <CardHeader className="pb-3">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className={`p-2 rounded-full ${config.workerRole.enabled ? "bg-blue-500/20" : "bg-gray-500/20"}`}>
                    <ShoppingBag className={`h-5 w-5 ${config.workerRole.enabled ? "text-blue-500" : "text-gray-500"}`} />
                  </div>
                  <div>
                    <CardTitle className={`text-base ${isDark ? "text-[#f1f5f9]" : "text-[#0F172A]"}`}>
                      Perfil Empleado
                    </CardTitle>
                    <Badge
                      variant="outline"
                      className={`mt-1 text-xs ${config.workerRole.enabled ? "border-blue-500/30 text-blue-500 bg-blue-500/10" : "border-gray-500/30 text-gray-500 bg-gray-500/10"}`}
                    >
                      {config.workerRole.enabled ? (
                        <><CheckCircle className="h-3 w-3 mr-1" />Activo</>
                      ) : (
                        <><Lock className="h-3 w-3 mr-1" />Bloqueado</>
                      )}
                    </Badge>
                  </div>
                </div>
                <Switch
                  checked={config.workerRole.enabled}
                  onCheckedChange={(checked) => handleRoleToggle("worker", checked)}
                />
              </div>
            </CardHeader>

            <AnimatePresence>
              {config.workerRole.enabled && (
                <motion.div
                  initial={{ height: 0, opacity: 0 }}
                  animate={{ height: "auto", opacity: 1 }}
                  exit={{ height: 0, opacity: 0 }}
                  transition={{ duration: 0.3 }}
                >
                  <CardContent className="space-y-4">
                    <div>
                      <Label className={`text-sm ${isDark ? "text-[#f1f5f9]" : "text-[#0F172A]"}`}>
                        Nombre del Empleado *
                      </Label>
                      <Input
                        value={config.workerRole.name}
                        onChange={(e) => handleRoleUpdate("worker", { name: e.target.value })}
                        placeholder="Ej: María López"
                        className={`mt-1 ${inputBase}`}
                      />
                    </div>
                    <div>
                      <Label className={`text-sm ${isDark ? "text-[#f1f5f9]" : "text-[#0F172A]"}`}>
                        PIN de Acceso (4 dígitos) *
                      </Label>
                      <div className="relative mt-1">
                        <Input
                          type={showWorkerPin ? "text" : "password"}
                          placeholder="••••"
                          value={config.workerRole.pin}
                          onChange={(e) => handleRoleUpdate("worker", { pin: e.target.value.replace(/\D/g, "").slice(0, 4) })}
                          className={`${inputBase} pr-10 text-center tracking-widest font-bold`}
                          maxLength={4}
                        />
                        <button
                          type="button"
                          onClick={() => setShowWorkerPin(!showWorkerPin)}
                          className={`absolute right-3 top-1/2 -translate-y-1/2 ${isDark ? "text-[#94a3b8] hover:text-[#f1f5f9]" : "text-gray-500 hover:text-gray-700"}`}
                        >
                          {showWorkerPin ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                        </button>
                      </div>
                    </div>
                  </CardContent>
                </motion.div>
              )}
            </AnimatePresence>
          </Card>
        </div>
      </div>

      {/* Info Card */}
      <Card className={`mb-6 ${isDark ? "bg-gradient-to-r from-[#2c3545] to-[#1e293b] border-[#C89B6D]/30" : "bg-gradient-to-r from-white to-gray-50 border-[#C89B6D]/30"}`}>
        <CardContent className="p-5">
          <div className="flex gap-4">
            <div className="flex-shrink-0">
              <div className="p-2 rounded-full bg-[#C89B6D]/20">
                <Shield className="h-6 w-6 text-[#C89B6D]" />
              </div>
            </div>
            <div className="flex-1">
              <p className={`text-base font-bold mb-2 ${isDark ? "text-[#f1f5f9]" : "text-[#0F172A]"}`}>
                💡 Sistema de Acceso Rápido (Lock Screen)
              </p>
              <div className={`space-y-2 text-xs ${isDark ? "text-[#94a3b8]" : "text-gray-600"}`}>
                <div className="flex items-start gap-2">
                  <CheckCircle className="h-4 w-4 text-[#4ade80] flex-shrink-0 mt-0.5" />
                  <p>
                    <span className="font-semibold">El Switch actúa en tiempo real:</span> Al apagar un perfil queda bloqueado inmediatamente en la pantalla de selección.
                  </p>
                </div>
                <div className="flex items-start gap-2">
                  <Lock className="h-4 w-4 text-[#C89B6D] flex-shrink-0 mt-0.5" />
                  <p>
                    <span className="font-semibold">Solo PIN:</span> Nadie necesita correo ni contraseña. 4 dígitos para acceso inmediato (ideal para POS).
                  </p>
                </div>
                <div className="flex items-start gap-2">
                  <Crown className="h-4 w-4 text-[#C89B6D] flex-shrink-0 mt-0.5" />
                  <p>
                    <span className="font-semibold">Cambiar de Rol vs Cerrar Sesión:</span> "Cambiar de Rol" vuelve al lock screen. "Cerrar Sesión" borra la sesión activa.
                  </p>
                </div>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Save Button */}
      <div className="flex justify-center md:justify-end">
        <Button
          onClick={handleSave}
          disabled={!isFormValid() || !hasChanges}
          className={`${
            isFormValid() && hasChanges
              ? "bg-gradient-to-r from-[#C89B6D] to-[#B8895D] hover:from-[#B8895D] hover:to-[#A87A4D] text-white shadow-xl hover:shadow-2xl"
              : "bg-gray-500/20 text-gray-500 cursor-not-allowed"
          } min-w-[250px] h-14 font-bold text-base transition-all duration-300`}
        >
          <Save className="mr-2 h-5 w-5" />
          {hasChanges ? "Guardar Configuración" : "✓ Configuración Guardada"}
        </Button>
      </div>

      {hasChanges && isFormValid() && (
        <motion.p
          initial={{ opacity: 0, y: -10 }}
          animate={{ opacity: 1, y: 0 }}
          className={`text-center md:text-right mt-3 text-sm ${isDark ? "text-[#C89B6D]" : "text-[#B8895D]"} font-medium`}
        >
          ✨ Guarda para aplicar los PINes y nombres actualizados
        </motion.p>
      )}
    </div>
  );
}
