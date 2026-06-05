import { useState, useEffect } from "react";
import { Dashboard } from "./components/Dashboard";
import { Inventory } from "./components/Inventory";
import { POS } from "./components/POS";
import { Reports } from "./components/Reports";
import { RoleManagement } from "./components/RoleManagement";
import { SplashScreen } from "./components/auth/SplashScreen";
import { Login } from "./components/auth/Login";
import { Register } from "./components/auth/Register";
import { ProfileSelection } from "./components/auth/ProfileSelection";
import {
  LayoutDashboard, Package, ShoppingCart, FileText, Menu, LogOut,
  Sun, Moon, Crown, TrendingUp, ShoppingBag, RefreshCw, Shield,
  ShoppingBag as StockIcon, CreditCard, AlertCircle
} from "lucide-react";
import { Button } from "./components/ui/button";
import { Toaster } from "./components/ui/sonner";
import { toast } from "sonner";
import { ImageWithFallback } from "./components/figma/ImageWithFallback";
import { ThemeProvider, useTheme } from "./context/ThemeContext";

type Page =
  | "dashboard"
  | "inventory"
  | "pos"
  | "reports"
  | "role-management"
  | "stock-order"
  | "payment-management";

type AuthPage = "splash" | "login" | "register" | "profile-selection" | "app";

interface NavItem {
  id: Page;
  name: string;
  icon: React.ElementType;
}

// Role-based navigation definitions
const OWNER_NAV: NavItem[] = [
  { id: "dashboard", name: "Dashboard", icon: LayoutDashboard },
  { id: "inventory", name: "Inventario", icon: Package },
  { id: "reports", name: "Reportes", icon: FileText },
  { id: "role-management", name: "Control de Accesos", icon: Shield },
  { id: "stock-order", name: "Solicitar Stock", icon: StockIcon },
  { id: "payment-management", name: "Gestión de Pagos", icon: CreditCard },
];

const MANAGER_NAV: NavItem[] = [
  { id: "dashboard", name: "Dashboard", icon: LayoutDashboard },
  { id: "inventory", name: "Inventario", icon: Package },
  { id: "reports", name: "Reportes", icon: FileText },
  { id: "stock-order", name: "Pedido de Stock", icon: AlertCircle },
];

const WORKER_NAV: NavItem[] = [
  { id: "pos", name: "Punto de Venta", icon: ShoppingCart },
  { id: "inventory", name: "Consultar Inventario", icon: Package },
];

function getNavigation(profile?: string): NavItem[] {
  if (profile === "owner") return OWNER_NAV;
  if (profile === "manager") return MANAGER_NAV;
  if (profile === "worker") return WORKER_NAV;
  return [];
}

function getDefaultPage(profile?: string): Page {
  if (profile === "worker") return "pos";
  return "dashboard";
}

// Placeholder screens for new pages
function StockOrderPage({ isDark }: { isDark: boolean }) {
  return (
    <div className={`p-6 min-h-full ${isDark ? "bg-[#1f2937]" : "bg-[#F8FAFC]"} flex items-center justify-center`}>
      <div className="text-center max-w-md">
        <div className="p-4 rounded-2xl bg-[#C89B6D]/10 w-20 h-20 mx-auto mb-4 flex items-center justify-center">
          <StockIcon className="h-10 w-10 text-[#C89B6D]" />
        </div>
        <h2 className={`text-2xl font-bold mb-2 ${isDark ? "text-[#f1f5f9]" : "text-[#0F172A]"}`}>
          Solicitar Pedido de Stock
        </h2>
        <p className={`text-sm ${isDark ? "text-[#94a3b8]" : "text-gray-600"}`}>
          Módulo en desarrollo. Aquí podrás crear órdenes de reposición y alertas de stock mínimo para tus proveedores.
        </p>
        <div className={`mt-6 px-4 py-2 rounded-lg inline-block text-xs font-medium ${isDark ? "bg-[#C89B6D]/10 text-[#C89B6D]" : "bg-[#C89B6D]/10 text-[#B8895D]"}`}>
          Próximamente disponible
        </div>
      </div>
    </div>
  );
}

