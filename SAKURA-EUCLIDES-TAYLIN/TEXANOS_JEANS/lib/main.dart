// ═══════════════════════════════════════════════════════════════
// TEXANOS JEANS — VERSIÓN CORREGIDA Y COMPLETA
// ✅ Sin clases duplicadas
// ✅ AdminShell declarado correctamente
// ✅ Firebase Storage con metadata y manejo de errores
// ✅ Logo: ícono checkroom (sin assets externos)
// ✅ Partículas doradas animadas en Splash y Login
// ═══════════════════════════════════════════════════════════════

import 'dart:async';
import 'dart:math' as math;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

// ─────────────────────────────────────────────────────────────────
// FIREBASE CONFIG
// ─────────────────────────────────────────────────────────────────
const _firebaseOptions = FirebaseOptions(
  apiKey: "AIzaSyBejBSe880R8cz3YAOhMQtmAtOBC9n2ZnQ",
  authDomain: "texanos-jeans.firebaseapp.com",
  projectId: "texanos-jeans",
  storageBucket: "texanos-jeans.firebasestorage.app",
  messagingSenderId: "752824588773",
  appId: "1:752824588773:android:8db5f7e90c2ce05b90f70c",
);

// ─────────────────────────────────────────────────────────────────
// PALETA DE COLORES
// ─────────────────────────────────────────────────────────────────
class Tx {
  static const navy      = Color(0xFF0B2540);
  static const navyDeep  = Color(0xFF071A2E);
  static const navyMid   = Color(0xFF163354);
  static const navyLight = Color(0xFF1E4470);
  static const gold      = Color(0xFFC9A84C);
  static const goldLight = Color(0xFFE8CB7A);
  static const goldDark  = Color(0xFF9E7D2E);
  static const cream     = Color(0xFFF6F2EC);
  static const creamDark = Color(0xFFEDE8E0);
  static const white     = Color(0xFFFFFFFF);
  static const grey      = Color(0xFF8D8D8D);
  static const greyLight = Color(0xFFE8E8E8);
  static const greyMid   = Color(0xFFBDBDBD);
  static const dark      = Color(0xFF1A1A1A);
  static const success   = Color(0xFF27AE60);
  static const danger    = Color(0xFFE74C3C);
  static const warning   = Color(0xFFF39C12);
  static const info      = Color(0xFF2980B9);

  static const LinearGradient gradNavy = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [navyDeep, navyMid]);
  static const LinearGradient gradGold = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [goldDark, goldLight]);
}

class TxText {
  static const h1 = TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Tx.navy, letterSpacing: -0.5);
  static const h2 = TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Tx.navy);
  static const h3 = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Tx.navy);
  static const body = TextStyle(fontSize: 14, color: Tx.dark);
  static const small = TextStyle(fontSize: 12, color: Tx.grey);
  static const price = TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Tx.navy);
  static const button = TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1.5);
}

// ─────────────────────────────────────────────────────────────────
// SISTEMA DE PARTÍCULAS DORADAS
// ─────────────────────────────────────────────────────────────────
class _Particle {
  double x, y, size, speed, opacity, angle;
  _Particle({
    required this.x, required this.y, required this.size,
    required this.speed, required this.opacity, required this.angle,
  });
}

class TxParticlesBg extends StatefulWidget {
  final Widget child;
  final Color bgColor1;
  final Color bgColor2;
  final int particleCount;
  final bool showGradient;

  const TxParticlesBg({
    super.key,
    required this.child,
    this.bgColor1 = Tx.navyDeep,
    this.bgColor2 = Tx.navyMid,
    this.particleCount = 18,
    this.showGradient = true,
  });

  @override
  State<TxParticlesBg> createState() => _TxParticlesBgState();
}

class _TxParticlesBgState extends State<TxParticlesBg>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final List<_Particle> _particles = [];
  final _rng = math.Random();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat();
    _ctrl.addListener(_update);
  }

  void _initParticles(Size size) {
    if (_particles.isNotEmpty) return;
    for (int i = 0; i < widget.particleCount; i++) {
      _particles.add(_Particle(
        x: _rng.nextDouble() * size.width,
        y: _rng.nextDouble() * size.height,
        size: 1.5 + _rng.nextDouble() * 3.5,
        speed: 0.15 + _rng.nextDouble() * 0.4,
        opacity: 0.15 + _rng.nextDouble() * 0.55,
        angle: _rng.nextDouble() * 2 * math.pi,
      ));
    }
  }

  void _update() {
    if (!mounted) return;
    setState(() {
      for (final p in _particles) {
        p.y -= p.speed;
        p.x += math.sin(p.angle) * 0.3;
        p.angle += 0.01;
        if (p.y < -10) {
          p.y = MediaQuery.of(context).size.height + 10;
          p.x = _rng.nextDouble() * MediaQuery.of(context).size.width;
        }
      }
    });
  }

  @override
  void dispose() {
    _ctrl.removeListener(_update);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final size = Size(constraints.maxWidth, constraints.maxHeight);
      _initParticles(size);
      return Stack(children: [
        if (widget.showGradient)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [widget.bgColor1, widget.bgColor2],
              ),
            ),
          ),
        CustomPaint(size: size, painter: _ParticlesPainter(_particles)),
        widget.child,
      ]);
    });
  }
}

class _ParticlesPainter extends CustomPainter {
  final List<_Particle> particles;
  _ParticlesPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = Tx.gold.withOpacity(p.opacity)
        ..style = PaintingStyle.fill;
      if (p.size > 3) {
        final path = Path();
        path.moveTo(p.x, p.y - p.size);
        path.lineTo(p.x + p.size * 0.6, p.y);
        path.lineTo(p.x, p.y + p.size);
        path.lineTo(p.x - p.size * 0.6, p.y);
        path.close();
        canvas.drawPath(path, paint);
      } else {
        canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_ParticlesPainter old) => true;
}

// ─────────────────────────────────────────────────────────────────
// MODELOS
// ─────────────────────────────────────────────────────────────────
class ProductoModel {
  final String id, nombre, descripcion, badge, categoria;
  final double precio;
  final int stock, vendidos;
  final List<String> tallas, colores, imagenes;
  final bool activo;

  const ProductoModel({
    required this.id, required this.nombre, required this.descripcion,
    required this.precio, required this.stock, required this.tallas,
    required this.colores, required this.imagenes, this.badge = '',
    this.activo = true, this.vendidos = 0, this.categoria = 'jeans',
  });

  factory ProductoModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ProductoModel(
      id: doc.id, nombre: d['nombre'] ?? '', descripcion: d['descripcion'] ?? '',
      precio: (d['precio'] ?? 0).toDouble(), stock: d['stock'] ?? 0,
      tallas: List<String>.from(d['tallas'] ?? []),
      colores: List<String>.from(d['colores'] ?? []),
      imagenes: List<String>.from(d['imagenes'] ?? []),
      badge: d['badge'] ?? '', activo: d['activo'] ?? true,
      vendidos: d['vendidos'] ?? 0, categoria: d['categoria'] ?? 'jeans',
    );
  }

  Map<String, dynamic> toMap() => {
    'nombre': nombre, 'descripcion': descripcion, 'precio': precio,
    'stock': stock, 'tallas': tallas, 'colores': colores, 'imagenes': imagenes,
    'badge': badge, 'activo': activo, 'vendidos': vendidos, 'categoria': categoria,
    'actualizadoEn': FieldValue.serverTimestamp(),
  };
}

class CartItem {
  final ProductoModel producto;
  final String talla, color;
  int cantidad;
  CartItem({required this.producto, required this.talla, required this.color, required this.cantidad});
  double get subtotal => producto.precio * cantidad;
  String get key => '${producto.id}_${talla}_$color';
}

class DireccionModel {
  final String id, nombre, telefono, calle, ciudad, departamento, pais;
  final bool esPrincipal;
  const DireccionModel({
    required this.id, required this.nombre, required this.telefono,
    required this.calle, required this.ciudad, required this.departamento,
    required this.pais, this.esPrincipal = false,
  });
  factory DireccionModel.fromMap(String id, Map<String, dynamic> d) => DireccionModel(
    id: id, nombre: d['nombre'] ?? '', telefono: d['telefono'] ?? '',
    calle: d['calle'] ?? '', ciudad: d['ciudad'] ?? '',
    departamento: d['departamento'] ?? '', pais: d['pais'] ?? 'Colombia',
    esPrincipal: d['esPrincipal'] ?? false);
  Map<String, dynamic> toMap() => {
    'nombre': nombre, 'telefono': telefono, 'calle': calle,
    'ciudad': ciudad, 'departamento': departamento, 'pais': pais, 'esPrincipal': esPrincipal,
  };
  String get direccionCompleta => '$calle, $ciudad, $departamento, $pais';
}

class PedidoModel {
  final String id, estado, direccion;
  final double total;
  final List<Map<String, dynamic>> items;
  final DateTime? creadoEn;
  const PedidoModel({
    required this.id, required this.estado, required this.total,
    required this.items, this.creadoEn, this.direccion = '',
  });
  factory PedidoModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return PedidoModel(
      id: doc.id, estado: d['estado'] ?? 'pendiente',
      total: (d['total'] ?? 0).toDouble(),
      items: List<Map<String, dynamic>>.from(d['items'] ?? []),
      creadoEn: (d['creadoEn'] as Timestamp?)?.toDate(),
      direccion: d['direccion'] ?? '',
    );
  }
}

class NotificacionModel {
  final String id, titulo, mensaje, tipo;
  final bool leida;
  final DateTime? fecha;
  const NotificacionModel({
    required this.id, required this.titulo, required this.mensaje,
    required this.tipo, this.leida = false, this.fecha,
  });
  factory NotificacionModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return NotificacionModel(
      id: doc.id, titulo: d['titulo'] ?? '', mensaje: d['mensaje'] ?? '',
      tipo: d['tipo'] ?? 'info', leida: d['leida'] ?? false,
      fecha: (d['fecha'] as Timestamp?)?.toDate(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// CART STATE
// ─────────────────────────────────────────────────────────────────
class CartState extends ChangeNotifier {
  final List<CartItem> _items = [];
  List<CartItem> get items => List.unmodifiable(_items);
  int get count => _items.fold(0, (s, i) => s + i.cantidad);
  double get total => _items.fold(0.0, (s, i) => s + i.subtotal);

  void agregar(ProductoModel prod, String talla, String color, int cant) {
    final idx = _items.indexWhere((i) => i.key == '${prod.id}_${talla}_$color');
    if (idx >= 0) {
      _items[idx].cantidad += cant;
    } else {
      _items.add(CartItem(producto: prod, talla: talla, color: color, cantidad: cant));
    }
    notifyListeners();
  }

  void actualizar(int idx, int nuevaCant) {
    if (nuevaCant <= 0) _items.removeAt(idx); else _items[idx].cantidad = nuevaCant;
    notifyListeners();
  }

  void eliminar(int idx) { _items.removeAt(idx); notifyListeners(); }
  void limpiar() { _items.clear(); notifyListeners(); }

  double calcularDescuento(List<Map<String, dynamic>> reglas) {
    double pct = 0;
    for (final r in reglas) {
      if (count >= (r['minCantidad'] ?? 0) && (r['porcentaje'] ?? 0) > pct) {
        pct = (r['porcentaje'] ?? 0).toDouble();
      }
    }
    return pct;
  }
}

class CartProvider extends InheritedNotifier<CartState> {
  const CartProvider({super.key, required CartState cart, required super.child})
      : super(notifier: cart);
  static CartState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CartProvider>()!.notifier!;
}

// ─────────────────────────────────────────────────────────────────
// MAIN
// ─────────────────────────────────────────────────────────────────
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  try { await Firebase.initializeApp(options: _firebaseOptions); } catch (_) {}
  runApp(TexanosApp());
}

class TexanosApp extends StatelessWidget {
  final CartState _cart = CartState();
  TexanosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CartProvider(
      cart: _cart,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Texanos Jeans',
        theme: _buildTheme(),
        home: const AuthGate(),
      ),
    );
  }

  ThemeData _buildTheme() => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Tx.navy, primary: Tx.navy, secondary: Tx.gold, surface: Tx.white),
    scaffoldBackgroundColor: Tx.cream,
    appBarTheme: const AppBarTheme(
      backgroundColor: Tx.navy, foregroundColor: Tx.white,
      elevation: 0, centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.light),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Tx.navy,
      indicatorColor: Tx.gold.withOpacity(0.15),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(color: Tx.white, fontSize: 10, fontWeight: FontWeight.w500)),
      iconTheme: WidgetStateProperty.resolveWith((s) =>
        IconThemeData(color: s.contains(WidgetState.selected) ? Tx.gold : Colors.white38))),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: Tx.cream,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Tx.greyLight, width: 1)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Tx.navy, width: 1.5)),
      labelStyle: const TextStyle(color: Tx.grey, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Tx.navy, foregroundColor: Tx.white, elevation: 0,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: TxText.button)),
    cardTheme: CardThemeData(
      elevation: 0, color: Tx.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
  );
}

