import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/dashboard_screen.dart';
import '../screens/login_screen.dart';
import '../screens/configuracion/configuracion_screen.dart';
import '../screens/empleados/empleados_screen.dart';
import '../screens/empleados/empleado_form_screen.dart';
import '../screens/cortes/cortes_screen.dart';
import '../screens/cortes/corte_form_screen.dart';
import '../screens/pagos/pagos_screen.dart';
import '../screens/pagos/pago_form_screen.dart';
import '../screens/historial/historial_screen.dart';

class AuthChangeNotifier extends ChangeNotifier {
  AuthChangeNotifier() {
    _subscription = FirebaseAuth.instance.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  StreamSubscription<User?>? _subscription;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final authChangeNotifier = AuthChangeNotifier();

/// ---------------------------------------------------------------------------
/// Configuracion de Rutas - GoRouter
/// ---------------------------------------------------------------------------
/// Define todas las rutas de navegacion de la aplicacion Judisa Taller.
///
/// Estructura de rutas:
/// /                         -> Dashboard (pantalla principal)
/// /empleados                -> Lista de empleados
/// /empleados/nuevo          -> Formulario para crear empleado
/// /empleados/:id/editar     -> Formulario para editar empleado
/// /cortes                   -> Lista de cortes
/// /cortes/nuevo             -> Formulario para crear corte
/// /pagos                    -> Lista de pagos
/// /pagos/nuevo              -> Formulario para crear pago
/// /historial                -> Historial completo
///
/// Las rutas usan go_router con navegacion por nombres.
/// ---------------------------------------------------------------------------

/// Router principal de la aplicacion
/// Se utiliza en MaterialApp.router como el sistema de navegacion
final GoRouter appRouter = GoRouter(
  // Actualiza la navegación cuando cambia el estado de autenticación
  refreshListenable: authChangeNotifier,
  redirect: (context, state) {
    final userLogged = FirebaseAuth.instance.currentUser != null;
    final loggingIn = state.uri.path == '/login';

    if (!userLogged && !loggingIn) {
      return '/login';
    }

    if (userLogged && loggingIn) {
      return '/';
    }

    return null;
  },

  // Ruta inicial al abrir la app
  initialLocation: '/login',

  // Configuracion de rutas
  routes: [
    // -------------------------------------------------------------------------
    // RUTA: / (Dashboard)
    // Pantalla principal con resumen del taller
    // -------------------------------------------------------------------------
    GoRoute(
      path: '/',
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/configuracion',
      name: 'configuracion',
      builder: (context, state) => const ConfiguracionScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),

    // -------------------------------------------------------------------------
    // RUTAS: /empleados/*
    // Gestion de empleados del taller
    // -------------------------------------------------------------------------
    GoRoute(
      path: '/empleados',
      name: 'empleados',
      builder: (context, state) => const EmpleadosScreen(),
      routes: [
        // /empleados/nuevo
        GoRoute(
          path: 'nuevo',
          name: 'empleado-nuevo',
          builder: (context, state) => const EmpleadoFormScreen(),
        ),
        // /empleados/:id/editar
        GoRoute(
          path: ':id/editar',
          name: 'empleado-editar',
          builder: (context, state) {
            final empleadoId = state.pathParameters['id']!;
            return EmpleadoFormScreen(empleadoId: empleadoId);
          },
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // RUTAS: /cortes/*
    // Gestion de cortes de tela asignados a empleados
    // -------------------------------------------------------------------------
    GoRoute(
      path: '/cortes',
      name: 'cortes',
      builder: (context, state) => const CortesScreen(),
      routes: [
        // /cortes/nuevo
        GoRoute(
          path: 'nuevo',
          name: 'corte-nuevo',
          builder: (context, state) => const CorteFormScreen(),
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // RUTAS: /pagos/*
    // Gestion de pagos a empleados
    // -------------------------------------------------------------------------
    GoRoute(
      path: '/pagos',
      name: 'pagos',
      builder: (context, state) => const PagosScreen(),
      routes: [
        // /pagos/nuevo
        GoRoute(
          path: 'nuevo',
          name: 'pago-nuevo',
          builder: (context, state) => const PagoFormScreen(),
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // RUTA: /historial
    // Historial completo de actividad
    // -------------------------------------------------------------------------
    GoRoute(
      path: '/historial',
      name: 'historial',
      builder: (context, state) => const HistorialScreen(),
    ),
  ],

  // ---------------------------------------------------------------------------
  // Manejo de errores de navegacion
  // Se muestra cuando se intenta acceder a una ruta inexistente
  // ---------------------------------------------------------------------------
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Pagina no encontrada',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Ruta: ${state.uri.path}',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Ir al Dashboard'),
          ),
        ],
      ),
    ),
  ),

  // Configuracion de navegacion
  debugLogDiagnostics: true, // Muestra logs de navegacion en debug
);