function PaymentManagementPage({ isDark }: { isDark: boolean }) {
  return (
    <div className={`p-6 min-h-full ${isDark ? "bg-[#1f2937]" : "bg-[#F8FAFC]"} flex items-center justify-center`}>
      <div className="text-center max-w-md">
        <div className="p-4 rounded-2xl bg-[#C89B6D]/10 w-20 h-20 mx-auto mb-4 flex items-center justify-center">
          <CreditCard className="h-10 w-10 text-[#C89B6D]" />
        </div>
        <h2 className={`text-2xl font-bold mb-2 ${isDark ? "text-[#f1f5f9]" : "text-[#0F172A]"}`}>
          Gestión de Pagos
        </h2>
        <p className={`text-sm ${isDark ? "text-[#94a3b8]" : "text-gray-600"}`}>
          Módulo en desarrollo. Aquí podrás gestionar pagos pendientes, cuentas por cobrar y reportes financieros de la licorería.
        </p>
        <div className={`mt-6 px-4 py-2 rounded-lg inline-block text-xs font-medium ${isDark ? "bg-[#C89B6D]/10 text-[#C89B6D]" : "bg-[#C89B6D]/10 text-[#B8895D]"}`}>
          Próximamente disponible
        </div>
      </div>
    </div>
  );
}