// ─────────────────────────────────────────────────────────────────
// AUTH GATE
// ─────────────────────────────────────────────────────────────────
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const SplashView();
        if (snap.hasData) return RoleGate(user: snap.data!);
        return const LoginView();
      });
  }
}

class RoleGate extends StatelessWidget {
  final User user;
  const RoleGate({super.key, required this.user});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get(),
      builder: (ctx, snap) {
        if (!snap.hasData) return const SplashView();
        final data = snap.data?.data() as Map<String, dynamic>?;
        if (data?['rol'] == 'admin') return const AdminShell();
        return const ClientShell();
      });
  }
}

// ─────────────────────────────────────────────────────────────────
// SPLASH
// ─────────────────────────────────────────────────────────────────
class SplashView extends StatefulWidget {
  const SplashView({super.key});
  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale, _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _scale = Tween<double>(begin: 0.6, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Tx.navyDeep,
      body: TxParticlesBg(
        particleCount: 22,
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: Tx.gradGold,
                    boxShadow: [
                      BoxShadow(color: Tx.gold.withOpacity(0.5), blurRadius: 40, spreadRadius: 6),
                      BoxShadow(color: Tx.gold.withOpacity(0.2), blurRadius: 80, spreadRadius: 12),
                    ]),
                  child: const Icon(Icons.checkroom_rounded, size: 52, color: Tx.navy),
                ),
                const SizedBox(height: 24),
                ShaderMask(
                  shaderCallback: (b) => Tx.gradGold.createShader(b),
                  child: const Text('TEXANOS', style: TextStyle(
                    color: Tx.white, fontSize: 30,
                    fontWeight: FontWeight.w900, letterSpacing: 10))),
                const Text('J E A N S', style: TextStyle(
                  color: Tx.gold, fontSize: 13,
                  fontWeight: FontWeight.w300, letterSpacing: 10)),
                const SizedBox(height: 56),
                const SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(
                    color: Tx.gold, strokeWidth: 1.5, strokeCap: StrokeCap.round)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// LOGIN
// ─────────────────────────────────────────────────────────────────
class LoginView extends StatefulWidget {
  const LoginView({super.key});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with SingleTickerProviderStateMixin {
  final _email = TextEditingController();
  final _pass  = TextEditingController();
  final _form  = GlobalKey<FormState>();
  bool _loading = false, _showPass = false;
  String? _error;
  late AnimationController _ctrl;
  late Animation<double> _slide, _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _slide = Tween<double>(begin: 80, end: 0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _loginEmail() async {
    if (!_form.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(), password: _pass.text.trim());
      if (!cred.user!.emailVerified) {
        await FirebaseAuth.instance.signOut();
        setState(() => _error = 'Verifica tu correo antes de ingresar.');
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _authMsg(e.code));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loginGoogle() async {
    setState(() { _loading = true; _error = null; });
    try {
      final provider = GoogleAuthProvider()..addScope('email');
      final result = await FirebaseAuth.instance.signInWithProvider(provider);
      final user = result.user;
      if (user != null) {
        final ref = FirebaseFirestore.instance.collection('usuarios').doc(user.uid);
        if (!(await ref.get()).exists) {
          await ref.set({
            'email': user.email, 'nombre': user.displayName ?? '',
            'rol': 'cliente', 'aprobado': true, 'credito': 0, 'saldo': 0,
            'telefono': user.phoneNumber ?? '', 'fotoPerfil': user.photoURL ?? '',
            'creadoEn': FieldValue.serverTimestamp(),
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _authMsg(e.code));
    } catch (_) {
      setState(() => _error = 'Error al iniciar con Google.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _recuperarPass() async {
    if (_email.text.trim().isEmpty) {
      setState(() => _error = 'Ingresa tu correo para recuperar contraseña.');
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _email.text.trim());
      if (mounted) TxSnack.show(context, 'Email de recuperación enviado ✓', type: 'success');
    } catch (_) {
      setState(() => _error = 'No se pudo enviar el correo.');
    }
  }

  String _authMsg(String code) {
    switch (code) {
      case 'user-not-found': return 'No existe cuenta con este correo.';
      case 'wrong-password': return 'Contraseña incorrecta.';
      case 'too-many-requests': return 'Demasiados intentos. Espera un momento.';
      case 'invalid-email': return 'Correo electrónico inválido.';
      case 'user-disabled': return 'Esta cuenta ha sido desactivada.';
      default: return 'Error de autenticación. Intenta de nuevo.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TxParticlesBg(
        particleCount: 20,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(children: [
              const SizedBox(height: 50),
              FadeTransition(
                opacity: _fade,
                child: Column(children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: Tx.gradGold,
                      boxShadow: [
                        BoxShadow(color: Tx.gold.withOpacity(0.4), blurRadius: 30, spreadRadius: 4),
                        BoxShadow(color: Tx.gold.withOpacity(0.15), blurRadius: 60, spreadRadius: 8),
                      ]),
                    child: const Icon(Icons.checkroom_rounded, size: 54, color: Tx.navy),
                  ),
                  const SizedBox(height: 14),
                  ShaderMask(
                    shaderCallback: (b) => Tx.gradGold.createShader(b),
                    child: const Text('TEXANOS JEANS', style: TextStyle(
                      color: Tx.white, fontSize: 20,
                      fontWeight: FontWeight.w900, letterSpacing: 6))),
                  const SizedBox(height: 4),
                  Text('Fábrica de Estilo', style: TextStyle(
                    color: Tx.gold.withOpacity(0.7), fontSize: 11, letterSpacing: 3)),
                ]),
              ),
              const SizedBox(height: 32),
              AnimatedBuilder(
                animation: _ctrl,
                builder: (_, child) => Opacity(
                  opacity: _fade.value,
                  child: Transform.translate(offset: Offset(0, _slide.value), child: child)),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: Tx.white.withOpacity(0.97),
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 50, offset: const Offset(0, 20)),
                      BoxShadow(color: Tx.gold.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 10)),
                    ]),
                  child: Form(
                    key: _form,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Bienvenido de nuevo', style: TxText.h2),
                      const SizedBox(height: 4),
                      const Text('Ingresa para gestionar tus pedidos',
                        style: TextStyle(color: Tx.grey, fontSize: 12)),
                      const SizedBox(height: 22),
                      if (_error != null) _ErrorBanner(_error!),
                      TxInput(
                        controller: _email, label: 'Correo electrónico',
                        icon: Icons.alternate_email_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v!.contains('@') ? null : 'Correo inválido'),
                      TxInput(
                        controller: _pass, label: 'Contraseña',
                        icon: Icons.lock_outline_rounded, obscure: !_showPass,
                        validator: (v) => v!.length >= 6 ? null : 'Mínimo 6 caracteres',
                        suffix: IconButton(
                          icon: Icon(
                            _showPass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: Tx.grey, size: 20),
                          onPressed: () => setState(() => _showPass = !_showPass))),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _recuperarPass,
                          child: const Text('¿Olvidaste tu contraseña?',
                            style: TextStyle(color: Tx.navy, fontSize: 12)))),
                      if (_loading)
                        const Center(child: TxLoader())
                      else ...[
                        ElevatedButton(
                          onPressed: _loginEmail,
                          child: const Text('INGRESAR', style: TxText.button)),
                        const SizedBox(height: 14),
                        _DividerOr(),
                        const SizedBox(height: 14),
                        _GoogleBtn(onTap: _loginGoogle),
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.push(context, _txSlide(const RegisterView())),
                            child: const Text.rich(TextSpan(children: [
                              TextSpan(text: '¿Sin cuenta? ', style: TextStyle(color: Tx.grey)),
                              TextSpan(text: 'Regístrate aquí',
                                style: TextStyle(color: Tx.navy, fontWeight: FontWeight.w700)),
                            ])))),
                      ],
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// REGISTER
// ─────────────────────────────────────────────────────────────────
class RegisterView extends StatefulWidget {
  const RegisterView({super.key});
  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _form   = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _email  = TextEditingController();
  final _pass   = TextEditingController();
  final _tel    = TextEditingController();
  String _rol = 'cliente';
  bool _loading = false;
  String? _error;

  Future<void> _register() async {
    if (!_form.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(), password: _pass.text.trim());
      await FirebaseFirestore.instance.collection('usuarios').doc(cred.user!.uid).set({
        'email': _email.text.trim(), 'nombre': _nombre.text.trim(),
        'telefono': _tel.text.trim(), 'rol': _rol,
        'aprobado': _rol == 'admin', 'credito': 0, 'saldo': 0,
        'creadoEn': FieldValue.serverTimestamp(),
      });
      await cred.user!.sendEmailVerification();
      await FirebaseAuth.instance.signOut();
      if (mounted) _showSuccess();
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSuccess() {
    showDialog(
      context: context, barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFE8F8F0)),
            child: const Icon(Icons.check_rounded, color: Tx.success, size: 32)),
          const SizedBox(height: 14),
          const Text('¡Cuenta creada!', style: TxText.h3, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          const Text('Verifica tu correo para activar la cuenta.',
            style: TextStyle(color: Tx.grey), textAlign: TextAlign.center),
        ]),
        actions: [
          SizedBox(width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Tx.success),
              onPressed: () { Navigator.pop(context); Navigator.pop(context); },
              child: const Text('ENTENDIDO'))),
        ],
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Cuenta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _form,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Únete a Texanos', style: TxText.h1),
            const SizedBox(height: 6),
            const Text('Crea tu cuenta de mayorista', style: TextStyle(color: Tx.grey)),
            const SizedBox(height: 24),
            if (_error != null) ...[_ErrorBanner(_error!), const SizedBox(height: 12)],
            TxInput(controller: _nombre, label: 'Nombre completo',
              icon: Icons.person_outline_rounded,
              validator: (v) => v!.isNotEmpty ? null : 'Requerido'),
            TxInput(controller: _email, label: 'Correo electrónico',
              icon: Icons.alternate_email_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => v!.contains('@') ? null : 'Correo inválido'),
            TxInput(controller: _tel, label: 'Teléfono (opcional)',
              icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
            TxInput(controller: _pass, label: 'Contraseña (mín. 6 caracteres)',
              icon: Icons.lock_outline_rounded, obscure: true,
              validator: (v) => v!.length >= 6 ? null : 'Mínimo 6 caracteres'),
            const SizedBox(height: 20),
            const Text('Tipo de cuenta',
              style: TextStyle(fontWeight: FontWeight.w700, color: Tx.navy)),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _RolCard(
                icon: Icons.store_outlined, label: 'Cliente\nMayorista',
                selected: _rol == 'cliente',
                onTap: () => setState(() => _rol = 'cliente'))),
              const SizedBox(width: 12),
              Expanded(child: _RolCard(
                icon: Icons.admin_panel_settings_outlined, label: 'Administrador',
                selected: _rol == 'admin',
                onTap: () => setState(() => _rol = 'admin'))),
            ]),
            const SizedBox(height: 28),
            _loading
                ? const Center(child: TxLoader())
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Tx.gold, foregroundColor: Tx.navy),
                    onPressed: _register,
                    child: const Text('CREAR CUENTA', style: TxText.button)),
          ])),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// CLIENT SHELL
// ─────────────────────────────────────────────────────────────────
class ClientShell extends StatefulWidget {
  const ClientShell({super.key});
  @override
  State<ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends State<ClientShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final cart = CartProvider.of(context);
    final count = cart.count;
    final views = [
      const CatalogView(), const CartView(), const OrdersView(), const ProfileView(),
    ];
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(shape: BoxShape.circle, gradient: Tx.gradGold),
            child: const Icon(Icons.checkroom_rounded, size: 14, color: Tx.navy)),
          const SizedBox(width: 10),
          const Text('TEXANOS JEANS',
            style: TextStyle(fontSize: 13, letterSpacing: 2, fontWeight: FontWeight.w800)),
        ]),
        actions: [
          _NotifBadge(onTap: () =>
            Navigator.push(context, _txSlide(const NotificationsView()))),
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(index: _tab, children: views),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded), label: 'Catálogo'),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: count > 0,
              label: Text('$count', style: const TextStyle(fontSize: 9)),
              child: const Icon(Icons.shopping_bag_outlined)),
            selectedIcon: Badge(
              isLabelVisible: count > 0,
              label: Text('$count', style: const TextStyle(fontSize: 9)),
              child: const Icon(Icons.shopping_bag_rounded)),
            label: 'Carrito'),
          const NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded), label: 'Pedidos'),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded), label: 'Perfil'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// CATALOG VIEW
// ─────────────────────────────────────────────────────────────────
class CatalogView extends StatefulWidget {
  const CatalogView({super.key});
  @override
  State<CatalogView> createState() => _CatalogViewState();
}

