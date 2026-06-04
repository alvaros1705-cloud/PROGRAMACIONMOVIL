import { Home, Calendar, FileText, User, Pill } from "lucide-react";

interface BottomNavProps {
  currentScreen: string;
  onNavigate: (screen: string) => void;
}

export default function BottomNav({ currentScreen, onNavigate }: BottomNavProps) {
  // Normalize current screen (remove query params)
  const normalizedScreen = currentScreen.split('?')[0];

  return (
    <div className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 px-6 py-4 rounded-t-3xl shadow-lg">
      <div className="flex items-center justify-around max-w-md mx-auto">
        <button
          onClick={() => onNavigate('dashboard')}
          className={`flex flex-col items-center space-y-1 ${
            normalizedScreen === 'dashboard' ? 'text-blue-600' : 'text-gray-400 hover:text-gray-600'
          }`}
        >
          <Home className="w-6 h-6" fill={normalizedScreen === 'dashboard' ? 'currentColor' : 'none'} />
          <span className={`text-xs ${normalizedScreen === 'dashboard' ? 'font-medium' : ''}`}>Inicio</span>
        </button>
        <button
          onClick={() => onNavigate('appointments')}
          className={`flex flex-col items-center space-y-1 ${
            normalizedScreen === 'appointments' ? 'text-blue-600' : 'text-gray-400 hover:text-gray-600'
          }`}
        >
          <Calendar className="w-6 h-6" fill={normalizedScreen === 'appointments' ? 'currentColor' : 'none'} />
          <span className={`text-xs ${normalizedScreen === 'appointments' ? 'font-medium' : ''}`}>Citas</span>
        </button>
        <button
          onClick={() => onNavigate('exams')}
          className={`flex flex-col items-center space-y-1 ${
            normalizedScreen === 'exams' ? 'text-blue-600' : 'text-gray-400 hover:text-gray-600'
          }`}
        >
          <FileText className="w-6 h-6" fill={normalizedScreen === 'exams' ? 'currentColor' : 'none'} />
          <span className={`text-xs ${normalizedScreen === 'exams' ? 'font-medium' : ''}`}>Exámenes</span>
        </button>
        <button
          onClick={() => onNavigate('profile')}
          className={`flex flex-col items-center space-y-1 ${
            normalizedScreen === 'profile' ? 'text-blue-600' : 'text-gray-400 hover:text-gray-600'
          }`}
        >
          <User className="w-6 h-6" fill={normalizedScreen === 'profile' ? 'currentColor' : 'none'} />
          <span className={`text-xs ${normalizedScreen === 'profile' ? 'font-medium' : ''}`}>Perfil</span>
        </button>
      </div>
    </div>
  );
}
