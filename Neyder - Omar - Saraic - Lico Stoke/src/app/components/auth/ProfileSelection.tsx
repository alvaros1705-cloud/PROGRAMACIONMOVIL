import { useState, useEffect } from "react";
import { motion, AnimatePresence } from "motion/react";
import { Crown, TrendingUp, ShoppingBag, Lock, X, LockKeyhole } from "lucide-react";
import { ImageWithFallback } from "../figma/ImageWithFallback";
import { useTheme } from "../../context/ThemeContext";
import { Input } from "../ui/input";
import { Button } from "../ui/button";
import { toast } from "sonner";

interface Profile {
  id: string;
  name: string;
  role: string;
  icon: typeof Crown;
  description: string;
  color: string;
}

interface ProfileSelectionProps {
  onSelectProfile: (profileId: string) => void;
  onNavigateToLogin: () => void;
  userId: string;
}

interface SecurityConfig {
  ownerPin: string;
  managerRole: { enabled: boolean; pin: string; name: string };
  workerRole: { enabled: boolean; pin: string; name: string };
}

export function ProfileSelection({ onSelectProfile, userId }: ProfileSelectionProps) {
  const { theme } = useTheme();
  const isDark = theme === "dark";
  const [pinModalOpen, setPinModalOpen] = useState(false);
  const [selectedProfileId, setSelectedProfileId] = useState<string | null>(null);
  const [pin, setPin] = useState("");
  const [securityConfig, setSecurityConfig] = useState<SecurityConfig | null>(null);

  const loadConfig = () => {
    const stored = localStorage.getItem(`licostoke_${userId}_security_config`);
    if (stored) setSecurityConfig(JSON.parse(stored));
  };

  useEffect(() => {
    loadConfig();

    // Listen for storage changes so switch toggle in RoleManagement reflects immediately
    const handleStorage = (e: StorageEvent) => {
      if (e.key === `licostoke_${userId}_security_config`) loadConfig();
    };
    window.addEventListener("storage", handleStorage);
    return () => window.removeEventListener("storage", handleStorage);
  }, [userId]);

  const profiles: Profile[] = [
    {
      id: "owner",
      name: "Dueño",
      role: "Empleador",
      icon: Crown,
      description: "Acceso completo al sistema",
      color: "#C89B6D"
    },
    {
      id: "manager",
      name: "Gerente",
      role: "Gestión",
      icon: TrendingUp,
      description: "Reportes y análisis",
      color: "#4ade80"
    },
    {
      id: "worker",
      name: "Trabajador",
      role: "Ventas",
      icon: ShoppingBag,
      description: "Punto de venta",
      color: "#60a5fa"
    }
  ];

  const isProfileEnabled = (profileId: string): boolean => {
    if (profileId === "owner") return !!(securityConfig?.ownerPin);
    if (!securityConfig) return false;
    if (profileId === "manager") return securityConfig.managerRole.enabled;
    if (profileId === "worker") return securityConfig.workerRole.enabled;
    return false;
  };

  const handleProfileClick = (profileId: string) => {
    if (!isProfileEnabled(profileId)) {
      if (profileId === "owner") {
        toast.error("El Dueño aún no ha configurado el PIN Maestro. Inicia sesión primero.");
      } else {
        toast.error("Este perfil no está habilitado. El Dueño debe activarlo.");
      }
      return;
    }
    setSelectedProfileId(profileId);
    setPin("");
    setPinModalOpen(true);
  };

  const handleVerifyPin = () => {
    if (!pin || pin.length < 4) {
      toast.error("Ingresa los 4 dígitos del PIN");
      return;
    }
    if (!securityConfig) {
      toast.error("Configuración de seguridad no encontrada");
      return;
    }

    let valid = false;
    if (selectedProfileId === "owner") valid = pin === securityConfig.ownerPin;
    else if (selectedProfileId === "manager") valid = pin === securityConfig.managerRole.pin;
    else if (selectedProfileId === "worker") valid = pin === securityConfig.workerRole.pin;

    if (valid) {
      setPinModalOpen(false);
      setPin("");
      onSelectProfile(selectedProfileId!);
      toast.success("✓ Acceso concedido");
    } else {
      toast.error("PIN incorrecto");
      setPin("");
    }
  };

  const handleCancelPin = () => {
    setPinModalOpen(false);
    setPin("");
    setSelectedProfileId(null);
  };

  const selectedProfile = profiles.find(p => p.id === selectedProfileId);

  return (
    <div className={`size-full flex flex-col items-center justify-center ${isDark ? "bg-gradient-to-br from-[#0F172A] via-[#1e293b] to-[#0F172A]" : "bg-gradient-to-br from-[#F8FAFC] via-[#F1F5F9] to-[#E2E8F0]"} p-4 md:p-8`}>
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6 }}
        className="w-full max-w-6xl"
      >
        {/* Header */}
        <div className="text-center mb-12 md:mb-16">
          <motion.div
            initial={{ scale: 0.9, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            transition={{ delay: 0.2, duration: 0.5 }}
            className="mb-6"
            style={{ filter: "drop-shadow(0 10px 30px rgba(200, 155, 109, 0.25))" }}
          >
            <ImageWithFallback
              src="/src/imports/Logo-LicoStoke.png"
              alt="LicoStoke Logo"
              className="w-24 h-24 md:w-32 md:h-32 mx-auto object-contain"
            />
          </motion.div>

          <motion.h1
            initial={{ y: 20, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ delay: 0.3, duration: 0.5 }}
            className={`text-3xl md:text-4xl font-bold mb-3 ${isDark ? "text-[#f1f5f9]" : "text-[#0F172A]"}`}
          >
            Selecciona tu perfil
          </motion.h1>

          <motion.p
            initial={{ y: 20, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ delay: 0.4, duration: 0.5 }}
            className={`text-base md:text-lg ${isDark ? "text-[#94a3b8]" : "text-gray-600"}`}
          >
            Elige el perfil e ingresa tu PIN de 4 dígitos
          </motion.p>
        </div>

        {/* Profile Cards */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 md:gap-8 max-w-5xl mx-auto">
          {profiles.map((profile, index) => {
            const Icon = profile.icon;
            const isEnabled = isProfileEnabled(profile.id);
            return (
              <motion.div
                key={profile.id}
                initial={{ opacity: 0, y: 30 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.5 + index * 0.1, duration: 0.5 }}
              >
                <motion.button
                  onClick={() => handleProfileClick(profile.id)}
                  whileHover={isEnabled ? { scale: 1.05, y: -8 } : {}}
                  whileTap={isEnabled ? { scale: 0.98 } : {}}
                  disabled={!isEnabled}
                  className={`w-full group relative overflow-hidden rounded-2xl ${
                    isEnabled
                      ? isDark
                        ? "bg-[#1e293b] border-2 border-[#334155] hover:border-[#C89B6D]"
                        : "bg-white border-2 border-gray-200 hover:border-[#C89B6D]"
                      : isDark
                        ? "bg-[#1e293b]/40 border-2 border-[#334155]/40 opacity-40 cursor-not-allowed"
                        : "bg-white/40 border-2 border-gray-200/40 opacity-40 cursor-not-allowed"
                  } shadow-xl ${isEnabled ? "hover:shadow-2xl" : ""} transition-all duration-300 p-8`}
                >
                  {/* Locked Overlay */}
                  {!isEnabled && (
                    <div className="absolute inset-0 flex items-center justify-center bg-black/40 backdrop-blur-[3px] z-10">
                      <div className="text-center px-4">
                        <motion.div initial={{ scale: 0 }} animate={{ scale: 1 }} transition={{ delay: 0.3, type: "spring" }}>
                          <LockKeyhole className={`h-14 w-14 mx-auto mb-3 ${isDark ? "text-[#64748b]" : "text-gray-400"}`} />
                        </motion.div>
                        <p className={`text-base font-bold mb-1 ${isDark ? "text-[#f1f5f9]" : "text-[#0F172A]"}`}>
                          Perfil Bloqueado
                        </p>
                        <p className={`text-xs ${isDark ? "text-[#94a3b8]" : "text-gray-600"}`}>
                          {profile.id === "owner" ? "Configura el PIN Maestro" : "Habilitar desde el panel"}
                        </p>
                        <p className={`text-xs ${isDark ? "text-[#94a3b8]" : "text-gray-600"}`}>
                          {profile.id === "owner" ? "en Control de Accesos" : "de Administrador"}
                        </p>
                      </div>
                    </div>
                  )}

                  {/* Gradient on hover */}
                  {isEnabled && (
                    <div
                      className="absolute inset-0 opacity-0 group-hover:opacity-10 transition-opacity duration-300"
                      style={{ background: `linear-gradient(135deg, ${profile.color} 0%, transparent 100%)` }}
                    />
                  )}

                  {/* Icon */}
                  <div className="relative mb-6">
                    <motion.div
                      whileHover={{ rotate: [0, -10, 10, -10, 0] }}
                      transition={{ duration: 0.5 }}
                      className={`w-20 h-20 md:w-24 md:h-24 mx-auto rounded-full flex items-center justify-center ${isDark ? "bg-[#0F172A]" : "bg-gray-100"} group-hover:shadow-lg transition-shadow duration-300`}
                    >
                      <Icon
                        className="w-10 h-10 md:w-12 md:h-12 group-hover:scale-110 transition-transform duration-300"
                        style={{ color: profile.color }}
                      />
                    </motion.div>
                  </div>

                  {/* Profile Info */}
                  <div className="relative space-y-3">
                    <h3 className={`text-2xl md:text-3xl font-bold ${isDark ? "text-[#f1f5f9]" : "text-[#0F172A]"}`}>
                      {profile.name}
                    </h3>
                    <div
                      className="inline-block px-4 py-1.5 rounded-full text-sm font-medium"
                      style={{ backgroundColor: `${profile.color}20`, color: profile.color }}
                    >
                      {profile.role}
                    </div>
                    <p className={`text-sm ${isDark ? "text-[#94a3b8]" : "text-gray-600"} mt-3`}>
                      {profile.description}
                    </p>

                    {isEnabled && (
                      <motion.div initial={{ opacity: 0 }} whileHover={{ opacity: 1 }} className="pt-4">
                        <div
                          className="w-full py-2.5 rounded-lg font-semibold text-white shadow-md group-hover:shadow-lg transition-all duration-300 flex items-center justify-center gap-2"
                          style={{ backgroundColor: profile.color }}
                        >
                          <Lock className="h-4 w-4" />
                          Ingresar con PIN
                        </div>
                      </motion.div>
                    )}
                  </div>

                  <div
                    className="absolute top-0 right-0 w-32 h-32 rounded-full blur-3xl opacity-0 group-hover:opacity-20 transition-opacity duration-500"
                    style={{ backgroundColor: profile.color }}
                  />
                </motion.button>
              </motion.div>
            );
          })}
        </div>

        <motion.p
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.9, duration: 0.5 }}
          className={`text-center mt-12 text-sm ${isDark ? "text-[#64748b]" : "text-gray-500"}`}
        >
          Los permisos se aplicarán según el perfil seleccionado
        </motion.p>
      </motion.div>

      {/* PIN Modal */}
      <AnimatePresence>
        {pinModalOpen && selectedProfile && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-50 flex items-center justify-center p-4"
            onClick={handleCancelPin}
          >
            <div className={`absolute inset-0 ${isDark ? "bg-black/70" : "bg-black/50"} backdrop-blur-sm`} />

            <motion.div
              initial={{ scale: 0.9, opacity: 0, y: 20 }}
              animate={{ scale: 1, opacity: 1, y: 0 }}
              exit={{ scale: 0.9, opacity: 0, y: 20 }}
              transition={{ type: "spring", duration: 0.5 }}
              onClick={(e) => e.stopPropagation()}
              className={`relative w-full max-w-md rounded-2xl ${isDark ? "bg-[#1e293b] border-2 border-[#334155]" : "bg-white border-2 border-gray-200"} shadow-2xl p-8`}
            >
              <button
                onClick={handleCancelPin}
                className={`absolute top-4 right-4 p-2 rounded-full transition-colors ${isDark ? "hover:bg-[#334155] text-[#94a3b8]" : "hover:bg-gray-100 text-gray-500"}`}
              >
                <X className="h-5 w-5" />
              </button>

              <div className="text-center mb-6">
                <motion.div
                  initial={{ scale: 0 }}
                  animate={{ scale: 1 }}
                  transition={{ delay: 0.2, type: "spring" }}
                  className={`w-20 h-20 mx-auto mb-4 rounded-full flex items-center justify-center ${isDark ? "bg-[#0F172A]" : "bg-gray-100"}`}
                >
                  <Lock className="w-10 h-10" style={{ color: selectedProfile.color }} />
                </motion.div>

                <h2 className={`text-2xl font-bold mb-2 ${isDark ? "text-[#f1f5f9]" : "text-[#0F172A]"}`}>
                  Acceso Rápido
                </h2>
                <p className={`text-sm ${isDark ? "text-[#94a3b8]" : "text-gray-600"}`}>
                  Ingresa tu PIN de 4 dígitos para acceder como{" "}
                  <span className="font-semibold" style={{ color: selectedProfile.color }}>
                    {selectedProfile.name}
                  </span>
                </p>
              </div>

              <div className="mb-6">
                <label className={`block text-sm font-medium mb-2 ${isDark ? "text-[#f1f5f9]" : "text-[#0F172A]"}`}>
                  PIN de 4 Dígitos
                </label>
                <Input
                  type="password"
                  placeholder="••••"
                  value={pin}
                  onChange={(e) => setPin(e.target.value.replace(/\D/g, "").slice(0, 4))}
                  onKeyDown={(e) => e.key === "Enter" && handleVerifyPin()}
                  className={`${
                    isDark
                      ? "bg-[#0F172A] border-[#334155] text-[#f1f5f9] placeholder:text-[#64748b] focus:border-[#C89B6D]"
                      : "bg-white border-gray-300 text-[#0F172A] placeholder:text-gray-400 focus:border-[#C89B6D]"
                  } h-16 text-center text-3xl tracking-[1rem] font-bold`}
                  maxLength={4}
                  autoFocus
                />
                <p className={`mt-2 text-xs text-center ${isDark ? "text-[#C89B6D]" : "text-[#B8895D]"} font-medium`}>
                  ⚡ Acceso rápido sin contraseña
                </p>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <Button
                  onClick={handleCancelPin}
                  variant="outline"
                  className={`${isDark ? "bg-transparent border-[#334155] text-[#f1f5f9] hover:bg-[#334155]" : "bg-white border-gray-300 text-gray-700 hover:bg-gray-50"} h-12`}
                >
                  Cancelar
                </Button>
                <Button
                  onClick={handleVerifyPin}
                  className="h-12 font-semibold shadow-lg"
                  style={{ backgroundColor: selectedProfile.color, color: "white" }}
                >
                  Verificar
                </Button>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