class _CatalogViewState extends State<CatalogView> {
  final _promoCtrl = PageController(viewportFraction: 0.9);
  int _promoPage = 0;
  Timer? _promoTimer;
  String _filtro = 'todos';
  static const _filtros = ['todos', 'slim', 'straight', 'bootcut', 'skinny', 'relaxed'];
  static const _promos = [
    (titulo: 'COLECCIÓN\nOTOÑO', sub: 'Nuevos estilos 2025', tag: '20% OFF',
     color1: Tx.navyDeep, color2: Tx.navyLight, accent: Tx.gold, icon: Icons.star_rounded),
    (titulo: 'JEAN\nPREMIUM', sub: 'Calidad garantizada', tag: 'ENVÍO GRATIS',
     color1: Color(0xFF0F2E1A), color2: Color(0xFF1E5C32), accent: Color(0xFF6FCF97),
     icon: Icons.local_shipping_rounded),
    (titulo: 'COMPRA\nPOR MAYOR', sub: 'Hasta 30% de descuento', tag: '–30%',
     color1: Color(0xFF1E0A30), color2: Color(0xFF3D1A60), accent: Color(0xFFB39DDB),
     icon: Icons.inventory_2_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _promoTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_promoPage + 1) % _promos.length;
      _promoCtrl.animateToPage(next,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() { _promoTimer?.cancel(); _promoCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: Column(children: [
          const SizedBox(height: 12),
          SizedBox(
            height: 168,
            child: PageView.builder(
              controller: _promoCtrl,
              onPageChanged: (i) => setState(() => _promoPage = i),
              itemCount: _promos.length,
              itemBuilder: (_, i) {
                final p = _promos[i];
                return _PromoSlide(
                  titulo: p.titulo, sub: p.sub, tag: p.tag,
                  color1: p.color1, color2: p.color2, accent: p.accent,
                  icon: p.icon, active: _promoPage == i);
              })),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_promos.length, (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _promoPage == i ? 20 : 6, height: 6,
              decoration: BoxDecoration(
                color: _promoPage == i ? Tx.navy : Tx.greyLight,
                borderRadius: BorderRadius.circular(3))))),
          const SizedBox(height: 14),
        ])),
        SliverPersistentHeader(
          pinned: true,
          delegate: _FilterBarDelegate(
            filtros: _filtros, selected: _filtro,
            onSelect: (f) => setState(() => _filtro = f))),
        SliverToBoxAdapter(child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('productos')
              .where('activo', isEqualTo: true).snapshots(),
          builder: (_, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.only(top: 48),
                child: Center(child: TxLoader()));
            }
            var docs = snap.data?.docs ?? [];
            if (_filtro != 'todos') {
              docs = docs.where((d) {
                final data = d.data() as Map<String, dynamic>;
                return (data['categoria'] ?? '').toLowerCase() == _filtro;
              }).toList();
            }
            if (docs.isEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Center(child: Column(children: [
                  Icon(Icons.inventory_2_outlined, size: 56, color: Tx.grey.withOpacity(0.3)),
                  const SizedBox(height: 10),
                  const Text('Sin productos disponibles', style: TextStyle(color: Tx.grey)),
                ])));
            }
            return Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              child: GridView.builder(
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, childAspectRatio: 0.68,
                  crossAxisSpacing: 10, mainAxisSpacing: 10),
                itemBuilder: (_, i) {
                  final prod = ProductoModel.fromFirestore(docs[i]);
                  return _ProductCard(
                    producto: prod,
                    onTap: () => showModalBottomSheet(
                      context: context, isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => ProductDetailSheet(producto: prod)));
                }));
          })),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// PRODUCT DETAIL SHEET
// ─────────────────────────────────────────────────────────────────
class ProductDetailSheet extends StatefulWidget {
  final ProductoModel producto;
  const ProductDetailSheet({super.key, required this.producto});
  @override
  State<ProductDetailSheet> createState() => _ProductDetailSheetState();
}

class _ProductDetailSheetState extends State<ProductDetailSheet> {
  String? _tallaSelected, _colorSelected;
  int _cantidad = 1, _imgIdx = 0;

  @override
  void initState() {
    super.initState();
    if (widget.producto.tallas.isNotEmpty) _tallaSelected = widget.producto.tallas[0];
    if (widget.producto.colores.isNotEmpty) _colorSelected = widget.producto.colores[0];
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.producto;
    final cart = CartProvider.of(context);
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Tx.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(children: [
        const SizedBox(height: 10),
        Container(
          width: 38, height: 4,
          decoration: BoxDecoration(color: Tx.greyLight, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 6),
        Expanded(child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              height: 260,
              child: p.imagenes.isNotEmpty
                  ? PageView.builder(
                      onPageChanged: (i) => setState(() => _imgIdx = i),
                      itemCount: p.imagenes.length,
                      itemBuilder: (_, i) => Image.network(
                        p.imagenes[i], fit: BoxFit.cover,
                        loadingBuilder: (_, child, prog) =>
                            prog == null ? child : const _ImgSkeleton(),
                        errorBuilder: (_, __, ___) => const _NoImgPlaceholder()))
                  : const _NoImgPlaceholder()),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Expanded(child: Text(p.nombre, style: TxText.h2)),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('\$${p.precio.toStringAsFixed(0)}', style: TxText.price),
                    const Text('precio mayorista', style: TxText.small),
                  ]),
                ]),
                const SizedBox(height: 8),
                Text(p.descripcion,
                  style: const TextStyle(color: Tx.grey, fontSize: 13, height: 1.5)),
                const SizedBox(height: 18),
                if (p.tallas.isNotEmpty) ...[
                  const Text('Talla',
                    style: TextStyle(fontWeight: FontWeight.w700, color: Tx.navy)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: p.tallas.map((t) => GestureDetector(
                      onTap: () => setState(() => _tallaSelected = t),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 50, height: 50,
                        decoration: BoxDecoration(
                          color: _tallaSelected == t ? Tx.navy : Tx.cream,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _tallaSelected == t ? Tx.gold : Tx.greyLight,
                            width: 1.5)),
                        child: Center(child: Text(t, style: TextStyle(
                          color: _tallaSelected == t ? Tx.gold : Tx.navy,
                          fontWeight: FontWeight.w700, fontSize: 12)))))).toList()),
                  const SizedBox(height: 18),
                ],
                if (p.colores.isNotEmpty) ...[
                  const Text('Color',
                    style: TextStyle(fontWeight: FontWeight.w700, color: Tx.navy)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: p.colores.map((c) => GestureDetector(
                      onTap: () => setState(() => _colorSelected = c),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _colorSelected == c ? Tx.navy : Tx.cream,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _colorSelected == c ? Tx.gold : Tx.greyLight,
                            width: 1.5)),
                        child: Text(c, style: TextStyle(
                          color: _colorSelected == c ? Tx.gold : Tx.navy,
                          fontWeight: FontWeight.w500, fontSize: 12))))).toList()),
                  const SizedBox(height: 18),
                ],
                const Text('Cantidad',
                  style: TextStyle(fontWeight: FontWeight.w700, color: Tx.navy)),
                const SizedBox(height: 10),
                Row(children: [
                  _QtyBtn(icon: Icons.remove,
                    onTap: () { if (_cantidad > 1) setState(() => _cantidad--); }),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text('$_cantidad', style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800, color: Tx.navy))),
                  _QtyBtn(icon: Icons.add, onTap: () => setState(() => _cantidad++)),
                  const Spacer(),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    const Text('Subtotal', style: TextStyle(color: Tx.grey, fontSize: 11)),
                    Text('\$${(p.precio * _cantidad).toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800, color: Tx.navy)),
                  ]),
                ]),
              ])),
          ]))),
        Container(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 22),
          decoration: BoxDecoration(
            color: Tx.white,
            border: Border(top: BorderSide(color: Tx.greyLight))),
          child: SafeArea(
            top: false,
            child: ElevatedButton.icon(
              onPressed: () {
                if (_tallaSelected == null) {
                  TxSnack.show(context, 'Selecciona una talla', type: 'warning');
                  return;
                }
                cart.agregar(p, _tallaSelected!, _colorSelected ?? '', _cantidad);
                Navigator.pop(context);
                TxSnack.show(context, '${p.nombre} añadido al carrito', type: 'success');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14)),
              icon: const Icon(Icons.add_shopping_cart_rounded),
              label: const Text('AGREGAR AL CARRITO', style: TxText.button)))),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// CART VIEW
// ─────────────────────────────────────────────────────────────────
class CartView extends StatefulWidget {
  const CartView({super.key});
  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  DireccionModel? _direccion;
  List<Map<String, dynamic>> _reglas = [];

  @override
  void initState() { super.initState(); _cargarReglas(); _cargarDireccion(); }

  Future<void> _cargarReglas() async {
    final snap = await FirebaseFirestore.instance.collection('descuentos')
        .where('activo', isEqualTo: true).get();
    if (mounted) {
      setState(() => _reglas = snap.docs.map((d) => d.data() as Map<String, dynamic>).toList());
    }
  }

  Future<void> _cargarDireccion() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final snap = await FirebaseFirestore.instance
        .collection('usuarios').doc(uid).collection('direcciones')
        .where('esPrincipal', isEqualTo: true).get();
    if (snap.docs.isNotEmpty && mounted) {
      setState(() => _direccion = DireccionModel.fromMap(
        snap.docs.first.id, snap.docs.first.data()));
    }
  }

  Future<void> _confirmarPedido(CartState cart) async {
    if (cart.items.isEmpty) return;
    if (_direccion == null) {
      TxSnack.show(context, 'Selecciona una dirección de entrega', type: 'warning');
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDialog(
        total: cart.total * (1 - cart.calcularDescuento(_reglas) / 100),
        count: cart.count, direccion: _direccion!.direccionCompleta));
    if (ok != true) return;
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final desc = cart.calcularDescuento(_reglas);
      final totalFinal = cart.total * (1 - desc / 100);
      final ref = await FirebaseFirestore.instance.collection('pedidos').add({
        'clienteId': user.uid, 'clienteEmail': user.email,
        'direccion': _direccion!.direccionCompleta,
        'items': cart.items.map((i) => {
          'productoId': i.producto.id, 'nombre': i.producto.nombre,
          'talla': i.talla, 'color': i.color,
          'cantidad': i.cantidad, 'subtotal': i.subtotal,
        }).toList(),
        'total': totalFinal, 'descuento': desc,
        'estado': 'pendiente', 'creadoEn': FieldValue.serverTimestamp(),
      });
      for (final item in cart.items) {
        await FirebaseFirestore.instance.collection('productos').doc(item.producto.id)
            .update({'stock': FieldValue.increment(-item.cantidad)});
      }
      await FirebaseFirestore.instance.collection('usuarios').doc(user.uid)
          .collection('notificaciones').add({
        'titulo': '¡Pedido confirmado! 🎉',
        'mensaje': 'Tu pedido #${ref.id.substring(0, 6).toUpperCase()} fue recibido.',
        'tipo': 'compra', 'leida': false, 'fecha': FieldValue.serverTimestamp(),
      });
      cart.limpiar();
      if (mounted) TxSnack.show(context, '¡Pedido confirmado!', type: 'success');
    } catch (_) {
      if (mounted) TxSnack.show(context, 'Error al confirmar pedido.', type: 'error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartProvider.of(context);
    if (cart.items.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          padding: const EdgeInsets.all(26),
          decoration: const BoxDecoration(color: Tx.cream, shape: BoxShape.circle),
          child: const Icon(Icons.shopping_bag_outlined, size: 52, color: Tx.grey)),
        const SizedBox(height: 18),
        const Text('Tu carrito está vacío', style: TxText.h3),
        const SizedBox(height: 6),
        const Text('Explora el catálogo y añade productos',
          style: TextStyle(color: Tx.grey)),
      ]));
    }
    final desc = cart.calcularDescuento(_reglas);
    final totalFinal = cart.total * (1 - desc / 100);
    return Column(children: [
      Expanded(child: ListView(
        padding: const EdgeInsets.all(14),
        physics: const BouncingScrollPhysics(),
        children: [
          GestureDetector(
            onTap: () async {
              final dir = await Navigator.push<DireccionModel>(context,
                _txSlide<DireccionModel>(const DireccionesView(seleccionar: true)));
              if (dir != null) setState(() => _direccion = dir);
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Tx.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _direccion != null ? Tx.navy : Tx.gold, width: 1.5)),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Tx.navy.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.location_on_rounded, color: Tx.navy, size: 18)),
                const SizedBox(width: 12),
                Expanded(child: _direccion != null
                    ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Entregar en',
                          style: TextStyle(color: Tx.grey, fontSize: 11)),
                        Text(_direccion!.nombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700, color: Tx.navy, fontSize: 13)),
                        Text(_direccion!.ciudad,
                          style: const TextStyle(color: Tx.grey, fontSize: 12)),
                      ])
                    : const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Seleccionar dirección',
                          style: TextStyle(fontWeight: FontWeight.w600, color: Tx.navy)),
                        Text('Toca para elegir',
                          style: TextStyle(color: Tx.gold, fontSize: 12)),
                      ])),
                const Icon(Icons.chevron_right_rounded, color: Tx.grey),
              ])),
          ),
          ...List.generate(cart.items.length, (i) {
            final item = cart.items[i];
            return Dismissible(
              key: Key(item.key),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => cart.eliminar(i),
              background: Container(
                alignment: Alignment.centerRight,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.only(right: 18),
                decoration: BoxDecoration(
                  color: Tx.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.delete_rounded, color: Tx.danger)),
              child: _CartItemCard(
                item: item, index: i,
                onUpdate: (qty) => cart.actualizar(i, qty)));
          }),
        ],
      )),
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Tx.navy,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          boxShadow: [BoxShadow(
            color: Tx.navy.withOpacity(0.4),
            blurRadius: 20, offset: const Offset(0, -6))]),
        child: SafeArea(top: false, child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Subtotal', style: TextStyle(color: Colors.white54, fontSize: 13)),
            Text('\$${cart.total.toStringAsFixed(0)}',
              style: const TextStyle(color: Tx.white, fontSize: 13)),
          ]),
          const SizedBox(height: 8),
          const Divider(color: Colors.white12),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('TOTAL', style: TextStyle(
                color: Colors.white54, fontSize: 10, letterSpacing: 1.5)),
              Text('\$${totalFinal.toStringAsFixed(0)}', style: const TextStyle(
                color: Tx.gold, fontSize: 24, fontWeight: FontWeight.w900)),
            ]),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Tx.gold, foregroundColor: Tx.navy,
                minimumSize: const Size(0, 48),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () => _confirmarPedido(cart),
              icon: const Icon(Icons.send_rounded, size: 16),
              label: const Text('CONFIRMAR', style: TxText.button)),
          ]),
        ])),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────