function AppContent() {
  const { theme, toggleTheme } = useTheme();
  const [authPage, setAuthPage] = useState<AuthPage>("splash");
  const [currentPage, setCurrentPage] = useState<Page>("dashboard");
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [isMobile, setIsMobile] = useState(false);
  const [user, setUser] = useState<{ name: string; email: string; id: string; profile?: string } | null>(null);

  useEffect(() => {
    const checkMobile = () => {
      setIsMobile(window.innerWidth < 768);
      setSidebarOpen(window.innerWidth >= 768);
    };

    const storedUser = localStorage.getItem("licostoke_user");

    const checkSecurityConfig = (uid: string) => {
      const sec = localStorage.getItem(`licostoke_${uid}_security_config`);
      return sec ? JSON.parse(sec) : null;
    };

    if (storedUser) {
      const userData = JSON.parse(storedUser);
      const sec = checkSecurityConfig(userData.id);

      if (sec?.ownerPin) {
        // System has PIN configured — always show Lock Screen on app launch for security
        // Strip active profile so the PIN modal is required again
        const lockedUser = { name: userData.name, email: userData.email, id: userData.id };
        setUser(lockedUser);
        localStorage.setItem("licostoke_user", JSON.stringify(lockedUser));
        setAuthPage("profile-selection");
      } else if (userData.profile) {
        // No PIN configured yet (e.g., just registered) — allow direct access
        setUser(userData);
        setCurrentPage(getDefaultPage(userData.profile));
        setAuthPage("app");
      }
      // else: no profile and no PIN → stay at splash → login
    } else {
      // No active session — check if any user has configured the system
      const googleToken = localStorage.getItem("licostoke_token_sesion");
      const googleEmail = localStorage.getItem("licostoke_user_email");
      const allUsers = localStorage.getItem("licostoke_users");

      if (allUsers) {
        const users = JSON.parse(allUsers);

        // Prefer the Google-authed user if token exists
        let configured: any = null;
        if (googleToken && googleEmail) {
          configured = users.find((u: any) => u.email === googleEmail);
        }
        // Fall back to any user with ownerPin configured
        if (!configured) {
          configured = users.find((u: any) => {
            const sec = localStorage.getItem(`licostoke_${u.id}_security_config`);
            if (sec) { const p = JSON.parse(sec); return p.ownerPin?.length >= 4; }
            return false;
          });
        }
        if (configured) {
          setUser({ name: configured.name, email: configured.email, id: configured.id });
          setAuthPage("profile-selection");
        }
      }
    }

    checkMobile();
    window.addEventListener("resize", checkMobile);
    return () => window.removeEventListener("resize", checkMobile);
  }, []);

  const handleLogin = (email: string, password: string) => {
    const storedUsers = localStorage.getItem("licostoke_users");
    const users = storedUsers ? JSON.parse(storedUsers) : [];
    const foundUser = users.find((u: any) => u.email === email && u.password === password);
    if (foundUser) {
      const userData = { name: foundUser.name, email: foundUser.email, id: foundUser.id, profile: "owner" };
      setUser(userData);
      localStorage.setItem("licostoke_user", JSON.stringify(userData));
      setCurrentPage("dashboard");
      setAuthPage("app");
      toast.success(`Bienvenido, ${foundUser.name}!`);
    } else {
      toast.error("Credenciales incorrectas");
    }
  };

  const handleRegister = (name: string, email: string, password: string) => {
    const storedUsers = localStorage.getItem("licostoke_users");
    const users = storedUsers ? JSON.parse(storedUsers) : [];
    if (users.find((u: any) => u.email === email)) {
      toast.error("Este correo ya está registrado");
      return;
    }
    const userId = `user_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    users.push({ id: userId, name, email, password });
    localStorage.setItem("licostoke_users", JSON.stringify(users));
    const userData = { name, email, id: userId, profile: "owner" };
    setUser(userData);
    localStorage.setItem("licostoke_user", JSON.stringify(userData));
    setCurrentPage("dashboard");
    setAuthPage("app");
    toast.success(`Cuenta creada! Bienvenido, ${name}!`);
  };

  const handleGoogleLogin = () => {
    const GOOGLE_TEST_EMAIL = "dueño.google@gmail.com";
    const GOOGLE_TEST_NAME = "Administrador Google";

    // Persist simulated OAuth tokens
    localStorage.setItem("licostoke_token_sesion", `ggl_tok_${Date.now()}_${Math.random().toString(36).slice(2)}`);
    localStorage.setItem("licostoke_user_email", GOOGLE_TEST_EMAIL);

    // Resolve or create the user record for this Google account
    const storedUsers = localStorage.getItem("licostoke_users");
    const users: any[] = storedUsers ? JSON.parse(storedUsers) : [];

    let googleUser = users.find((u: any) => u.email === GOOGLE_TEST_EMAIL);
    if (!googleUser) {
      googleUser = {
        id: `ggl_${Date.now()}_${Math.random().toString(36).slice(2)}`,
        name: GOOGLE_TEST_NAME,
        email: GOOGLE_TEST_EMAIL,
        password: "",         // no password — Google auth
        provider: "google"
      };
      users.push(googleUser);
      localStorage.setItem("licostoke_users", JSON.stringify(users));
    }

    // Check if this device has ever configured profiles (first-time detection)
    const secConfig = localStorage.getItem(`licostoke_${googleUser.id}_security_config`);
    const isFirstTime = !secConfig || !JSON.parse(secConfig).ownerPin;

    const userData = { name: googleUser.name, email: googleUser.email, id: googleUser.id, profile: "owner" };
    setUser(userData);
    localStorage.setItem("licostoke_user", JSON.stringify(userData));

    if (isFirstTime) {
      // First time → land on role-management so the owner sets their PIN immediately
      setCurrentPage("role-management");
      setAuthPage("app");
      toast.success(`¡Bienvenido! Configura tu PIN Maestro para empezar.`);
    } else {
      // Returning → go to lock screen (profile-selection)
      const userWithoutProfile = { name: googleUser.name, email: googleUser.email, id: googleUser.id };
      setUser(userWithoutProfile);
      localStorage.setItem("licostoke_user", JSON.stringify(userWithoutProfile));
      setAuthPage("profile-selection");
      toast.success("Sesión Google verificada. Selecciona tu perfil.");
    }
  };

  const handleProfileSelect = (profileId: string) => {
    if (user) {
      const updatedUser = { ...user, profile: profileId };
      setUser(updatedUser);
      localStorage.setItem("licostoke_user", JSON.stringify(updatedUser));
      setCurrentPage(getDefaultPage(profileId));
      setAuthPage("app");
      const names: Record<string, string> = { owner: "Dueño", manager: "Gerente", worker: "Trabajador" };
      toast.success(`Bienvenido, ${names[profileId] || profileId}`);
    }
  };

  const handleChangeRole = () => {
    if (user) {
      const updatedUser = { ...user, profile: undefined };
      setUser(updatedUser);
      localStorage.setItem("licostoke_user", JSON.stringify(updatedUser));
      setAuthPage("profile-selection");
    }
  };

  const handleLogout = () => {
    const currentUserId = user?.id;
    setUser(null);
    localStorage.removeItem("licostoke_user");

    // If system has PIN configured, keep the Lock Screen active (never go back to login)
    if (currentUserId) {
      const sec = localStorage.getItem(`licostoke_${currentUserId}_security_config`);
      if (sec) {
        const parsed = JSON.parse(sec);
        if (parsed.ownerPin?.length >= 4) {
          const allUsers = localStorage.getItem("licostoke_users");
          if (allUsers) {
            const u = JSON.parse(allUsers).find((u: any) => u.id === currentUserId);
            if (u) {
              setUser({ name: u.name, email: u.email, id: u.id });
              setAuthPage("profile-selection");
              toast.info("Sesión cerrada. Ingresa tu PIN para continuar.");
              return;
            }
          }
        }
      }
    }

    // Full wipe — also clear Google tokens so login screen shows
    localStorage.removeItem("licostoke_token_sesion");
    localStorage.removeItem("licostoke_user_email");
    setAuthPage("login");
    toast.info("Sesión cerrada completamente");
  };

  const navigation = getNavigation(user?.profile);

  const handleNavigate = (page: Page) => {
    setCurrentPage(page);
    if (isMobile) setSidebarOpen(false);
  };

  const renderPage = () => {
    if (!user) return null;
    const isDark = theme === "dark";

    // Worker can only access pos and inventory
    if (user.profile === "worker" && currentPage !== "pos" && currentPage !== "inventory") {
      return <POS userId={user.id} />;
    }
    // Manager cannot access pos or role-management
    if (user.profile === "manager" && (currentPage === "pos" || currentPage === "role-management")) {
      return <Dashboard userId={user.id} />;
    }

    switch (currentPage) {
      case "dashboard": return <Dashboard userId={user.id} />;
      case "inventory": return <Inventory userId={user.id} />;
      case "pos": return <POS userId={user.id} />;
      case "reports": return <Reports userId={user.id} />;
      case "role-management": return user.profile === "owner" ? <RoleManagement userId={user.id} /> : <Dashboard userId={user.id} />;
      case "stock-order": return <StockOrderPage isDark={isDark} />;
      case "payment-management": return <PaymentManagementPage isDark={isDark} />;
      default: return <Dashboard userId={user.id} />;
    }
  };

  if (authPage === "splash") return <SplashScreen onComplete={() => setAuthPage("login")} />;
  if (authPage === "login") return <Login onLogin={handleLogin} onGoogleLogin={handleGoogleLogin} onNavigateToRegister={() => setAuthPage("register")} />;
  if (authPage === "register") return <Register onRegister={handleRegister} onGoogleLogin={handleGoogleLogin} onNavigateToLogin={() => setAuthPage("login")} />;
  if (authPage === "profile-selection") {
    return (
      <ProfileSelection
        onSelectProfile={handleProfileSelect}
        onNavigateToLogin={() => setAuthPage("login")}
        userId={user?.id || ""}
      />
    );
  }

  const isDark = theme === "dark";
  const profileLabel = user?.profile === "owner" ? "Dueño" : user?.profile === "manager" ? "Gerente" : user?.profile === "worker" ? "Trabajador" : "Usuario";
  const ProfileIcon = user?.profile === "owner" ? Crown : user?.profile === "manager" ? TrendingUp : ShoppingBag;
  const profileColor = user?.profile === "owner" ? "#C89B6D" : user?.profile === "manager" ? "#4ade80" : "#60a5fa";

  const currentNavItem = navigation.find(n => n.id === currentPage);
  const headerTitle = currentNavItem?.name ?? navigation[0]?.name ?? "LicoStoke";

  return (
    <div className={`size-full flex ${isDark ? "bg-[#1f2937]" : "bg-[#F8FAFC]"}`}>
      {sidebarOpen && isMobile && (
        <div className="fixed inset-0 bg-black/50 z-40" onClick={() => setSidebarOpen(false)} />
      )}

      <aside
        className={`${isMobile ? "fixed inset-y-0 left-0 z-50" : "relative"} ${
          sidebarOpen ? "translate-x-0" : "-translate-x-full"
        } ${isMobile ? "w-64" : sidebarOpen ? "w-64" : "w-0"} transition-all duration-300 ${
          isDark ? "bg-[#2c3545] border-[#3a4556]" : "bg-white border-gray-200"
        } border-r flex flex-col overflow-hidden`}
      >
        {/* Logo */}
        <div className={`p-4 md:p-6 border-b ${isDark ? "border-[#3a4556]" : "border-gray-200"}`}>
          <div className="flex items-center gap-3">
            <div style={{ filter: "drop-shadow(0 2px 8px rgba(200, 155, 109, 0.3))" }}>
              <ImageWithFallback src="/src/imports/Logo-LicoStoke.png" alt="LicoStoke" className="w-14 h-14 object-contain" />
            </div>
            <div>
              <h1 className={`text-lg md:text-xl font-bold ${isDark ? "text-[#f1f5f9]" : "text-[#1E293B]"}`}>LicoStoke</h1>
              <p className={`text-xs ${isDark ? "text-[#94a3b8]" : "text-gray-500"}`}>Sistema de Gestión</p>
            </div>
          </div>
        </div>

        {/* Navigation */}
        <nav className="flex-1 p-3 md:p-4 space-y-1 md:space-y-2 overflow-y-auto">
          {navigation.map((item) => {
            const Icon = item.icon;
            return (
              <button
                key={item.id}
                onClick={() => handleNavigate(item.id)}
                className={`w-full flex items-center gap-3 px-3 md:px-4 py-2.5 md:py-3 rounded-lg transition-all ${
                  currentPage === item.id
                    ? "bg-[#C89B6D] text-white font-semibold shadow-lg"
                    : isDark
                      ? "text-[#f1f5f9] hover:bg-[#3a4556]"
                      : "text-gray-700 hover:bg-gray-100"
                }`}
              >
                <Icon className="h-5 w-5 flex-shrink-0" />
                <span className="text-sm md:text-base">{item.name}</span>
              </button>
            );
          })}
        </nav>

        {/* Bottom Controls */}
        <div className={`p-3 md:p-4 border-t ${isDark ? "border-[#3a4556]" : "border-gray-200"} space-y-3`}>
          <Button
            onClick={toggleTheme}
            variant="outline"
            className={`w-full ${isDark ? "bg-transparent border-[#3a4556] text-[#f1f5f9] hover:bg-[#1f2937]" : "bg-white border-gray-300 text-gray-700 hover:bg-gray-50"}`}
            size="sm"
          >
            {isDark ? <Sun className="mr-2 h-4 w-4" /> : <Moon className="mr-2 h-4 w-4" />}
            {isDark ? "Modo Claro" : "Modo Oscuro"}
          </Button>

          {user && (
            <>
              <div className={`${isDark ? "bg-[#1f2937]" : "bg-gray-100"} rounded-lg p-3`}>
                <div className="flex items-center gap-2 mb-1">
                  <ProfileIcon className="h-4 w-4" style={{ color: profileColor }} />
                  <p className={`text-xs ${isDark ? "text-[#94a3b8]" : "text-gray-500"}`}>{profileLabel}</p>
                </div>
                <p className={`text-sm font-medium ${isDark ? "text-[#f1f5f9]" : "text-[#1E293B]"} truncate`}>{user.name}</p>
              </div>

              <Button
                onClick={handleChangeRole}
                variant="outline"
                className={`w-full ${isDark ? "bg-transparent border-[#3a4556] text-[#C89B6D] hover:bg-[#1f2937] hover:border-[#C89B6D]" : "bg-white border-gray-300 text-[#C89B6D] hover:bg-gray-50 hover:border-[#C89B6D]"}`}
                size="sm"
              >
                <RefreshCw className="mr-2 h-4 w-4" />
                Cambiar de Rol
              </Button>
            </>
          )}

          <Button
            onClick={handleLogout}
            variant="outline"
            className={`w-full ${isDark ? "bg-transparent border-[#3a4556] text-[#f1f5f9] hover:bg-[#1f2937] hover:border-red-500/50" : "bg-white border-gray-300 text-gray-700 hover:bg-gray-50 hover:border-red-500/50"}`}
            size="sm"
          >
            <LogOut className="mr-2 h-4 w-4" />
            Cerrar sesión
          </Button>
          <div className={`text-xs ${isDark ? "text-[#64748b]" : "text-gray-400"} text-center`}>
            v1.0.0 - LicoStoke
          </div>
        </div>
      </aside>

      <div className="flex-1 flex flex-col min-w-0">
        <header className={`${isDark ? "bg-[#2c3545] border-[#3a4556]" : "bg-white border-gray-200"} border-b px-3 md:px-6 py-3 md:py-4 flex items-center gap-2 md:gap-4`}>
          <Button
            variant="ghost"
            size="sm"
            onClick={() => setSidebarOpen(!sidebarOpen)}
            className={`flex-shrink-0 ${isDark ? "text-[#f1f5f9] hover:bg-[#3a4556]" : "text-gray-700 hover:bg-gray-100"}`}
          >
            <Menu className="h-5 w-5" />
          </Button>

          <div className="flex-1 min-w-0">
            <h2 className={`text-base md:text-xl font-semibold ${isDark ? "text-[#f1f5f9]" : "text-[#1E293B]"} truncate`}>
              {headerTitle}
            </h2>
          </div>

          <div className={`text-xs md:text-sm ${isDark ? "text-[#94a3b8]" : "text-gray-500"} hidden sm:block`}>
            {new Date().toLocaleDateString("es-ES", { day: "numeric", month: "short" })}
          </div>
        </header>

        <main className={`flex-1 overflow-auto ${isDark ? "bg-[#1f2937]" : "bg-[#F8FAFC]"}`}>
          {renderPage()}
        </main>
      </div>

      <Toaster />
    </div>
  );
}

export default function App() {
  return (
    <ThemeProvider>
      <AppContent />
    </ThemeProvider>
  );
}
