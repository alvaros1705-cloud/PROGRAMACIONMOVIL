import { useState } from "react";
import { motion, AnimatePresence } from "motion/react";
import { Button } from "../ui/button";
import { Input } from "../ui/input";
import { Label } from "../ui/label";
import { User, Mail, Lock, UserPlus, ArrowLeft, Loader2 } from "lucide-react";
import { toast } from "sonner";
import { ImageWithFallback } from "../figma/ImageWithFallback";

interface RegisterProps {
  onRegister: (name: string, email: string, password: string) => void;
  onGoogleLogin: () => void;
  onNavigateToLogin: () => void;
}

export function Register({ onRegister, onGoogleLogin, onNavigateToLogin }: RegisterProps) {
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [googleLoading, setGoogleLoading] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!name || !email || !password || !confirmPassword) {
      toast.error("Por favor completa todos los campos");
      return;
    }
    if (password !== confirmPassword) {
      toast.error("Las contraseñas no coinciden");
      return;
    }
    if (password.length < 6) {
      toast.error("La contraseña debe tener al menos 6 caracteres");
      return;
    }
    onRegister(name, email, password);
  };

  const handleGoogleLogin = () => {
    if (googleLoading) return;
    setGoogleLoading(true);
    setTimeout(() => {
      setGoogleLoading(false);
      onGoogleLogin();
    }, 1500);
  };

  const disabled = googleLoading;

  return (
    <div className="size-full flex items-center justify-center bg-gradient-to-br from-[#0F172A] via-[#1e293b] to-[#0F172A] p-4">
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
        className="w-full max-w-md"
      >
        <div className="bg-[#1e293b] rounded-2xl shadow-2xl border border-[#334155] p-8">
          <button
            onClick={onNavigateToLogin}
            disabled={disabled}
            className="mb-6 flex items-center text-[#94a3b8] hover:text-[#C89B6D] transition-colors disabled:opacity-50"
          >
            <ArrowLeft className="h-4 w-4 mr-2" />
            <span className="text-sm">Volver</span>
          </button>

          {/* Logo */}
          <div className="text-center mb-8">
            <motion.div
              initial={{ scale: 0.8, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              transition={{ delay: 0.1, duration: 0.4 }}
              className="mb-6"
              style={{ filter: "drop-shadow(0 4px 12px rgba(200, 155, 109, 0.25))" }}
            >
              <ImageWithFallback
                src="/src/imports/Logo-LicoStoke.png"
                alt="LicoStoke Logo"
                className="w-32 h-32 mx-auto object-contain"
              />
            </motion.div>
            <h1 className="text-2xl md:text-3xl font-bold text-[#f1f5f9] mb-2">Crear cuenta</h1>
            <p className="text-[#94a3b8] text-sm">Únete a LicoStoke</p>
          </div>

          {/* Google Button */}
          <motion.div layout className="mb-6">
            <Button
              type="button"
              onClick={handleGoogleLogin}
              disabled={disabled}
              className={`w-full relative overflow-hidden bg-white hover:bg-gray-50 active:bg-gray-100 text-gray-800 font-semibold border border-gray-200 shadow-sm transition-all duration-200 ${disabled ? "opacity-80 cursor-not-allowed" : ""}`}
              size="lg"
            >
              <AnimatePresence mode="wait" initial={false}>
                {googleLoading ? (
                  <motion.span
                    key="loading"
                    initial={{ opacity: 0, scale: 0.8 }}
                    animate={{ opacity: 1, scale: 1 }}
                    exit={{ opacity: 0, scale: 0.8 }}
                    transition={{ duration: 0.15 }}
                    className="flex items-center gap-2"
                  >
                    <Loader2 className="h-4 w-4 animate-spin text-[#4285F4]" />
                    <span className="text-gray-700">Conectando con Google...</span>
                  </motion.span>
                ) : (
                  <motion.span
                    key="idle"
                    initial={{ opacity: 0, scale: 0.8 }}
                    animate={{ opacity: 1, scale: 1 }}
                    exit={{ opacity: 0, scale: 0.8 }}
                    transition={{ duration: 0.15 }}
                    className="flex items-center gap-2"
                  >
                    <svg className="h-5 w-5 flex-shrink-0" viewBox="0 0 24 24" aria-hidden="true">
                      <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                      <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                      <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
                      <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
                    </svg>
                    Registrarse con Google
                  </motion.span>
                )}
              </AnimatePresence>

              {googleLoading && (
                <motion.div
                  initial={{ x: "-100%" }}
                  animate={{ x: "200%" }}
                  transition={{ repeat: Infinity, duration: 1.2, ease: "linear" }}
                  className="absolute inset-0 bg-gradient-to-r from-transparent via-white/30 to-transparent pointer-events-none"
                />
              )}
            </Button>
          </motion.div>

          {/* Divider */}
          <div className="relative mb-6">
            <div className="absolute inset-0 flex items-center">
              <div className="w-full border-t border-[#334155]" />
            </div>
            <div className="relative flex justify-center text-xs">
              <span className="bg-[#1e293b] px-3 text-[#94a3b8]">o con correo y contraseña</span>
            </div>
          </div>

          {/* Registration form */}
          <form onSubmit={handleSubmit} className="space-y-4">
            <fieldset disabled={disabled} className="space-y-4 disabled:opacity-50 disabled:pointer-events-none transition-opacity duration-300">
              <div className="space-y-2">
                <Label htmlFor="name" className="text-[#f1f5f9] text-sm">Nombre completo</Label>
                <div className="relative">
                  <User className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-[#94a3b8]" />
                  <Input
                    id="name"
                    type="text"
                    placeholder="Tu nombre"
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    className="pl-10 bg-[#0F172A] border-[#334155] text-[#f1f5f9] placeholder:text-[#64748b] focus:border-[#C89B6D] focus:ring-[#C89B6D]"
                  />
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="email" className="text-[#f1f5f9] text-sm">Correo electrónico</Label>
                <div className="relative">
                  <Mail className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-[#94a3b8]" />
                  <Input
                    id="email"
                    type="email"
                    placeholder="tu@email.com"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    className="pl-10 bg-[#0F172A] border-[#334155] text-[#f1f5f9] placeholder:text-[#64748b] focus:border-[#C89B6D] focus:ring-[#C89B6D]"
                  />
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="password" className="text-[#f1f5f9] text-sm">Contraseña</Label>
                <div className="relative">
                  <Lock className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-[#94a3b8]" />
                  <Input
                    id="password"
                    type="password"
                    placeholder="Mínimo 6 caracteres"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    className="pl-10 bg-[#0F172A] border-[#334155] text-[#f1f5f9] placeholder:text-[#64748b] focus:border-[#C89B6D] focus:ring-[#C89B6D]"
                  />
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="confirmPassword" className="text-[#f1f5f9] text-sm">Confirmar contraseña</Label>
                <div className="relative">
                  <Lock className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-[#94a3b8]" />
                  <Input
                    id="confirmPassword"
                    type="password"
                    placeholder="Confirma tu contraseña"
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                    className="pl-10 bg-[#0F172A] border-[#334155] text-[#f1f5f9] placeholder:text-[#64748b] focus:border-[#C89B6D] focus:ring-[#C89B6D]"
                  />
                </div>
              </div>

              <Button
                type="submit"
                className="w-full bg-[#C89B6D] hover:bg-[#B8895D] text-[#0F172A] font-semibold shadow-lg mt-6 transition-all"
                size="lg"
              >
                <UserPlus className="mr-2 h-4 w-4" />
                Crear cuenta
              </Button>
            </fieldset>
          </form>

          <div className="mt-6 text-center">
            <p className="text-sm text-[#94a3b8]">
              ¿Ya tienes cuenta?{" "}
              <button
                type="button"
                onClick={onNavigateToLogin}
                disabled={disabled}
                className="text-[#C89B6D] hover:text-[#B8895D] font-medium transition-colors disabled:opacity-50"
              >
                Inicia sesión
              </button>
            </p>
          </div>
        </div>

        <p className="text-center text-xs text-[#475569] mt-4">
          Al continuar, aceptas los Términos de Servicio de LicoStoke
        </p>
      </motion.div>
    </div>
  );
}