// ORDERS VIEW
// ─────────────────────────────────────────────────────────────────
class OrdersView extends StatelessWidget {
  const OrdersView({super.key});
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('pedidos')
          .where('clienteId', isEqualTo: uid)
          .orderBy('creadoEn', descending: true).snapshots(),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: TxLoader());
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              padding: const EdgeInsets.all(26),
              decoration: const BoxDecoration(color: Tx.cream, shape: BoxShape.circle),
              child: const Icon(Icons.receipt_long_outlined, size: 52, color: Tx.grey)),
            const SizedBox(height: 18),
            const Text('Sin pedidos aún', style: TxText.h3),
            const SizedBox(height: 6),
            const Text('Tus pedidos aparecerán aquí', style: TextStyle(color: Tx.grey)),
          ]));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(14),
          physics: const BouncingScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (_, i) => _PedidoCard(pedido: PedidoModel.fromFirestore(docs[i])));
      });
  }
}

// ─────────────────────────────────────────────────────────────────
// PROFILE VIEW
// ─────────────────────────────────────────────────────────────────
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final user = FirebaseAuth.instance.currentUser!;
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('usuarios').doc(uid).snapshots(),
      builder: (_, snap) {
        final data = snap.data?.data() as Map<String, dynamic>? ?? {};
        final nombre = data['nombre'] ?? user.displayName ?? 'Usuario';
        final email  = data['email'] ?? user.email ?? '';
        final saldo  = (data['saldo'] ?? 0).toDouble();
        final credito = (data['credito'] ?? 0).toDouble();
        return ListView(
          padding: const EdgeInsets.all(14),
          physics: const BouncingScrollPhysics(),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: Tx.gradNavy, borderRadius: BorderRadius.circular(22)),
              child: Column(children: [
                Stack(children: [
                  Container(
                    width: 76, height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Tx.gold.withOpacity(0.2),
                      border: Border.all(color: Tx.gold, width: 2)),
                    child: (data['fotoPerfil'] != null &&
                        (data['fotoPerfil'] as String).isNotEmpty)
                        ? ClipOval(child: Image.network(data['fotoPerfil'], fit: BoxFit.cover))
                        : const Icon(Icons.person_rounded, size: 38, color: Tx.gold)),
                  Positioned(
                    bottom: 0, right: 0,
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, _txSlide(EditProfileView(data: data))),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(color: Tx.gold, shape: BoxShape.circle),
                        child: const Icon(Icons.edit_rounded, size: 13, color: Tx.navy)))),
                ]),
                const SizedBox(height: 10),
                Text(nombre, style: const TextStyle(
                  color: Tx.white, fontSize: 16, fontWeight: FontWeight.w700)),
                Text(email, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: _WalletChip(label: 'Saldo', value: saldo)),
                  const SizedBox(width: 10),
                  Expanded(child: _WalletChip(label: 'Crédito', value: credito)),
                ]),
              ])),
            const SizedBox(height: 16),
            _ProfileSection(items: [
              _ProfileItem(
                icon: Icons.person_outline_rounded, label: 'Editar perfil',
                onTap: () => Navigator.push(context, _txSlide(EditProfileView(data: data)))),
              _ProfileItem(
                icon: Icons.location_on_outlined, label: 'Mis direcciones',
                onTap: () => Navigator.push(context, _txSlide(const DireccionesView()))),
              _ProfileItem(
                icon: Icons.notifications_outlined, label: 'Notificaciones',
                onTap: () => Navigator.push(context, _txSlide(const NotificationsView()))),
              _ProfileItem(
                icon: Icons.account_balance_wallet_outlined, label: 'Billetera',
                onTap: () => Navigator.push(context, _txSlide(const WalletView()))),
            ]),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Tx.white, borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                leading: const Icon(Icons.logout_rounded, color: Tx.danger),
                title: const Text('Cerrar sesión',
                  style: TextStyle(color: Tx.danger, fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right_rounded, color: Tx.danger),
                onTap: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      title: const Text('¿Cerrar sesión?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar')),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Tx.danger),
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Salir')),
                      ]));
                  if (ok == true) await FirebaseAuth.instance.signOut();
                })),
            const SizedBox(height: 24),
          ],
        );
      });
  }
}

// ─────────────────────────────────────────────────────────────────
// ADMIN SHELL — Declaración completa y correcta
// ─────────────────────────────────────────────────────────────────
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});
  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _tab = 0;
  final List<Widget> _views = const [
    AdminDashboardView(), AdminInventoryView(), AdminOrdersView(),
    AdminUsersView(), AdminPromoView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(shape: BoxShape.circle, gradient: Tx.gradGold),
            child: const Icon(Icons.checkroom_rounded, size: 14, color: Tx.navy)),
          const SizedBox(width: 10),
          const Text('TEXANOS · ADMIN',
            style: TextStyle(fontSize: 13, letterSpacing: 1.5)),
        ]),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: Tx.gold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Tx.gold.withOpacity(0.4))),
            child: const Text('ADMIN', style: TextStyle(
              color: Tx.gold, fontSize: 10,
              fontWeight: FontWeight.w800, letterSpacing: 1.5))),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => FirebaseAuth.instance.signOut()),
        ],
      ),
      body: IndexedStack(index: _tab, children: _views),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded), label: 'Dashboard'),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2_rounded), label: 'Inventario'),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded), label: 'Pedidos'),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_rounded), label: 'Usuarios'),
          NavigationDestination(
            icon: Icon(Icons.local_offer_outlined),
            selectedIcon: Icon(Icons.local_offer_rounded), label: 'Promos'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// ADMIN: DASHBOARD
// ─────────────────────────────────────────────────────────────────
class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('pedidos').snapshots(),
      builder: (_, pedSnap) => StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('productos').snapshots(),
        builder: (_, prodSnap) {
          final pedidos = pedSnap.data?.docs ?? [];
          final prods   = prodSnap.data?.docs ?? [];
          double ventas = 0;
          final Map<String, int>    ventasProd = {};
          final Map<String, double> ventasCli  = {};
          for (final p in pedidos) {
            final d = p.data() as Map<String, dynamic>;
            ventas += (d['total'] ?? 0).toDouble();
            ventasCli[d['clienteEmail'] ?? ''] =
              (ventasCli[d['clienteEmail']] ?? 0) + (d['total'] ?? 0).toDouble();
            for (final item in (d['items'] as List? ?? [])) {
              ventasProd[item['nombre'] ?? ''] =
                (ventasProd[item['nombre']] ?? 0) + (item['cantidad'] ?? 0) as int;
            }
          }
          final topProds = ventasProd.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          final topCli = ventasCli.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          final stockBajo = prods.where((p) => ((p.data() as Map)['stock'] ?? 0) < 8).length;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(14),
            physics: const BouncingScrollPhysics(),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Dashboard', style: TxText.h1),
              const Text('Analítica en tiempo real',
                style: TextStyle(color: Tx.grey, fontSize: 13)),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _KpiTile(
                  label: 'Ventas', value: '\$${ventas.toStringAsFixed(0)}',
                  icon: Icons.trending_up_rounded, accent: Tx.gold)),
                const SizedBox(width: 10),
                Expanded(child: _KpiTile(
                  label: 'Pedidos', value: '${pedidos.length}',
                  icon: Icons.receipt_long_rounded, accent: Tx.success)),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _KpiTile(
                  label: 'Productos', value: '${prods.length}',
                  icon: Icons.inventory_2_rounded, accent: const Color(0xFFA07FCA))),
                const SizedBox(width: 10),
                Expanded(child: _KpiTile(
                  label: 'Stock bajo', value: '$stockBajo',
                  icon: Icons.warning_rounded, accent: Tx.danger)),
              ]),
              if (topProds.isNotEmpty) ...[
                const SizedBox(height: 22),
                const Text('Top Productos', style: TxText.h3),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Tx.white, borderRadius: BorderRadius.circular(16)),
                  child: Column(children: topProds.take(5).map((e) {
                    final pct = e.value / topProds.first.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Expanded(child: Text(e.key, style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600, color: Tx.navy),
                            overflow: TextOverflow.ellipsis)),
                          Text('${e.value} uds', style: const TextStyle(
                            color: Tx.gold, fontWeight: FontWeight.w700, fontSize: 12)),
                        ]),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct, minHeight: 8,
                            backgroundColor: Tx.greyLight,
                            valueColor: const AlwaysStoppedAnimation(Tx.gold))),
                      ]));
                  }).toList())),
              ],
              if (topCli.isNotEmpty) ...[
                const SizedBox(height: 22),
                const Text('Top Clientes', style: TxText.h3),
                const SizedBox(height: 10),
                ...topCli.take(5).map((e) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Tx.white, borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        gradient: Tx.gradNavy, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.person, color: Tx.gold, size: 20)),
                    const SizedBox(width: 10),
                    Expanded(child: Text(e.key, style: const TextStyle(
                      color: Tx.navy, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis)),
                    Text('\$${e.value.toStringAsFixed(0)}', style: const TextStyle(
                      color: Tx.gold, fontWeight: FontWeight.w800, fontSize: 13)),
                  ]))),
              ],
            ]));
        }));
  }
}

// ─────────────────────────────────────────────────────────────────
// ADMIN: INVENTARIO
// ─────────────────────────────────────────────────────────────────
class AdminInventoryView extends StatelessWidget {
  const AdminInventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Tx.cream,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Tx.navy, foregroundColor: Tx.gold,
        icon: const Icon(Icons.add_rounded), label: const Text('Nuevo Producto'),
        onPressed: () => Navigator.push(context, _txSlide(const ProductFormView()))),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('productos').snapshots(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: TxLoader());
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 56, color: Tx.grey),
                Text('Sin productos', style: TextStyle(color: Tx.grey)),
              ]));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final prod = ProductoModel.fromFirestore(docs[i]);
              return _AdminProductTile(
                producto: prod,
                onEdit: () => Navigator.push(context, _txSlide(ProductFormView(producto: prod))),
                onDelete: () => _confirmDelete(context, prod.id));
            });
        }),
    );
  }

  void _confirmDelete(BuildContext ctx, String id) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('¿Eliminar producto?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Tx.danger),
            onPressed: () {
              FirebaseFirestore.instance.collection('productos').doc(id).delete();
              Navigator.pop(ctx);
            },
            child: const Text('Eliminar')),
        ]));
  }
}

// ─────────────────────────────────────────────────────────────────
// ADMIN: PEDIDOS
// ─────────────────────────────────────────────────────────────────
class AdminOrdersView extends StatelessWidget {
  const AdminOrdersView({super.key});
  static const _estados = ['pendiente', 'confirmado', 'enviado', 'entregado', 'cancelado'];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('pedidos')
          .orderBy('creadoEn', descending: true).snapshots(),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: TxLoader());
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('Sin pedidos', style: TextStyle(color: Tx.grey)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(14),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final id = docs[i].id;
            final estado = data['estado'] ?? 'pendiente';
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Tx.white, borderRadius: BorderRadius.circular(14)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Pedido #${id.substring(0, 6).toUpperCase()}',
                    style: const TextStyle(fontWeight: FontWeight.w800, color: Tx.navy)),
                  _EstadoBadge(estado: estado),
                ]),
                const SizedBox(height: 4),
                Text(data['clienteEmail'] ?? '',
                  style: const TextStyle(color: Tx.grey, fontSize: 12)),
                Text('\$${(data['total'] ?? 0).toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Tx.gold, fontWeight: FontWeight.w900, fontSize: 17)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 34,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _estados.length,
                    itemBuilder: (_, j) {
                      final e = _estados[j];
                      final active = e == estado;
                      return GestureDetector(
                        onTap: () async {
                          await FirebaseFirestore.instance
                              .collection('pedidos').doc(id)
                              .update({'estado': e});
                          if (data['clienteId'] != null) {
                            await FirebaseFirestore.instance
                                .collection('usuarios')
                                .doc(data['clienteId'])
                                .collection('notificaciones').add({
                              'titulo': 'Estado actualizado',
                              'mensaje': 'Tu pedido ahora está: ${e.toUpperCase()}',
                              'tipo': 'estado', 'leida': false,
                              'fecha': FieldValue.serverTimestamp(),
                            });
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: active ? Tx.navy : Tx.cream,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: active ? Tx.gold : Tx.greyLight, width: 1.5)),
                          child: Text(e.toUpperCase(), style: TextStyle(
                            fontSize: 9, fontWeight: FontWeight.w700,
                            color: active ? Tx.gold : Tx.grey))));
                    })),
              ]));
          });
      });
  }
}

// ─────────────────────────────────────────────────────────────────
// ADMIN: USUARIOS
// ─────────────────────────────────────────────────────────────────
class AdminUsersView extends StatelessWidget {
  const AdminUsersView({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('usuarios').snapshots(),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: TxLoader());
        }
        final docs = snap.data?.docs ?? [];
        return ListView.builder(
          padding: const EdgeInsets.all(14),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final id = docs[i].id;
            final aprobado = data['aprobado'] ?? false;
            final rol = data['rol'] ?? 'cliente';
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Tx.white,
                borderRadius: BorderRadius.circular(14),
                border: !aprobado ? Border.all(color: Tx.warning.withOpacity(0.4)) : null),
              child: Row(children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: rol == 'admin' ? Tx.gold.withOpacity(0.15) : Tx.cream,
                    borderRadius: BorderRadius.circular(10)),
                  child: Icon(
                    rol == 'admin'
                        ? Icons.admin_panel_settings_rounded
                        : Icons.person_rounded,
                    color: rol == 'admin' ? Tx.gold : Tx.navy, size: 20)),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(data['nombre'] ?? data['email'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700, color: Tx.navy, fontSize: 13)),
                  Text(data['email'] ?? '',
                    style: const TextStyle(color: Tx.grey, fontSize: 11)),
                  Row(children: [
                    _TagBadge(
                      label: aprobado ? 'Aprobado' : 'Pendiente',
                      color: aprobado ? Tx.success : Tx.warning),
                    const SizedBox(width: 6),
                    _TagBadge(label: rol.toUpperCase(), color: Tx.navy),
                  ]),
                ])),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: Tx.grey),
                  onSelected: (v) {
                    final ref = FirebaseFirestore.instance.collection('usuarios').doc(id);
                    if (v == 'aprobar') ref.update({'aprobado': true});
                    if (v == 'admin')   ref.update({'rol': 'admin'});
                    if (v == 'cliente') ref.update({'rol': 'cliente'});
                    if (v == 'delete')  ref.delete();
                  },
                  itemBuilder: (_) => [
                    if (!aprobado)
                      const PopupMenuItem(value: 'aprobar', child: Text('Aprobar')),
                    const PopupMenuItem(value: 'admin', child: Text('Hacer Admin')),
                    const PopupMenuItem(value: 'cliente', child: Text('Hacer Cliente')),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Eliminar', style: TextStyle(color: Tx.danger))),
                  ]),
              ]));
          });
      });
  }
}

// ─────────────────────────────────────────────────────────────────
// ADMIN: PROMOS
// ─────────────────────────────────────────────────────────────────
class AdminPromoView extends StatefulWidget {
  const AdminPromoView({super.key});
  @override
  State<AdminPromoView> createState() => _AdminPromoViewState();
}

class _AdminPromoViewState extends State<AdminPromoView> {
  final _tit  = TextEditingController();
  final _desc = TextEditingController();
  final _min  = TextEditingController();
  final _pct  = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Reglas de Negocio', style: TxText.h1),
        const Text('Descuentos y promociones', style: TextStyle(color: Tx.grey)),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Tx.white, borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Descuento por volumen',
              style: TextStyle(fontWeight: FontWeight.w700, color: Tx.navy)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TxInput(
                controller: _min, label: 'Cant. mínima',
                icon: Icons.numbers_rounded, keyboardType: TextInputType.number)),
              const SizedBox(width: 10),
              Expanded(child: TxInput(
                controller: _pct, label: 'Descuento %',
                icon: Icons.percent_rounded, keyboardType: TextInputType.number)),
            ]),
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: () {
                if (_min.text.isEmpty || _pct.text.isEmpty) return;
                FirebaseFirestore.instance.collection('descuentos').add({
                  'minCantidad': int.tryParse(_min.text) ?? 0,
                  'porcentaje': double.tryParse(_pct.text) ?? 0,
                  'activo': true, 'creadoEn': FieldValue.serverTimestamp(),
                });
                _min.clear(); _pct.clear();
              },
              child: const Text('AGREGAR DESCUENTO'))),
          ])),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Tx.white, borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Nueva Promoción',
              style: TextStyle(fontWeight: FontWeight.w700, color: Tx.navy)),
            const SizedBox(height: 12),
            TxInput(controller: _tit, label: 'Título', icon: Icons.campaign_rounded),
            const SizedBox(height: 10),
            TxInput(controller: _desc, label: 'Descripción', icon: Icons.description_rounded),
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Tx.gold, foregroundColor: Tx.navy),
              onPressed: () {
                if (_tit.text.isEmpty) return;
                FirebaseFirestore.instance.collection('promociones').add({
                  'titulo': _tit.text.trim(), 'descripcion': _desc.text.trim(),
                  'activo': true, 'creadoEn': FieldValue.serverTimestamp(),
                });
                _tit.clear(); _desc.clear();
              },
              child: const Text('PUBLICAR PROMOCIÓN', style: TxText.button))),
          ])),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// PRODUCT FORM — Con subida a Firebase Storage
// ─────────────────────────────────────────────────────────────────
class ProductFormView extends StatefulWidget {
  final ProductoModel? producto;
  const ProductFormView({super.key, this.producto});
  @override
  State<ProductFormView> createState() => _ProductFormViewState();
}

class _ProductFormViewState extends State<ProductFormView> {
  late final _nombre  = TextEditingController(text: widget.producto?.nombre ?? '');
  late final _desc    = TextEditingController(text: widget.producto?.descripcion ?? '');
  late final _precio  = TextEditingController(
    text: widget.producto != null ? widget.producto!.precio.toString() : '');
  late final _stock   = TextEditingController(
    text: widget.producto != null ? widget.producto!.stock.toString() : '');
  late final _badge   = TextEditingController(text: widget.producto?.badge ?? '');
  late final _imgUrl  = TextEditingController();
  late final _catCtrl = TextEditingController(text: widget.producto?.categoria ?? 'jeans');

  List<String> _tallas   = [];
  List<String> _colores  = [];
  List<String> _imagenes = [];
  bool _loading = false;
  bool _subiendoImagen = false;

  static const _tallasOpts  = ['28', '30', '32', '34', '36', '38', '40'];
  static const _coloresOpts = [
    'Azul clásico', 'Negro', 'Gris', 'Blanco', 'Azul oscuro', 'Café', 'Verde',
  ];
  static const _categorias = [
    'jeans', 'slim', 'straight', 'bootcut', 'skinny', 'relaxed',
  ];

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tallas   = List<String>.from(widget.producto?.tallas   ?? []);
    _colores  = List<String>.from(widget.producto?.colores  ?? []);
    _imagenes = List<String>.from(widget.producto?.imagenes ?? []);
  }

  Future<void> _agregarDesdeGaleria() async {
    try {
      final List<XFile> imagenes =
          await _picker.pickMultiImage(imageQuality: 80, maxWidth: 1200);
      if (imagenes.isEmpty) return;
      setState(() => _subiendoImagen = true);
      for (final img in imagenes) {
        await _subirImagen(File(img.path));
      }
      setState(() => _subiendoImagen = false);
      if (mounted) {
        TxSnack.show(context, '${imagenes.length} imagen(es) subida(s) ✓', type: 'success');
      }
    } catch (e) {
      setState(() => _subiendoImagen = false);
      if (mounted) TxSnack.show(context, 'Error al acceder a galería', type: 'error');
    }
  }

  Future<void> _agregarDesdeCamara() async {
    try {
      final XFile? img = await _picker.pickImage(
        source: ImageSource.camera, imageQuality: 80, maxWidth: 1200);
      if (img == null) return;
      setState(() => _subiendoImagen = true);
      await _subirImagen(File(img.path));
      setState(() => _subiendoImagen = false);
      if (mounted) TxSnack.show(context, 'Foto subida ✓', type: 'success');
    } catch (e) {
      setState(() => _subiendoImagen = false);
      if (mounted) TxSnack.show(context, 'Error al acceder a cámara', type: 'error');
    }
  }

  Future<void> _subirImagen(File archivo) async {
    try {
      final nombre =
          'productos/${DateTime.now().millisecondsSinceEpoch}_${_imagenes.length}.jpg';
      final ref = FirebaseStorage.instance.ref().child(nombre);
      final metadata = SettableMetadata(contentType: 'image/jpeg');
      final task = ref.putFile(archivo, metadata);
      final snapshot = await task.whenComplete(() {});
      if (snapshot.state == TaskState.success) {
        final url = await ref.getDownloadURL();
        setState(() => _imagenes.add(url));
      } else {
        throw Exception('Upload no completó: ${snapshot.state}');
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        TxSnack.show(context,
          'Error Storage [${e.code}]: ${e.message ?? "desconocido"}',
          type: 'error');
      }
    } catch (e) {
      if (mounted) TxSnack.show(context, 'Error al subir: $e', type: 'error');
    }
  }

  void _agregarUrl() {
    final url = _imgUrl.text.trim();
    if (url.isEmpty) return;
    setState(() { _imagenes.add(url); _imgUrl.clear(); });
  }

  void _mostrarOpcionesImagen() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Tx.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 38, height: 4,
            decoration: BoxDecoration(
              color: Tx.greyLight, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          const Text('Agregar imagen', style: TxText.h3),
          const SizedBox(height: 20),
          _OpcionImagenTile(
            icon: Icons.photo_library_rounded,
            titulo: 'Desde galería',
            subtitulo: 'Selecciona una o varias fotos',
            color: Tx.navy,
            onTap: () { Navigator.pop(context); _agregarDesdeGaleria(); }),
          const SizedBox(height: 12),
          _OpcionImagenTile(
            icon: Icons.camera_alt_rounded,
            titulo: 'Tomar foto',
            subtitulo: 'Usa la cámara del dispositivo',
            color: Tx.gold,
            onTap: () { Navigator.pop(context); _agregarDesdeCamara(); }),
          const SizedBox(height: 12),
          _OpcionImagenTile(
            icon: Icons.link_rounded,
            titulo: 'Pegar URL',
            subtitulo: 'Ingresa el enlace de una imagen web',
            color: Tx.info,
            onTap: () { Navigator.pop(context); _mostrarDialogURL(); }),
          const SizedBox(height: 10),
        ])));
  }

  void _mostrarDialogURL() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('URL de imagen'),
        content: TxInput(controller: _imgUrl, label: 'https://...', icon: Icons.link_rounded),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () { _agregarUrl(); Navigator.pop(context); },
            child: const Text('Agregar')),
        ]));
  }

  Future<void> _guardar() async {
    if (_nombre.text.isEmpty || _precio.text.isEmpty) {
      TxSnack.show(context, 'Completa nombre y precio', type: 'warning');
      return;
    }
    setState(() => _loading = true);
    try {
      final data = {
        'nombre': _nombre.text.trim(), 'descripcion': _desc.text.trim(),
        'precio': double.tryParse(_precio.text) ?? 0,
        'stock': int.tryParse(_stock.text) ?? 0,
        'tallas': _tallas, 'colores': _colores, 'imagenes': _imagenes,
        'badge': _badge.text.trim(), 'activo': true,
        'vendidos': widget.producto?.vendidos ?? 0,
        'categoria': _catCtrl.text.trim(),
        'actualizadoEn': FieldValue.serverTimestamp(),
      };
      if (widget.producto == null) {
        await FirebaseFirestore.instance.collection('productos').add(data);
      } else {
        await FirebaseFirestore.instance.collection('productos')
            .doc(widget.producto!.id).update(data);
      }
      if (mounted) {
        TxSnack.show(context, 'Producto guardado ✓', type: 'success');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) TxSnack.show(context, 'Error: $e', type: 'error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.producto == null ? 'Nuevo Producto' : 'Editar Producto')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        physics: const BouncingScrollPhysics(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Imágenes del producto', style: TxText.h3),
          const SizedBox(height: 4),
          const Text('Agrega fotos desde galería, cámara o URL',
            style: TextStyle(color: Tx.grey, fontSize: 12)),
          const SizedBox(height: 14),
          SizedBox(
            height: 110,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                GestureDetector(
                  onTap: _mostrarOpcionesImagen,
                  child: Container(
                    width: 100, height: 100,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: _subiendoImagen ? Tx.navy.withOpacity(0.05) : Tx.cream,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Tx.navy.withOpacity(0.3), width: 1.5)),
                    child: _subiendoImagen
                        ? const Center(child: TxLoader())
                        : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: Tx.gradNavy, shape: BoxShape.circle,
                                boxShadow: [BoxShadow(
                                  color: Tx.navy.withOpacity(0.3),
                                  blurRadius: 8, offset: const Offset(0, 3))]),
                              child: const Icon(Icons.add_photo_alternate_rounded,
                                color: Tx.gold, size: 22)),
                            const SizedBox(height: 6),
                            const Text('Agregar', style: TextStyle(
                              color: Tx.navy, fontSize: 10, fontWeight: FontWeight.w700)),
                          ]))),
                ..._imagenes.asMap().entries.map((e) => Stack(children: [
                  Container(
                    width: 100, height: 100,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14), color: Tx.cream,
                      boxShadow: [BoxShadow(
                        color: Colors.black.withOpacity(0.08), blurRadius: 6)]),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(e.value, fit: BoxFit.cover,
                      loadingBuilder: (_, child, prog) =>
                          prog == null ? child : const _ImgSkeleton(),
                      errorBuilder: (_, __, ___) => const _NoImgPlaceholder())),
                  Positioned(
                    bottom: 5, left: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Tx.success.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(6)),
                      child: const Text('✓ OK', style: TextStyle(
                        color: Tx.white, fontSize: 7, fontWeight: FontWeight.w800)))),
                  Positioned(
                    top: 4, right: 14,
                    child: GestureDetector(
                      onTap: () => setState(() => _imagenes.removeAt(e.key)),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Tx.danger, shape: BoxShape.circle,
                          boxShadow: [BoxShadow(
                            color: Tx.danger.withOpacity(0.3), blurRadius: 4)]),
                        child: const Icon(Icons.close_rounded, color: Tx.white, size: 12)))),
                ])).toList(),
              ],
            ),
          ),
          if (_imagenes.isEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Tx.gold.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Tx.gold.withOpacity(0.2))),
              child: const Row(children: [
                Icon(Icons.info_outline_rounded, color: Tx.gold, size: 14),
                SizedBox(width: 8),
                Expanded(child: Text(
                  'Las imágenes se suben a Firebase Storage y serán visibles para los clientes',
                  style: TextStyle(color: Tx.gold, fontSize: 11))),
              ])),
          ],
          const SizedBox(height: 20),
          _FieldSection(title: 'Información básica', children: [
            TxInput(controller: _nombre, label: 'Nombre del producto *', icon: Icons.checkroom_rounded),
            TxInput(controller: _desc, label: 'Descripción', icon: Icons.description_rounded),
            TxInput(controller: _badge, label: 'Badge (ej: NUEVO, HOT)', icon: Icons.local_fire_department_rounded),
          ]),
          const SizedBox(height: 18),
          _FieldSection(title: 'Precio y stock', children: [
            Row(children: [
              Expanded(child: TxInput(
                controller: _precio, label: 'Precio *',
                icon: Icons.attach_money_rounded, keyboardType: TextInputType.number)),
              const SizedBox(width: 10),
              Expanded(child: TxInput(
                controller: _stock, label: 'Stock',
                icon: Icons.inventory_rounded, keyboardType: TextInputType.number)),
            ]),
          ]),
          const SizedBox(height: 18),
          const Text('Categoría',
            style: TextStyle(fontWeight: FontWeight.w700, color: Tx.navy)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _categorias.map((c) => GestureDetector(
              onTap: () => setState(() => _catCtrl.text = c),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _catCtrl.text == c ? Tx.navy : Tx.cream,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _catCtrl.text == c ? Tx.gold : Tx.greyLight, width: 1.5)),
                child: Text(c, style: TextStyle(
                  color: _catCtrl.text == c ? Tx.gold : Tx.navy,
                  fontWeight: FontWeight.w600, fontSize: 12))))).toList()),
          const SizedBox(height: 18),
          const Text('Tallas',
            style: TextStyle(fontWeight: FontWeight.w700, color: Tx.navy)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _tallasOpts.map((t) {
              final sel = _tallas.contains(t);
              return GestureDetector(
                onTap: () => setState(
                  () => sel ? _tallas.remove(t) : _tallas.add(t)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    color: sel ? Tx.navy : Tx.cream,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: sel ? Tx.gold : Tx.greyLight, width: 1.5)),
                  child: Center(child: Text(t, style: TextStyle(
                    color: sel ? Tx.gold : Tx.navy,
                    fontWeight: FontWeight.w700, fontSize: 12)))));
            }).toList()),
          const SizedBox(height: 18),
          const Text('Colores',
            style: TextStyle(fontWeight: FontWeight.w700, color: Tx.navy)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _coloresOpts.map((c) {
              final sel = _colores.contains(c);
              return GestureDetector(
                onTap: () => setState(
                  () => sel ? _colores.remove(c) : _colores.add(c)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? Tx.navy : Tx.cream,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: sel ? Tx.gold : Tx.greyLight, width: 1.5)),
                  child: Text(c, style: TextStyle(
                    color: sel ? Tx.gold : Tx.navy,
                    fontWeight: FontWeight.w600, fontSize: 12))));
            }).toList()),
          const SizedBox(height: 28),
          _loading
              ? const Center(child: TxLoader())
              : ElevatedButton(
                  onPressed: _guardar,
                  child: Text(
                    widget.producto == null ? 'CREAR PRODUCTO' : 'GUARDAR CAMBIOS',
                    style: TxText.button)),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// EDIT PROFILE VIEW
// ─────────────────────────────────────────────────────────────────
class EditProfileView extends StatefulWidget {
  final Map<String, dynamic> data;
  const EditProfileView({super.key, required this.data});
  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  late final _nombre   = TextEditingController(text: widget.data['nombre'] ?? '');
  late final _telefono = TextEditingController(text: widget.data['telefono'] ?? '');
  late final _cedula   = TextEditingController(text: widget.data['cedula'] ?? '');
  late final _ciudad   = TextEditingController(text: widget.data['ciudad'] ?? '');
  late final _depto    = TextEditingController(text: widget.data['departamento'] ?? '');
  late final _pais     = TextEditingController(text: widget.data['pais'] ?? 'Colombia');
  bool _loading = false;

  Future<void> _guardar() async {
    setState(() => _loading = true);
    try {
      await FirebaseFirestore.instance.collection('usuarios')
          .doc(FirebaseAuth.instance.currentUser!.uid).update({
        'nombre': _nombre.text.trim(), 'telefono': _telefono.text.trim(),
        'cedula': _cedula.text.trim(), 'ciudad': _ciudad.text.trim(),
        'departamento': _depto.text.trim(), 'pais': _pais.text.trim(),
        'actualizadoEn': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        TxSnack.show(context, 'Perfil actualizado', type: 'success');
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) TxSnack.show(context, 'Error al guardar', type: 'error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        physics: const BouncingScrollPhysics(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _FieldSection(title: 'Información personal', children: [
            TxInput(controller: _nombre, label: 'Nombre completo', icon: Icons.person_outline_rounded),
            TxInput(controller: _cedula, label: 'Cédula / Documento',
              icon: Icons.badge_outlined, keyboardType: TextInputType.number),
          ]),
          const SizedBox(height: 18),
          _FieldSection(title: 'Contacto', children: [
            TxInput(controller: _telefono, label: 'Teléfono',
              icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
          ]),
          const SizedBox(height: 18),
          _FieldSection(title: 'Ubicación', children: [
            TxInput(controller: _ciudad, label: 'Ciudad', icon: Icons.location_city_outlined),
            TxInput(controller: _depto, label: 'Departamento', icon: Icons.map_outlined),
            TxInput(controller: _pais, label: 'País', icon: Icons.public_outlined),
          ]),
          const SizedBox(height: 28),
          _loading
              ? const Center(child: TxLoader())
              : ElevatedButton(onPressed: _guardar, child: const Text('GUARDAR CAMBIOS')),
        ])));
  }
}

// ─────────────────────────────────────────────────────────────────
// DIRECCIONES VIEW
// ─────────────────────────────────────────────────────────────────
class DireccionesView extends StatefulWidget {
  final bool seleccionar;
  const DireccionesView({super.key, this.seleccionar = false});
  @override
  State<DireccionesView> createState() => _DireccionesViewState();
}

class _DireccionesViewState extends State<DireccionesView> {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  void _abrirFormulario([DireccionModel? dir]) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DireccionForm(
        uid: uid, direccion: dir, onGuardado: () => setState(() {})));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Direcciones')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Tx.navy, foregroundColor: Tx.gold,
        icon: const Icon(Icons.add_location_rounded), label: const Text('Nueva'),
        onPressed: _abrirFormulario),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('usuarios').doc(uid)
            .collection('direcciones').snapshots(),
        builder: (_, snap) {
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.location_off_outlined, size: 52, color: Tx.grey),
              SizedBox(height: 10),
              Text('Sin direcciones guardadas', style: TextStyle(color: Tx.grey)),
            ]));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final dir = DireccionModel.fromMap(docs[i].id, docs[i].data() as Map<String, dynamic>);
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Tx.white,
                  borderRadius: BorderRadius.circular(14),
                  border: dir.esPrincipal ? Border.all(color: Tx.gold, width: 1.5) : null),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: dir.esPrincipal ? Tx.gold.withOpacity(0.1) : Tx.cream,
                      borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.location_on_rounded,
                      color: dir.esPrincipal ? Tx.gold : Tx.grey, size: 20)),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(dir.nombre, style: const TextStyle(
                      fontWeight: FontWeight.w700, color: Tx.navy, fontSize: 13)),
                    Text(dir.calle, style: const TextStyle(color: Tx.grey, fontSize: 12)),
                    Text(dir.ciudad, style: const TextStyle(color: Tx.grey, fontSize: 12)),
                  ])),
                  Column(children: [
                    if (widget.seleccionar)
                      TextButton(
                        onPressed: () => Navigator.pop(context, dir),
                        child: const Text('Elegir'))
                    else
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Tx.navy, size: 18),
                        onPressed: () => _abrirFormulario(dir)),
                    IconButton(
                      icon: const Icon(Icons.delete_rounded, color: Tx.danger, size: 18),
                      onPressed: () => FirebaseFirestore.instance
                          .collection('usuarios').doc(uid)
                          .collection('direcciones').doc(dir.id).delete()),
                  ]),
                ]));
            });
        }),
    );
  }
}

class _DireccionForm extends StatefulWidget {
  final String uid;
  final DireccionModel? direccion;
  final VoidCallback onGuardado;
  const _DireccionForm({required this.uid, this.direccion, required this.onGuardado});
  @override
  State<_DireccionForm> createState() => _DireccionFormState();
}

class _DireccionFormState extends State<_DireccionForm> {
  late final _nom = TextEditingController(text: widget.direccion?.nombre ?? '');
  late final _tel = TextEditingController(text: widget.direccion?.telefono ?? '');
  late final _cal = TextEditingController(text: widget.direccion?.calle ?? '');
  late final _ciu = TextEditingController(text: widget.direccion?.ciudad ?? '');
  late final _dep = TextEditingController(text: widget.direccion?.departamento ?? '');
  late final _pai = TextEditingController(text: widget.direccion?.pais ?? 'Colombia');
  bool _esPrincipal = false;

  @override
  void initState() {
    super.initState();
    _esPrincipal = widget.direccion?.esPrincipal ?? false;
  }

  Future<void> _guardar() async {
    final data = {
      'nombre': _nom.text.trim(), 'telefono': _tel.text.trim(),
      'calle': _cal.text.trim(), 'ciudad': _ciu.text.trim(),
      'departamento': _dep.text.trim(), 'pais': _pai.text.trim(),
      'esPrincipal': _esPrincipal,
    };
    final ref = FirebaseFirestore.instance
        .collection('usuarios').doc(widget.uid).collection('direcciones');
    if (widget.direccion != null) {
      await ref.doc(widget.direccion!.id).update(data);
    } else {
      await ref.add(data);
    }
    widget.onGuardado();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: Tx.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    padding: EdgeInsets.only(
      left: 22, right: 22, top: 22,
      bottom: MediaQuery.of(context).viewInsets.bottom + 28),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(child: Container(
            width: 38, height: 4,
            decoration: BoxDecoration(
              color: Tx.greyLight, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 18),
          Text(widget.direccion != null ? 'Editar dirección' : 'Nueva dirección',
            style: TxText.h3),
          const SizedBox(height: 18),
          TxInput(controller: _nom, label: 'Nombre del destinatario', icon: Icons.person_outline_rounded),
          const SizedBox(height: 10),
          TxInput(controller: _tel, label: 'Teléfono',
            icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
          const SizedBox(height: 10),
          TxInput(controller: _cal, label: 'Dirección / Calle', icon: Icons.home_outlined),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: TxInput(controller: _ciu, label: 'Ciudad', icon: Icons.location_city_outlined)),
            const SizedBox(width: 10),
            Expanded(child: TxInput(controller: _dep, label: 'Depto.', icon: Icons.map_outlined)),
          ]),
          const SizedBox(height: 10),
          TxInput(controller: _pai, label: 'País', icon: Icons.public_outlined),
          SwitchListTile(
            value: _esPrincipal,
            onChanged: (v) => setState(() => _esPrincipal = v),
            activeColor: Tx.gold,
            title: const Text('Dirección principal',
              style: TextStyle(color: Tx.navy, fontWeight: FontWeight.w600)),
            contentPadding: EdgeInsets.zero),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _guardar, child: const Text('GUARDAR DIRECCIÓN')),
        ])));
}

// ─────────────────────────────────────────────────────────────────
// NOTIFICATIONS VIEW
// ─────────────────────────────────────────────────────────────────
class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  IconData _iconForTipo(String t) {
    switch (t) {
      case 'compra': return Icons.shopping_bag_rounded;
      case 'estado': return Icons.local_shipping_rounded;
      case 'promo':  return Icons.local_offer_rounded;
      default:       return Icons.notifications_rounded;
    }
  }

  Color _colorForTipo(String t) {
    switch (t) {
      case 'compra': return Tx.success;
      case 'estado': return Tx.info;
      case 'promo':  return Tx.gold;
      default:       return Tx.navy;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('usuarios').doc(uid)
            .collection('notificaciones')
            .orderBy('fecha', descending: true).snapshots(),
        builder: (_, snap) {
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.notifications_off_outlined, size: 52, color: Tx.grey),
              SizedBox(height: 10),
              Text('Sin notificaciones', style: TextStyle(color: Tx.grey)),
            ]));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final notif = NotificacionModel.fromFirestore(docs[i]);
              return GestureDetector(
                onTap: () => FirebaseFirestore.instance
                    .collection('usuarios').doc(uid)
                    .collection('notificaciones').doc(notif.id)
                    .update({'leida': true}),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: notif.leida ? Tx.white : Tx.navy.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(14),
                    border: notif.leida ? null : Border.all(color: Tx.navy.withOpacity(0.12))),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: _colorForTipo(notif.tipo).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10)),
                      child: Icon(_iconForTipo(notif.tipo),
                        color: _colorForTipo(notif.tipo), size: 20)),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(notif.titulo, style: const TextStyle(
                        fontWeight: FontWeight.w700, color: Tx.navy, fontSize: 13)),
                      const SizedBox(height: 3),
                      Text(notif.mensaje, style: const TextStyle(
                        color: Tx.grey, fontSize: 12, height: 1.4)),
                    ])),
                    if (!notif.leida)
                      Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(
                          color: Tx.navy, shape: BoxShape.circle)),
                  ])));
            });
        }));
  }
}

// ─────────────────────────────────────────────────────────────────
// WALLET VIEW
// ─────────────────────────────────────────────────────────────────
class WalletView extends StatelessWidget {
  const WalletView({super.key});
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Billetera')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('usuarios').doc(uid).snapshots(),
        builder: (_, snap) {
          final data = snap.data?.data() as Map<String, dynamic>? ?? {};
          final saldo   = (data['saldo']   ?? 0).toDouble();
          final credito = (data['credito'] ?? 0).toDouble();
          return SingleChildScrollView(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: Tx.gradNavy,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [BoxShadow(
                    color: Tx.navy.withOpacity(0.4),
                    blurRadius: 20, offset: const Offset(0, 10))]),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Row(children: [
                    Icon(Icons.account_balance_wallet_rounded, color: Tx.gold),
                    SizedBox(width: 8),
                    Text('Billetera Texanos', style: TextStyle(color: Colors.white70)),
                  ]),
                  const SizedBox(height: 18),
                  const Text('Saldo disponible',
                    style: TextStyle(color: Colors.white38, fontSize: 12)),
                  Text('\$${saldo.toStringAsFixed(0)}', style: const TextStyle(
                    color: Tx.gold, fontSize: 34, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 14),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 14),
                  Row(children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Línea de crédito',
                        style: TextStyle(color: Colors.white38, fontSize: 11)),
                      Text('\$${credito.toStringAsFixed(0)}', style: const TextStyle(
                        color: Tx.white, fontWeight: FontWeight.w700, fontSize: 16)),
                    ]),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Tx.success.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20)),
                      child: const Text('Al día',
                        style: TextStyle(color: Tx.success, fontWeight: FontWeight.w700))),
                  ]),
                ])),
            ]));
        }));
  }
}

// ─────────────────────────────────────────────────────────────────
// LAUNCHES VIEW
// ─────────────────────────────────────────────────────────────────
class LaunchesView extends StatelessWidget {
  const LaunchesView({super.key});
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('Lanzamientos')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('lanzamientos').snapshots(),
        builder: (_, snap) {
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.new_releases_outlined, size: 52, color: Tx.grey),
              SizedBox(height: 10),
              Text('Sin lanzamientos por ahora', style: TextStyle(color: Tx.grey)),
            ]));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final reservas = List<dynamic>.from(data['reservas'] ?? []);
              final yaReservado = reservas.contains(uid);
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Tx.white, borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Tx.gold.withOpacity(0.3))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: Tx.gradGold,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)))),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('PRÓXIMAMENTE', style: TextStyle(
                        color: Tx.gold, fontSize: 10,
                        fontWeight: FontWeight.w800, letterSpacing: 2)),
                      const SizedBox(height: 8),
                      Text(data['nombre'] ?? '', style: TxText.h2),
                      const SizedBox(height: 6),
                      Text(data['descripcion'] ?? '',
                        style: const TextStyle(color: Tx.grey)),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: yaReservado
                            ? Container(
                                height: 46,
                                decoration: BoxDecoration(
                                  color: Tx.success.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Tx.success.withOpacity(0.3))),
                                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Icon(Icons.check_circle_rounded, color: Tx.success, size: 16),
                                  SizedBox(width: 8),
                                  Text('Reservado', style: TextStyle(
                                    color: Tx.success, fontWeight: FontWeight.w700)),
                                ]))
                            : ElevatedButton.icon(
                                onPressed: () {
                                  FirebaseFirestore.instance
                                      .collection('lanzamientos').doc(docs[i].id)
                                      .update({'reservas': FieldValue.arrayUnion([uid])});
                                  TxSnack.show(context, '¡Reserva confirmada!', type: 'success');
                                },
                                icon: const Icon(Icons.bookmark_add_rounded, size: 16),
                                label: const Text('RESERVAR AHORA'))),
                    ])),
                ]));
            });
        }));
  }
}

// ═══════════════════════════════════════════════════════════════
// WIDGETS COMPARTIDOS
// ═══════════════════════════════════════════════════════════════

class TxInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  const TxInput({
    super.key, required this.controller, required this.label,
    required this.icon, this.obscure = false, this.suffix,
    this.keyboardType, this.validator,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller, obscureText: obscure,
      keyboardType: keyboardType, validator: validator,
      style: const TextStyle(fontSize: 14, color: Tx.dark),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Tx.navy, size: 20),
        suffixIcon: suffix)));
}

class TxLoader extends StatelessWidget {
  const TxLoader({super.key});
  @override
  Widget build(BuildContext context) => const Center(
    child: SizedBox(
      width: 30, height: 30,
      child: CircularProgressIndicator(
        color: Tx.navy, strokeWidth: 2.5, strokeCap: StrokeCap.round)));
}

class TxSnack {
  static void show(BuildContext ctx, String msg, {String type = 'info'}) {
    final color = type == 'success' ? Tx.success
        : type == 'error'   ? Tx.danger
        : type == 'warning' ? Tx.warning
        : Tx.navy;
    final icon = type == 'success' ? Icons.check_circle_rounded
        : type == 'error'   ? Icons.error_rounded
        : type == 'warning' ? Icons.warning_rounded
        : Icons.info_rounded;
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(icon, color: Tx.white, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(msg, style: const TextStyle(color: Tx.white, fontSize: 13))),
      ]),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(10),
      duration: const Duration(seconds: 3)));
  }
}

class _ErrorBanner extends StatelessWidget {
  final String msg;
  const _ErrorBanner(this.msg);
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Tx.danger.withOpacity(0.06),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Tx.danger.withOpacity(0.2))),
    child: Row(children: [
      const Icon(Icons.error_outline_rounded, color: Tx.danger, size: 16),
      const SizedBox(width: 8),
      Expanded(child: Text(msg, style: const TextStyle(color: Tx.danger, fontSize: 12))),
    ]));
}

class _DividerOr extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Row(children: [
    Expanded(child: Divider()),
    Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Text('o', style: TextStyle(color: Tx.grey, fontSize: 12))),
    Expanded(child: Divider()),
  ]);
}

class _GoogleBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _GoogleBtn({required this.onTap});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity, height: 48,
    child: OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Tx.greyLight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      onPressed: onTap,
      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.g_mobiledata_rounded, size: 22, color: Tx.navy),
        SizedBox(width: 8),
        Text('Continuar con Google',
          style: TextStyle(color: Tx.navy, fontWeight: FontWeight.w600)),
      ])));
}

class _RolCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _RolCard({required this.icon, required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: selected ? Tx.navy : Tx.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: selected ? Tx.gold : Tx.greyLight, width: 1.5)),
      child: Column(children: [
        Icon(icon, color: selected ? Tx.gold : Tx.grey, size: 26),
        const SizedBox(height: 6),
        Text(label, textAlign: TextAlign.center, style: TextStyle(
          color: selected ? Tx.white : Tx.grey,
          fontWeight: FontWeight.w700, fontSize: 11)),
      ])));
}

class _PromoSlide extends StatelessWidget {
  final String titulo, sub, tag;
  final Color color1, color2, accent;
  final IconData icon;
  final bool active;
  const _PromoSlide({
    required this.titulo, required this.sub, required this.tag,
    required this.color1, required this.color2, required this.accent,
    required this.icon, required this.active,
  });
  @override
  Widget build(BuildContext context) => AnimatedScale(
    scale: active ? 1.0 : 0.93,
    duration: const Duration(milliseconds: 300),
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color1, color2]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
          color: color1.withOpacity(0.5), blurRadius: 16, offset: const Offset(0, 6))]),
      child: Stack(children: [
        Positioned(right: -20, bottom: -30,
          child: Container(
            width: 130, height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle, color: accent.withOpacity(0.12)))),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(20)),
                  child: Text(tag, style: TextStyle(
                    color: color1, fontWeight: FontWeight.w800, fontSize: 10))),
                const SizedBox(height: 10),
                Text(titulo, style: const TextStyle(
                  color: Tx.white, fontSize: 19, fontWeight: FontWeight.w900, height: 1.2)),
                const SizedBox(height: 6),
                Text(sub, style: TextStyle(color: Tx.white.withOpacity(0.65), fontSize: 11)),
              ])),
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withOpacity(0.15),
                border: Border.all(color: accent.withOpacity(0.4), width: 1.5)),
              child: Icon(icon, color: accent, size: 28)),
          ])),
      ])));
}

class _FilterBarDelegate extends SliverPersistentHeaderDelegate {
  final List<String> filtros;
  final String selected;
  final void Function(String) onSelect;
  const _FilterBarDelegate({required this.filtros, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext ctx, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Tx.cream, height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: filtros.length,
        itemBuilder: (_, i) {
          final f = filtros[i];
          final sel = f == selected;
          return GestureDetector(
            onTap: () => onSelect(f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: sel ? Tx.navy : Tx.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: sel ? Tx.gold : Tx.greyLight, width: 1.5)),
              child: Text(f.toUpperCase(), style: TextStyle(
                color: sel ? Tx.gold : Tx.grey,
                fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8))));
        }));
  }

  @override double get maxExtent => 52;
  @override double get minExtent => 52;
  @override bool shouldRebuild(_FilterBarDelegate o) =>
      o.selected != selected || o.filtros != filtros;
}

class _ProductCard extends StatelessWidget {
  final ProductoModel producto;
  final VoidCallback onTap;
  const _ProductCard({required this.producto, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final p = producto;
    final isLow = p.stock < 8;
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Stack(fit: StackFit.expand, children: [
            p.imagenes.isNotEmpty
                ? Image.network(p.imagenes[0], fit: BoxFit.cover,
                    loadingBuilder: (_, child, prog) =>
                        prog == null ? child : const _ImgSkeleton(),
                    errorBuilder: (_, __, ___) => const _NoImgPlaceholder())
                : const _NoImgPlaceholder(),
            Positioned.fill(child: Container(decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0x28000000)])))),
            if (p.badge.isNotEmpty)
              Positioned(top: 8, left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: Tx.gradNavy, borderRadius: BorderRadius.circular(20)),
                  child: Text(p.badge, style: const TextStyle(
                    color: Tx.gold, fontSize: 8, fontWeight: FontWeight.w800)))),
            Positioned(top: 8, right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                decoration: BoxDecoration(
                  color: (isLow ? Tx.warning : Tx.success).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8)),
                child: Text('${p.stock}', style: const TextStyle(
                  color: Tx.white, fontSize: 9, fontWeight: FontWeight.w700)))),
          ])),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.nombre, style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 12, color: Tx.navy),
                maxLines: 1, overflow: TextOverflow.ellipsis),
              if (p.descripcion.isNotEmpty)
                Text(p.descripcion, style: const TextStyle(color: Tx.grey, fontSize: 10),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 7),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('\$${p.precio.toStringAsFixed(0)}', style: const TextStyle(
                  color: Tx.navy, fontWeight: FontWeight.w800, fontSize: 14)),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    gradient: Tx.gradNavy,
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: const Icon(Icons.add_rounded, color: Tx.gold, size: 15)),
              ]),
            ])),
        ])));
  }
}

class _CartItemCard extends StatefulWidget {
  final CartItem item;
  final int index;
  final void Function(int) onUpdate;
  const _CartItemCard({required this.item, required this.index, required this.onUpdate});
  @override
  State<_CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<_CartItemCard> {
  late int _qty;
  @override
  void initState() { super.initState(); _qty = widget.item.cantidad; }
  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Tx.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
      child: Row(children: [
        Container(
          width: 52, height: 60,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Tx.cream),
          clipBehavior: Clip.antiAlias,
          child: item.producto.imagenes.isNotEmpty
              ? Image.network(item.producto.imagenes[0], fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const _NoImgPlaceholder())
              : const _NoImgPlaceholder()),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.producto.nombre, style: const TextStyle(
            fontWeight: FontWeight.w700, color: Tx.navy, fontSize: 13)),
          const SizedBox(height: 3),
          Row(children: [
            _TagBadge(label: 'T.${item.talla}', color: Tx.navy),
            if (item.color.isNotEmpty) ...[
              const SizedBox(width: 4),
              _TagBadge(label: item.color, color: Tx.grey),
            ],
          ]),
          const SizedBox(height: 6),
          Row(children: [
            _QtyBtn(
              icon: Icons.remove,
              onTap: () {
                setState(() { if (_qty > 1) _qty--; });
                widget.onUpdate(_qty);
              }),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('$_qty', style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w800, color: Tx.navy))),
            _QtyBtn(
              icon: Icons.add,
              onTap: () { setState(() => _qty++); widget.onUpdate(_qty); }),
          ]),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('\$${item.subtotal.toStringAsFixed(0)}', style: const TextStyle(
            fontWeight: FontWeight.w800, color: Tx.navy, fontSize: 14)),
          const SizedBox(height: 4),
          Text('\$${item.producto.precio.toStringAsFixed(0)}/u',
            style: const TextStyle(color: Tx.grey, fontSize: 10)),
        ]),
      ]));
  }
}

class _PedidoCard extends StatelessWidget {
  final PedidoModel pedido;
  const _PedidoCard({required this.pedido});
  Color _estadoColor(String e) {
    switch (e) {
      case 'entregado': return Tx.success;
      case 'enviado':   return Tx.info;
      case 'cancelado': return Tx.danger;
      case 'confirmado': return Tx.gold;
      default:          return Tx.grey;
    }
  }
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(color: Tx.white, borderRadius: BorderRadius.circular(16)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        height: 4,
        decoration: BoxDecoration(
          color: _estadoColor(pedido.estado),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)))),
      Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Pedido #${pedido.id.substring(0, 6).toUpperCase()}',
              style: const TextStyle(fontWeight: FontWeight.w800, color: Tx.navy)),
            _EstadoBadge(estado: pedido.estado),
          ]),
          const SizedBox(height: 4),
          if (pedido.creadoEn != null)
            Text('${pedido.creadoEn!.day}/${pedido.creadoEn!.month}/${pedido.creadoEn!.year}',
              style: const TextStyle(color: Tx.grey, fontSize: 11)),
          const SizedBox(height: 6),
          Text('\$${pedido.total.toStringAsFixed(0)}', style: const TextStyle(
            color: Tx.gold, fontWeight: FontWeight.w900, fontSize: 18)),
          if (pedido.items.isNotEmpty) ...[
            const SizedBox(height: 6),
            ...pedido.items.take(2).map((item) => Text(
              '${item['nombre']} × ${item['cantidad']} (T.${item['talla']})',
              style: const TextStyle(color: Tx.grey, fontSize: 11))),
            if (pedido.items.length > 2)
              Text('+${pedido.items.length - 2} más',
                style: const TextStyle(color: Tx.grey, fontSize: 11)),
          ],
        ])),
    ]));
}

class _EstadoBadge extends StatelessWidget {
  final String estado;
  const _EstadoBadge({required this.estado});
  Color get _color {
    switch (estado) {
      case 'entregado': return Tx.success;
      case 'enviado':   return Tx.info;
      case 'cancelado': return Tx.danger;
      case 'confirmado': return Tx.gold;
      default:          return Tx.grey;
    }
  }
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: _color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
    child: Text(estado.toUpperCase(), style: TextStyle(
      color: _color, fontSize: 9, fontWeight: FontWeight.w800)));
}

class _TagBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _TagBadge({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
    child: Text(label, style: TextStyle(
      color: color, fontSize: 10, fontWeight: FontWeight.w700)));
}

class _KpiTile extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color accent;
  const _KpiTile({required this.label, required this.value, required this.icon, required this.accent});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      gradient: Tx.gradNavy, borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(
        color: Tx.navy.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: accent, size: 20),
      const SizedBox(height: 10),
      Text(value, style: TextStyle(color: accent, fontSize: 20, fontWeight: FontWeight.w900)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(
        color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w500)),
    ]));
}

class _WalletChip extends StatelessWidget {
  final String label;
  final double value;
  const _WalletChip({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Tx.white.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
      Text('\$${value.toStringAsFixed(0)}', style: const TextStyle(
        color: Tx.gold, fontWeight: FontWeight.w800, fontSize: 16)),
    ]));
}

class _ProfileSection extends StatelessWidget {
  final List<_ProfileItem> items;
  const _ProfileSection({required this.items});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: Tx.white, borderRadius: BorderRadius.circular(14)),
    child: Column(children: items.asMap().entries.map((e) {
      final item = e.value;
      final isLast = e.key == items.length - 1;
      return Column(children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: Tx.cream, borderRadius: BorderRadius.circular(8)),
            child: Icon(item.icon, color: Tx.navy, size: 18)),
          title: Text(item.label, style: const TextStyle(
            fontWeight: FontWeight.w600, color: Tx.navy, fontSize: 13)),
          trailing: const Icon(Icons.chevron_right_rounded, color: Tx.greyMid),
          onTap: item.onTap),
        if (!isLast) const Divider(height: 0, indent: 54),
      ]);
    }).toList()));
}

class _ProfileItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ProfileItem({required this.icon, required this.label, required this.onTap});
}

class _NotifBadge extends StatelessWidget {
  final VoidCallback onTap;
  const _NotifBadge({required this.onTap});
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('usuarios').doc(uid)
          .collection('notificaciones').where('leida', isEqualTo: false).snapshots(),
      builder: (_, snap) {
        final count = snap.data?.docs.length ?? 0;
        return IconButton(
          onPressed: onTap,
          icon: Badge(
            isLabelVisible: count > 0,
            label: Text('$count', style: const TextStyle(fontSize: 9)),
            child: const Icon(Icons.notifications_outlined)));
      });
  }
}

class _FieldSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _FieldSection({required this.title, required this.children});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(
      fontWeight: FontWeight.w700, color: Tx.navy, fontSize: 13)),
    const SizedBox(height: 10),
    Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 2),
      decoration: BoxDecoration(color: Tx.white, borderRadius: BorderRadius.circular(14)),
      child: Column(children: children)),
  ]);
}

class _AdminProductTile extends StatelessWidget {
  final ProductoModel producto;
  final VoidCallback onEdit, onDelete;
  const _AdminProductTile({required this.producto, required this.onEdit, required this.onDelete});
  @override
  Widget build(BuildContext context) {
    final p = producto;
    final isLow = p.stock < 8;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p.activo ? Tx.white : Tx.greyLight,
        borderRadius: BorderRadius.circular(14),
        border: isLow ? Border.all(color: Tx.danger.withOpacity(0.3)) : null),
      child: Row(children: [
        Container(
          width: 50, height: 58,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Tx.cream),
          clipBehavior: Clip.antiAlias,
          child: p.imagenes.isNotEmpty
              ? Image.network(p.imagenes[0], fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const _NoImgPlaceholder())
              : const _NoImgPlaceholder()),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(p.nombre, style: const TextStyle(
            fontWeight: FontWeight.w700, color: Tx.navy, fontSize: 13)),
          Text('\$${p.precio.toStringAsFixed(0)}',
            style: const TextStyle(color: Tx.grey, fontSize: 12)),
          Text('Stock: ${p.stock}', style: TextStyle(
            color: isLow ? Tx.danger : Tx.success,
            fontSize: 11, fontWeight: FontWeight.w600)),
        ])),
        Column(children: [
          Switch(
            value: p.activo, activeColor: Tx.gold,
            onChanged: (v) => FirebaseFirestore.instance
                .collection('productos').doc(p.id).update({'activo': v})),
          Row(children: [
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: Tx.navy, size: 18),
              onPressed: onEdit),
            IconButton(
              icon: const Icon(Icons.delete_rounded, color: Tx.danger, size: 18),
              onPressed: onDelete),
          ]),
        ]),
      ]));
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
        color: Tx.cream, borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Tx.greyLight)),
      child: Icon(icon, color: Tx.navy, size: 15)));
}

class _ImgSkeleton extends StatelessWidget {
  const _ImgSkeleton();
  @override
  Widget build(BuildContext context) => Container(
    color: Tx.greyLight,
    child: const Center(child: CircularProgressIndicator(
      color: Tx.greyMid, strokeWidth: 1.5)));
}

class _NoImgPlaceholder extends StatelessWidget {
  const _NoImgPlaceholder();
  @override
  Widget build(BuildContext context) => Container(
    color: Tx.cream,
    child: const Center(child: Icon(Icons.checkroom_rounded, size: 36, color: Tx.greyMid)));
}

class _ConfirmDialog extends StatelessWidget {
  final double total;
  final int count;
  final String direccion;
  const _ConfirmDialog({required this.total, required this.count, required this.direccion});
  @override
  Widget build(BuildContext context) => AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    title: const Row(children: [
      Icon(Icons.shopping_bag_rounded, color: Tx.gold),
      SizedBox(width: 8),
      Text('Confirmar pedido'),
    ]),
    content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('$count productos', style: const TextStyle(color: Tx.grey)),
      const SizedBox(height: 4),
      Text('Total: \$${total.toStringAsFixed(0)}', style: const TextStyle(
        fontWeight: FontWeight.w800, color: Tx.navy, fontSize: 17)),
      const SizedBox(height: 10),
      const Text('Dirección:', style: TextStyle(color: Tx.grey, fontSize: 12)),
      Text(direccion, style: const TextStyle(color: Tx.navy, fontSize: 12)),
    ]),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text('Cancelar')),
      ElevatedButton(
        onPressed: () => Navigator.pop(context, true),
        child: const Text('CONFIRMAR')),
    ]);
}

class _OpcionImagenTile extends StatelessWidget {
  final IconData icon;
  final String titulo, subtitulo;
  final Color color;
  final VoidCallback onTap;
  const _OpcionImagenTile({
    required this.icon, required this.titulo, required this.subtitulo,
    required this.color, required this.onTap,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2))),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 22)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(titulo, style: TextStyle(
            fontWeight: FontWeight.w700, color: color, fontSize: 13)),
          Text(subtitulo, style: const TextStyle(color: Tx.grey, fontSize: 11)),
        ])),
        Icon(Icons.chevron_right_rounded, color: color.withOpacity(0.5)),
      ])));
}

// ─────────────────────────────────────────────────────────────────
// ROUTE HELPER
// ─────────────────────────────────────────────────────────────────
Route<T> _txSlide<T>(Widget page) => PageRouteBuilder<T>(
  pageBuilder: (_, __, ___) => page,
  transitionsBuilder: (_, anim, __, child) => SlideTransition(
    position: Tween(begin: const Offset(1, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
    child: child));