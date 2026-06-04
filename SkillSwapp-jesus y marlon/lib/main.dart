import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'login.dart';
import 'Interfaz_IA.dart';
import 'ventana_perfil.dart';
import 'bienvenida_perfil.dart';
import 'mis_archivos.dart';
import 'chat_screen.dart';
import 'terminos_condiciones.dart';
import 'calificaciones.dart';
import 'tutores_favoritos.dart';
import 'interfaz_match.dart';
import 'widgets/calendario_view.dart';
import 'calendario_screen.dart';

enum SearchFilterMode {
  people,
  offeredSkills,
  learningSkills,
  recommendations,
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyDh4LU3VSh02Hfk7xUR6fDl6F7SWIRrKpk",
          authDomain: "skillswapp-b7fc0.firebaseapp.com",
          projectId: "skillswapp-b7fc0",
          storageBucket: "skillswapp-b7fc0.firebasestorage.app",
          messagingSenderId: "141826962219",
          appId: "1:141826962219:web:a9e4fb7613e727e7344b6e",
          databaseURL: "https://skillswapp-b7fc0-default-rtdb.firebaseio.com/",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }
  runApp(const SkillSwapApp());
}

class SkillSwapApp extends StatelessWidget {
  const SkillSwapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkillSwap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6BCE7A),
          primary: const Color(0xFF6BCE7A),
          secondary: const Color(0xFF00A99D),
        ),
        primaryColor: const Color(0xFF6BCE7A),
        scaffoldBackgroundColor: Colors.transparent,
        fontFamily: 'Arial',
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/ai': (context) => const InterfazIA(),
        '/perfil': (context) => const ventana_perfil(),
        '/calificaciones': (context) => const CalificacionesScreen(),
        '/favoritos': (context) => const TutoresFavoritosScreen(),
        '/archivos': (context) => const MisArchivosScreen(),
        '/bienvenida': (context) => const BienvenidaPerfil(),
        '/terminos': (context) => const TermsAndConditionsScreen(),
        '/calendario': (context) => const CalendarioScreen(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Controlador de búsqueda
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  SearchFilterMode _filterMode = SearchFilterMode.recommendations;
  final bool _showCalendar = false; // Nueva variable para mostrar/ocultar calendario
  String _currentSort = "Conexión"; // Opción seleccionada por defecto
  final Set<String> _favoriteIds = {};
  bool _favoritesLoaded = false;

  // Controladores para las animaciones del bot
  late AnimationController _botAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  // Controladores para la animación del globo de texto
  late AnimationController _bubbleAnimationController;
  late Animation<double> _bubbleOpacityAnimation;
  late Animation<double> _bubbleScaleAnimation;
  bool _showGreeting = false;
 
  // Animación de la mano
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  // Variables para el Calendario
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _calendarFocusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<dynamic>> _events = {};

  @override
  void initState() {
    super.initState();
    _updatePresence();
    _cargarFavoritos();
    _escucharReuniones();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _waveAnimation = Tween<double>(begin: -0.2, end: 0.2).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );

    // -- Campo de Configuración de la animación del Bot
    _botAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true); // Repetir infinitamente

    // Animación de escala (pulso)
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _botAnimationController, curve: Curves.easeInOut),
    );

    // Animación de opacidad del brillo
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _botAnimationController, curve: Curves.easeInOut),
    );

    // --- Configuración animación del Globo de Saludo ---
    _bubbleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _bubbleOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bubbleAnimationController, curve: Curves.easeIn),
    );

    _bubbleScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _bubbleAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Mostrar el saludo después de un pequeño retraso y ocultarlo después
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showGreeting = true;
        });
        _bubbleAnimationController.forward();
      }
    });

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _showGreeting) {
        _bubbleAnimationController.reverse().then((value) {
          if (mounted) {
            setState(() {
              _showGreeting = false;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _botAnimationController.dispose();
    _bubbleAnimationController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _cargarFavoritos() async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) {
      if (mounted) {
        setState(() {
          _favoritesLoaded = true;
        });
      }
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(currentUid)
          .get();
      final data = doc.data();
      final favoritos = List<String>.from(data?['favoritos'] ?? const []);
      if (mounted) {
        setState(() {
          _favoriteIds
            ..clear()
            ..addAll(favoritos);
          _favoritesLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('Error cargando favoritos: $e');
      if (mounted) {
        setState(() {
          _favoritesLoaded = true;
        });
      }
    }
  }

  void _escucharReuniones() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Escuchar la colección global 'reuniones' para el usuario actual
    FirebaseFirestore.instance
        .collection('reuniones')
        .snapshots()
        .listen((snapshot) {
      Map<DateTime, List<dynamic>> newEvents = {};
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          if (data['meetingDate'] == null) continue;

          // Solo mostrar si el usuario actual es emisor o receptor
          if (data['senderId'] == user.uid || data['receiverId'] == user.uid) {
            final DateTime date = DateTime.parse(data['meetingDate']);
            final DateTime dayOnly = DateTime(date.year, date.month, date.day);
            
            final eventData = Map<String, dynamic>.from(data);
            eventData['id'] = doc.id;
            
            if (eventData['senderName'] == null) {
              eventData['senderName'] = "Usuario";
            }
            
            if (newEvents[dayOnly] == null) newEvents[dayOnly] = [];
            newEvents[dayOnly]!.add(eventData);
          }
        } catch (e) {
          debugPrint("Error al procesar evento de calendario en main: $e");
        }
      }
      if (mounted) {
        setState(() {
          _events = newEvents;
        });
      }
    });
  }

  Future<void> _toggleFavorito(String uid) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return;

    setState(() {
      if (_favoriteIds.contains(uid)) {
        _favoriteIds.remove(uid);
      } else {
        _favoriteIds.add(uid);
      }
    });

    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(currentUid)
          .set({'favoritos': _favoriteIds.toList()}, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error guardando favoritos: $e');
    }
  }

  String _fallbackAvatarUrl(String name) {
    final encodedName = Uri.encodeComponent(name);
    return 'https://ui-avatars.com/api/?name=$encodedName&background=6BCE7A&color=fff';
  }

  Widget _buildUserAvatar(String photo, String name, {double radius = 15}) {
    final fallbackUrl = _fallbackAvatarUrl(name);
    final photoTrimmed = photo.trim();

    if (photoTrimmed.startsWith('http')) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey.shade200,
        backgroundImage: NetworkImage(photoTrimmed),
      );
    }

    if (photoTrimmed.isNotEmpty) {
      // Intentar decodificar como Base64 primero si es una cadena larga
      if (photoTrimmed.length > 100 || (!photoTrimmed.contains('/') && !photoTrimmed.contains('\\'))) {
        try {
          String base64Data = photoTrimmed;
          if (base64Data.contains(',')) {
            base64Data = base64Data.split(',').last;
          }
          final bytes = base64Decode(base64Data);
          return CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey.shade200,
            child: ClipOval(
              child: Image.memory(
                bytes,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.person, size: radius * 1.2, color: Colors.grey),
              ),
            ),
          );
        } catch (e) {
          debugPrint("Error decodificando avatar Base64: $e");
        }
      }

      // Si parece una ruta de archivo local y no estamos en web
      if (!kIsWeb && (photoTrimmed.startsWith('/') || photoTrimmed.contains(':/') || photoTrimmed.contains(':\\'))) {
        return CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey.shade200,
          child: ClipOval(
            child: Image.file(
              File(photoTrimmed),
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.person, size: radius * 1.2, color: Colors.grey),
            ),
          ),
        );
      }
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: NetworkImage(fallbackUrl),
    );
  }

  String _normalizeText(String value) {
    return value
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n');
  }

  String _skillSearchText(Map<String, dynamic> userData) {
    final parts = <String>[];

    void addValue(dynamic value) {
      if (value == null) return;
      if (value is Iterable) {
        for (final item in value) {
          addValue(item);
        }
        return;
      }
      final text = value.toString().trim();
      if (text.isNotEmpty) {
        parts.add(text);
      }
    }

    addValue(userData['especialidad']);
    addValue(userData['ofrece']);
    addValue(userData['necesita']);
    addValue(userData['habilidades']);
    addValue(userData['areaAprendizaje']);
    addValue(userData['idiomaPreferido']);

    final areas = userData['areasAprendizaje'];
    if (areas is List) {
      for (final area in areas) {
        addValue(area);
      }
    }

    final subareasPorArea = userData['subareasPorArea'];
    if (subareasPorArea is Map) {
      for (final value in subareasPorArea.values) {
        addValue(value);
      }
    }

    final subareasSeleccionadas = userData['subareasSeleccionadas'];
    if (subareasSeleccionadas is List) {
      for (final value in subareasSeleccionadas) {
        addValue(value);
      }
    }

    return _normalizeText(parts.join(' '));
  }

  String _displaySkillText(Map<String, dynamic> userData) {
    final labels = <String>[];

    void addValue(dynamic value) {
      if (value == null) return;
      if (value is Iterable) {
        for (final item in value) {
          addValue(item);
        }
        return;
      }
      final text = value.toString().trim();
      if (text.isNotEmpty && !labels.contains(text)) {
        labels.add(text);
      }
    }

    addValue(userData['especialidad']);
    addValue(userData['habilidades']);
    addValue(userData['ofrece']);

    final areas = userData['areasAprendizaje'];
    if (areas is List) {
      for (final area in areas) {
        addValue(area);
      }
    }

    final subareasPorArea = userData['subareasPorArea'];
    if (subareasPorArea is Map) {
      for (final value in subareasPorArea.values) {
        addValue(value);
      }
    }

    if (labels.isEmpty) {
      addValue(userData['necesita']);
    }

    return labels.join(', ');
  }

  List<String> _stringListFromDynamic(dynamic value) {
    final items = <String>[];

    void addItem(dynamic item) {
      if (item == null) return;
      if (item is Iterable) {
        for (final nested in item) {
          addItem(nested);
        }
        return;
      }
      final text = item.toString().trim();
      if (text.isNotEmpty) {
        items.add(text);
      }
    }

    addItem(value);
    return items;
  }

  String _previewText(List<String> values, {int limit = 3}) {
    if (values.isEmpty) {
      return '';
    }
    if (values.length <= limit) {
      return values.join(', ');
    }
    return '${values.take(limit).join(', ')}...';
  }

  String _filterModeLabel() {
    switch (_filterMode) {
      case SearchFilterMode.people:
        return 'Personas';
      case SearchFilterMode.offeredSkills:
        return 'Habilidades que ofrece';
      case SearchFilterMode.learningSkills:
        return 'Habilidades que quieres aprender';
      case SearchFilterMode.recommendations:
        return 'Recomendaciones';
    }
  }

  Future<void> _openFilterSheet() async {
    final selected = await showModalBottomSheet<SearchFilterMode>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Filtros',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Elige cómo quieres buscar o recibir recomendaciones.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                ...SearchFilterMode.values.map((mode) {
                  final isSelected = mode == _filterMode;
                  final label = switch (mode) {
                    SearchFilterMode.people => 'Personas',
                    SearchFilterMode.offeredSkills => 'Habilidades que ofrece',
                    SearchFilterMode.learningSkills => 'Habilidades que quiere aprender',
                    SearchFilterMode.recommendations => 'Recomendar por habilidades a aprender',
                  };
                  final description = switch (mode) {
                    SearchFilterMode.people => 'Busca por nombre o correo.',
                    SearchFilterMode.offeredSkills => 'Busca por lo que la persona enseña o comparte.',
                    SearchFilterMode.learningSkills => 'Busca por lo que la persona quiere aprender.',
                    SearchFilterMode.recommendations => 'Prioriza personas que ofrecen lo que necesitas aprender.',
                  };

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () => Navigator.pop(context, mode),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF6BCE7A).withOpacity(0.12) : const Color(0xFFF7F8FA),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF6BCE7A) : Colors.grey.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.check_circle : Icons.filter_alt_outlined,
                              color: isSelected ? const Color(0xFF6BCE7A) : Colors.grey.shade600,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    label,
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    description,
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null && mounted) {
      setState(() => _filterMode = selected);
    }
  }

  void _showProfileMenu(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Stack(
          children: [
            Positioned(
              top: 80,
              right: 24,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 220,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (currentUser != null)
                          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                            stream: FirebaseFirestore.instance
                                .collection('usuarios')
                                .doc(currentUser.uid)
                                .snapshots(),
                            builder: (context, snapshot) {
                              final data = snapshot.data?.data();
                              final name =
                                  (data?['nombre'] ??
                                          currentUser.email?.split('@').first ??
                                          'Usuario')
                                      .toString();
                              final photo =
                                  (data?['photoUrl'] ??
                                          data?['fotoUrl'] ??
                                          currentUser.photoURL ??
                                          '')
                                      .toString();

                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  18,
                                  16,
                                  14,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF6FBF7),
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    _buildUserAvatar(photo, name, radius: 22),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF334A5F),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            currentUser.email ?? '',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        _buildMenuItem(
                          Icons.accessibility,
                          "Accesibilidad",
                          () {},
                        ),
                        _buildMenuItem(Icons.person_outline, "Perfil", () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/perfil');
                        }),
                        _buildMenuItem(
                          Icons.check_box_outlined,
                          "Calificaciones",
                          () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/calificaciones');
                          },
                        ),
                        _buildMenuItem(
                          Icons.star_outline,
                          "Tutores favoritos",
                          () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/favoritos');
                          },
                        ),
                        _buildMenuItem(
                          Icons.people_outline_rounded,
                          "Solicitudes de amistad",
                          () {
                            Navigator.pop(context);
                            _mostrarListaSolicitudes(context);
                          },
                        ),
                        _buildMenuItem(
                          Icons.calendar_today_outlined,
                          "Calendario",
                          () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/calendario');
                          },
                        ),
                        _buildMenuItem(
                          Icons.folder_open_outlined,
                          "Archivos personales",
                          () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/archivos');
                          },
                        ),
                        _buildMenuItem(Icons.logout, "Cerrar sesión", () {
                          Navigator.pop(context);
                          Navigator.pushReplacementNamed(context, '/login');
                        }, isExit: true),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _mostrarListaSolicitudes(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.68,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Solicitudes recibidas',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2A3D50),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('solicitudes')
                    .where('users', arrayContains: user.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No tienes solicitudes o amigos aún'),
                    );
                  }

                  final docs = snapshot.data!.docs.toList();
                  docs.sort((a, b) {
                    final ad = a.data() as Map<String, dynamic>;
                    final bd = b.data() as Map<String, dynamic>;
                    final at = (ad['timestamp'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
                    final bt = (bd['timestamp'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
                    return bt.compareTo(at);
                  });

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final fromUid = data['from'] as String? ?? '';
                      final toUid = data['to'] as String? ?? '';
                      final status = (data['status'] ?? 'pending').toString();
                      final isIncoming = toUid == user.uid;
                      final otherUid = fromUid == user.uid ? toUid : fromUid;

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('usuarios').doc(otherUid).get(),
                        builder: (context, userSnap) {
                          if (!userSnap.hasData) return const SizedBox.shrink();
                          final userData = userSnap.data!.data() as Map<String, dynamic>?;
                          final name = (userData?['nombre'] ?? 'Usuario').toString();
                          final photo = (userData?['photoUrl'] ?? userData?['fotoUrl'] ?? '').toString();

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: status == 'accepted'
                                    ? const Color(0xFF6BCE7A).withOpacity(0.25)
                                    : Colors.grey.shade100,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                _buildUserAvatar(photo, name, radius: 28),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFF2A3D50),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        status == 'accepted'
                                            ? 'Ya son amigos'
                                            : (isIncoming
                                                ? 'Te envió una solicitud'
                                                : 'Solicitud enviada'),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: status == 'accepted'
                                              ? const Color(0xFF6BCE7A)
                                              : Colors.grey,
                                          fontWeight: status == 'accepted'
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (status == 'pending' && isIncoming) ...[
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                      InterfazMatch.aceptarSolicitud(context, doc.id, data);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF6BCE7A),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.check, color: Colors.white, size: 18),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () => doc.reference.delete(),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: Colors.redAccent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close, color: Colors.white, size: 18),
                                    ),
                                  ),
                                ] else if (status == 'accepted') ...[
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChatScreen(
                                            receiverId: otherUid,
                                            receiverName: name,
                                            receiverPhoto: photo,
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6BCE7A),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Chatear',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDetallesUsuario(
    BuildContext context,
    Map<String, dynamic> data,
    String uid,
  ) {
    const Color primaryGreen = Color(0xFF6BCE7A);
    final String name =
        data['nombre'] ?? data['email']?.split('@')[0] ?? "Usuario";
    final String photo = data['photoUrl'] ?? data['fotoUrl'] ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height:
            MediaQuery.of(context).size.height *
            0.85, // Un poco más alto para ver más datos
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        _buildUserAvatar(photo, name, radius: 65),
                        StreamBuilder(
                          stream: FirebaseDatabase.instance
                              .ref("status/$uid")
                              .onValue,
                          builder: (context, snapshot) {
                            bool isOnline = false;
                            String statusText = "Desconectado";
                            if (snapshot.hasData &&
                                snapshot.data!.snapshot.value != null) {
                              final dynamic value =
                                  snapshot.data!.snapshot.value;
                              if (value is Map) {
                                isOnline = value["presence"] == "online";
                                statusText = isOnline
                                    ? "En línea"
                                    : "Desconectado";
                              }
                            }
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isOnline
                                    ? const Color(0xFF4CAF50)
                                    : Colors.grey.shade500,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: isOnline
                                          ? Colors.white
                                          : Colors.white70,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    statusText.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF334A5F),
                      ),
                    ),
                    Text(
                      data['email'] ?? "",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    // Mostrar la calificación que el usuario actual dio a este perfil (si existe)
                    Builder(
                      builder: (context) {
                        final viewerUid =
                            FirebaseAuth.instance.currentUser?.uid;
                        if (viewerUid == null) return const SizedBox.shrink();

                        return StreamBuilder<
                          DocumentSnapshot<Map<String, dynamic>>
                        >(
                          stream: FirebaseFirestore.instance
                              .collection('usuarios')
                              .doc(uid)
                              .collection('calificaciones')
                              .doc(viewerUid)
                              .snapshots(),
                          builder: (context, snap) {
                            if (snap.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox.shrink();
                            }
                            if (!snap.hasData ||
                                !(snap.data?.exists ?? false)) {
                              return Row(
                                children: [
                                  const Text(
                                    'Sin calificación',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: () =>
                                        CalificacionesScreen.mostrarDialogoCalificar(
                                          context,
                                          uid,
                                          name,
                                        ),
                                    child: const Text('Calificar'),
                                  ),
                                ],
                              );
                            }

                            final dataCal = snap.data!.data()!;
                            final int exp =
                                (dataCal['ratingExplicacion'] ?? 0) as int;
                            final int hab =
                                (dataCal['ratingHabilidades'] ?? 0) as int;
                            final avg = ((exp + hab) / 2).round();

                            return Row(
                              children: [
                                Row(
                                  children: List.generate(5, (i) {
                                    return Icon(
                                      i < avg ? Icons.star : Icons.star_border,
                                      color: Colors.amber,
                                      size: 18,
                                    );
                                  }),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Exp: $exp • Hab: $hab',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: () =>
                                      CalificacionesScreen.mostrarDialogoCalificar(
                                        context,
                                        uid,
                                        name,
                                      ),
                                  child: const Text('Editar'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 30),

                    // Nueva sección de Datos Personales / Detalles
                    _buildFullDetailSection("Detalles del perfil", [
                      {
                        "icon": Icons.phone,
                        "label": "Teléfono",
                        "value": data['telefono'] ?? "No registrado",
                      },
                      {
                        "icon": Icons.location_on,
                        "label": "Ubicación",
                        "value": data['ubicacion'] ?? "No especificada",
                      },
                      {
                        "icon": Icons.work,
                        "label": "Especialidad",
                        "value":
                            data['especialidad'] ??
                            data['ofrece'] ??
                            "Habilidades varias",
                      },
                    ]),

                    const SizedBox(height: 20),
                    _buildInfoSection(
                      "Acerca de",
                      data['bio'] ??
                          "Soy un apasionado de SkillSwap buscando nuevas formas de aprender.",
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildBadgeSection(
                            "OFRECE",
                            data['ofrece'] ?? "Todo tipo de ayuda",
                            const Color(0xFF6BCE7A),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildBadgeSection(
                            "NECESITA",
                            data['necesita'] ?? "Nuevas experiencias",
                            const Color(0xFF00A99D),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('solicitudes')
                          .doc(
                            InterfazMatch.getMatchId(
                              FirebaseAuth.instance.currentUser?.uid ?? '',
                              uid,
                            ),
                          )
                          .snapshots(),
                      builder: (context, matchSnap) {
                        final matchData =
                            matchSnap.data?.data() as Map<String, dynamic>?;
                        final status = matchData?['status'];

                        if (status == 'accepted') {
                          return ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    receiverId: uid,
                                    receiverName: name,
                                    receiverPhoto: photo,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.chat_bubble),
                            label: const Text("IR AL CHAT"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 55),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          );
                        } else if (status == 'pending') {
                          final isFromMe =
                              matchData?['from'] ==
                              FirebaseAuth.instance.currentUser?.uid;
                          return ElevatedButton.icon(
                            onPressed: () {
                              if (isFromMe) {
                                InterfazMatch.mostrarEstadoSolicitud(
                                  context,
                                  uid,
                                  name,
                                  photo,
                                );
                              } else {
                                InterfazMatch.aceptarSolicitud(
                                  context,
                                  matchSnap.data!.id,
                                  matchData!,
                                );
                              }
                            },
                            icon: Icon(
                              isFromMe ? Icons.timer_outlined : Icons.check,
                            ),
                            label: Text(
                              isFromMe
                                  ? "SOLICITUD PENDIENTE"
                                  : "ACEPTAR SOLICITUD",
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isFromMe ? Colors.orange.shade300 : primaryGreen,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 55),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          );
                        } else {
                          return ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              InterfazMatch.enviarSolicitud(context, uid, name, photo);
                            },
                            icon: const Icon(Icons.flash_on),
                            label: const Text("CONTACTAR AHORA"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 55),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullDetailSection(
    String title,
    List<Map<String, dynamic>> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF334A5F),
          ),
        ),
        const SizedBox(height: 10),
        ...items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      size: 20,
                      color: const Color(0xFF00A99D),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['label'] as String,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['value'] as String,
                            style: const TextStyle(color: Colors.black87),
                            softWrap: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
            ,
      ],
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF334A5F),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(content, style: const TextStyle(color: Colors.blueGrey)),
        ),
      ],
    );
  }

  Widget _buildBadgeSection(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 140,
          width: double.infinity,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: SingleChildScrollView(
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper actualizado para un look más integrado
  Widget _buildMenuItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isExit = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ), // Más espacio interno
        child: Row(
          children: [
            Icon(
              icon,
              color: isExit ? Colors.redAccent : const Color(0xFF6BCE7A),
              size: 20, // Icono un poco más pequeño
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isExit ? Colors.redAccent : const Color(0xFF334A5F),
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderNotificationButton({
    required IconData icon,
    required int count,
    required VoidCallback onTap,
  }) {
    return IconButton(
      onPressed: onTap,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text(
          count.toString(),
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700),
        ),
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: const Color(0xFF6BCE7A),
            size: 18,
          ),
        ),
      ),
    );
  }

  int _getPendingRequestCount(String userId) {
    int count = 0;
    for (final eventList in _events.values) {
      for (final event in eventList) {
        try {
          final data = event as Map<String, dynamic>;
          final status = (data['status'] ?? 'pending').toString();
          final senderId = (data['senderId'] ?? '').toString();
          final receiverId = (data['receiverId'] ?? '').toString();

          if (status == 'pending' && (senderId == userId || receiverId == userId)) {
            count++;
          }
        } catch (_) {
          continue;
        }
      }
    }
    return count;
  }

  int _getPendingMeetingCount(String userId) {
    final now = DateTime.now();
    var count = 0;
    _events.forEach((day, events) {
      for (final event in events) {
        try {
          if (event['senderId'] == userId || event['receiverId'] == userId) {
            final meetingDate = DateTime.parse(event['meetingDate'].toString());
            final status = (event['status'] ?? 'pending').toString();
            if (meetingDate.isAfter(now) && status != 'declined') {
              count++;
            }
          }
        } catch (_) {
          continue;
        }
      }
    });
    return count;
  }

  void _updatePresence() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Referencias a Realtime Database (RTDB)
    DatabaseReference presenceRef = FirebaseDatabase.instance.ref(
      "status/${user.uid}",
    );

    FirebaseDatabase.instance.ref(".info/connected").onValue.listen((event) {
      if (event.snapshot.value == true) {
        // Cuándo el usuario se desconecta de RTDB
        presenceRef.onDisconnect().update({
          "presence": "offline",
          "last_seen": ServerValue.timestamp,
        });

        // Cuándo el usuario está conectado a RTDB (Asegurar timestamp numérico)
        presenceRef.update({
          "presence": "online",
          "last_seen": DateTime.now().millisecondsSinceEpoch,
        });

        // Actualizar Firestore también para la lista global
        FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .update({
              'estado': 'online',
              'ultimoIngreso': FieldValue.serverTimestamp(),
            })
            .catchError((e) => debugPrint("Error actualizando Firestore: $e"));
      }
    });

    // Escuchar cambios de desconexión también para Firestore si es posible
    presenceRef
        .onDisconnect()
        .set({"presence": "offline", "last_seen": ServerValue.timestamp})
        .then((_) {
          // Esto se ejecuta cuando el servidor de Firebase detecta la desconexión
        });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF6BCE7A);
    const Color darkText = Color(0xFF334A5F);

    // Obtener el usuario actual
    final user = FirebaseAuth.instance.currentUser;
    String userName = "Guest";
    if (user != null && user.email != null) {
      // Extrae la parte antes del @ del correo
      userName = user.email!.split('@')[0];
    }

    return Scaffold(
      body: Stack(
        children: [
          // 1. FONDO
          Positioned.fill(
            child: Image.asset('assets/Fondo_SkillSwap.png', fit: BoxFit.cover),
          ),

          // 2. CONTENIDO
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 20.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Header con Logo y Perfil clickable ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      'assets/imagen_skillwasp.jpeg',
                                      height: 24,
                                    ),
                                    const SizedBox(width: 4),
                                    RichText(
                                      overflow: TextOverflow.ellipsis,
                                      text: const TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "Skill",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w900,
                                              color: Color(0xFF6BCE7A),
                                            ),
                                          ),
                                          TextSpan(
                                            text: "Swap",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w900,
                                              color: Color(0xFF00A99D),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (user != null)
                                  _buildHeaderNotificationButton(
                                    icon: Icons.people_outline_rounded,
                                    count: _getPendingRequestCount(user.uid),
                                    onTap: () => _mostrarListaSolicitudes(context),
                                  ),
                                const SizedBox(width: 4),
                                if (user != null)
                                  _buildHeaderNotificationButton(
                                    icon: Icons.calendar_month_rounded,
                                    count: _getPendingMeetingCount(user.uid),
                                    onTap: () {
                                      Navigator.pushNamed(context, '/calendario');
                                    },
                                  ),
                                const SizedBox(width: 4),
                                // Avatar interactivo (Imagen 2)
                                GestureDetector(
                                  onTap: () {
                                    _showProfileMenu(context);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (user != null)
                                          StreamBuilder<
                                            DocumentSnapshot<Map<String, dynamic>>
                                          >(
                                            stream: FirebaseFirestore.instance
                                                .collection('usuarios')
                                                .doc(user.uid)
                                                .snapshots(),
                                            builder: (context, snapshot) {
                                              final data = snapshot.data?.data();
                                              final displayName =
                                                  (data?['nombre'] ?? userName)
                                                      .toString();
                                              final photo =
                                                  (data?['photoUrl'] ??
                                                          data?['fotoUrl'] ??
                                                          user.photoURL ??
                                                          '')
                                                      .toString();
                                              return _buildUserAvatar(
                                                photo,
                                                displayName,
                                                radius: 11,
                                              );
                                            },
                                          )
                                        else
                                          _buildUserAvatar(
                                            '',
                                            userName,
                                            radius: 11,
                                          ),
                                        const SizedBox(width: 4),
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 48),
                                          child: Text(
                                            userName,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Color(0xFF334A5F),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.keyboard_arrow_down,
                                          color: Colors.grey,
                                          size: 14,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),

                        // --- Saludo ---
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              "Bienvenido, $userName!",
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: darkText,
                              ),
                            ),
                            const SizedBox(width: 10),
                            AnimatedBuilder(
                              animation: _waveAnimation,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _waveAnimation.value,
                                  child: const Text(
                                    "👋",
                                    style: TextStyle(fontSize: 32),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const Text(
                          "What skills do you want to swap?",
                          style: TextStyle(fontSize: 16, color: darkText),
                        ),
                        const SizedBox(height: 20),

                        if (_showCalendar)
                          CalendarioView(
                            events: _events,
                            focusedDay: _calendarFocusedDay,
                            selectedDay: _selectedDay,
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                _selectedDay = selectedDay;
                                _calendarFocusedDay = focusedDay;
                              });
                            },
                          )
                        else ...[
                          _buildMeetingReminder(), // Recordatorio de próxima reunión
                          const SizedBox(height: 10),
                          // --- BUSCADOR Y FILTROS TIPO IMAGEN ---
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          height: 55,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search,
                                color: Color(0xFF6BCE7A),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (value) {
                                    setState(() {
                                      _searchQuery = value;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    hintText: "Buscar personas o habilidades",
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 15,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              Container(
                                height: 25,
                                width: 1,
                                color: Colors.grey.withOpacity(0.3),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                              ),
                              GestureDetector(
                                onTap: _openFilterSheet,
                                child: Row(
                                  children: [
                                    const Icon(Icons.tune, color: Color(0xFF6BCE7A)),
                                    const SizedBox(width: 4),
                                    Text(
                                      _filterModeLabel(),
                                      style: const TextStyle(
                                        color: Color(0xFF6BCE7A),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),

                        // --- Menú de Ordenar ---
                        Row(
                          children: [
                            const Text(
                              "Ordenar por: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: darkText,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.3),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _currentSort,
                                  icon: const Icon(
                                    Icons.arrow_drop_down,
                                    color: primaryGreen,
                                  ),
                                  style: const TextStyle(
                                    color: Color(0xFF334A5F),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _currentSort = newValue;
                                      });
                                    }
                                  },
                                  items:
                                      <String>[
                                        'Conexión',
                                        'Nombre',
                                        'Habilidades',
                                      ].map<DropdownMenuItem<String>>((
                                        String value,
                                      ) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // --- Offer / Need ---
                        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          stream: user == null
                              ? null
                              : FirebaseFirestore.instance
                                  .collection('usuarios')
                                  .doc(user.uid)
                                  .snapshots(),
                          builder: (context, snapshot) {
                            final data = snapshot.data?.data() ?? const <String, dynamic>{};
                            return Row(
                              children: [
                                Expanded(
                                  child: _buildOfferCard(primaryGreen, data),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Image.asset(
                                    'assets/images.png',
                                    height: 35,
                                    width: 35, // Asegurar ancho fijo
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.swap_horiz_rounded,
                                            color: primaryGreen, size: 35),
                                  ),
                                ),
                                Expanded(
                                  child: _buildNeedCard(data),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 30),

                        _buildFindMatchButton(primaryGreen),
                        const SizedBox(height: 40),

                        // --- Matches ---
                        const Text(
                          "Suggested Matches",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: darkText,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // StreamBuilder para mostrar usuarios desde Firestore (Lista oficial)
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('usuarios')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return const Text("No hay usuarios registrados");
                            }

                            final currentUserId =
                                FirebaseAuth.instance.currentUser?.uid;
                            final normalizedQuery = _normalizeText(_searchQuery);

                            Map<String, dynamic>? currentUserData;
                            for (final doc in snapshot.data!.docs) {
                              if (doc.id == currentUserId) {
                                currentUserData = doc.data() as Map<String, dynamic>;
                                break;
                              }
                            }

                            final currentNeeds = _normalizeText(
                              _skillSearchText(currentUserData ?? const <String, dynamic>{}),
                            );
                            final recommendationSeed = normalizedQuery.isNotEmpty
                                ? normalizedQuery
                                : currentNeeds;

                            // Primero obtenemos todos los usuarios (excepto el actual)
                            var docs = snapshot.data!.docs
                                .where((doc) => doc.id != currentUserId)
                                .where((doc) {
                                  final userData =
                                      doc.data() as Map<String, dynamic>;
                                  final name = _normalizeText((userData['nombre'] ?? '').toString());
                                  final email = _normalizeText((userData['email'] ?? '').toString());
                                  final needs = _normalizeText((userData['necesita'] ?? '').toString());
                                  final offers = _skillSearchText(userData);
                                  final offeredSkills = _normalizeText(
                                    _stringListFromDynamic(userData['subareasSeleccionadas']).join(' '),
                                  );

                                  switch (_filterMode) {
                                    case SearchFilterMode.people:
                                      if (normalizedQuery.isEmpty) return true;
                                      return name.contains(normalizedQuery) ||
                                          email.contains(normalizedQuery);
                                    case SearchFilterMode.offeredSkills:
                                      if (normalizedQuery.isEmpty) return offers.isNotEmpty;
                                      return offers.contains(normalizedQuery) ||
                                          offeredSkills.contains(normalizedQuery);
                                    case SearchFilterMode.learningSkills:
                                      if (normalizedQuery.isEmpty) return needs.isNotEmpty;
                                      return needs.contains(normalizedQuery) ||
                                          _normalizeText(
                                            _stringListFromDynamic(userData['subareasSeleccionadas']).join(' '),
                                          ).contains(normalizedQuery);
                                    case SearchFilterMode.recommendations:
                                      if (recommendationSeed.isEmpty) {
                                        return false;
                                      }
                                      return offers.contains(recommendationSeed) ||
                                          offeredSkills.contains(recommendationSeed);
                                  }
                                })
                                .toList();

                            if (docs.isEmpty) {
                              final emptyMessage = _filterMode == SearchFilterMode.recommendations && recommendationSeed.isEmpty
                                  ? 'Agrega en bienvenida las habilidades que quieres aprender para recibir recomendaciones.'
                                  : 'No se encontraron resultados para tu búsqueda.';

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 40),
                                child: Center(
                                  child: Text(
                                    emptyMessage,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              );
                            }

                            // AHORA OBTENEMOS LOS ESTADOS DE PRESENCIA PARA ORDENAR POR CONECTADOS
                            return StreamBuilder<DatabaseEvent>(
                              stream: FirebaseDatabase.instance
                                  .ref('status')
                                  .onValue,
                              builder: (context, statusSnapshot) {
                                Map<dynamic, dynamic> statuses = {};
                                if (statusSnapshot.hasData &&
                                    statusSnapshot.data!.snapshot.value !=
                                        null) {
                                  statuses =
                                      statusSnapshot.data!.snapshot.value
                                          as Map<dynamic, dynamic>;
                                }

                                // Aplicar orden según selección del menú
                                docs.sort((a, b) {
                                  var userDataA =
                                      a.data() as Map<String, dynamic>;
                                  var userDataB =
                                      b.data() as Map<String, dynamic>;

                                  if (_currentSort == "Nombre") {
                                    String nameA = (userDataA['nombre'] ?? "")
                                        .toString()
                                        .toLowerCase();
                                    String nameB = (userDataB['nombre'] ?? "")
                                        .toString()
                                        .toLowerCase();
                                    return nameA.compareTo(nameB);
                                  } else if (_currentSort == "Habilidades") {
                                    String skillA = _skillSearchText(userDataA);
                                    String skillB = _skillSearchText(userDataB);
                                    return skillA.compareTo(skillB);
                                  } else {
                                    // Orden por Conexión (Por defecto)
                                    var statusA = statuses[a.id];
                                    var statusB = statuses[b.id];

                                    bool isOnlineA = false;
                                    bool isOnlineB = false;
                                    int lastSeenA = 0;
                                    int lastSeenB = 0;

                                    if (statusA is Map) {
                                      isOnlineA =
                                          (statusA['presence'] ??
                                              statusA['state']) ==
                                          'online';
                                      lastSeenA = statusA['last_seen'] ?? 0;
                                    }

                                    if (statusB is Map) {
                                      isOnlineB =
                                          (statusB['presence'] ??
                                              statusB['state']) ==
                                          'online';
                                      lastSeenB = statusB['last_seen'] ?? 0;
                                    }

                                    if (isOnlineA && !isOnlineB) return -1;
                                    if (!isOnlineA && isOnlineB) return 1;
                                    return lastSeenB.compareTo(lastSeenA);
                                  }
                                });

                                return ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: docs.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 15),
                                  itemBuilder: (context, index) {
                                    var userData =
                                        docs[index].data()
                                            as Map<String, dynamic>;
                                    String uid = docs[index].id;
                                    String name =
                                        userData['nombre'] ??
                                        userData['email']?.split('@')[0] ??
                                        "Usuario";
                                    String photo =
                                        userData['photoUrl'] ??
                                        userData['fotoUrl'] ??
                                        '';

                                    final skillText = _displaySkillText(userData);
                                    final needsText = (userData['necesita'] ?? "Por definir").toString();

                                    return GestureDetector(
                                      onTap: () => _mostrarDetallesUsuario(
                                        context,
                                        userData,
                                        uid,
                                      ),
                                      child: _buildMatchCard(
                                        context,
                                        name: name,
                                        userId: uid,
                                        needs: needsText,
                                        offers: skillText.isEmpty ? "Por definir" : skillText,
                                        imageUrl: photo,
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 30),
                        const SizedBox(height: 10),
                      ],
                      ],
                    ),
                  ),
                ),

                // --- Copyright ---
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text(
                    '© 2026 SkillSwap. Todos los derechos reservados.',
                    style: TextStyle(
                      color: darkText,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- Chat AI Bot con Saludo Animado ---
          Positioned(
            bottom: 60,
            right: 25,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Globo de saludo animado
                if (_showGreeting)
                  FadeTransition(
                    opacity: _bubbleOpacityAnimation,
                    child: ScaleTransition(
                      scale: _bubbleScaleAnimation,
                      alignment: Alignment.bottomRight,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10, right: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(
                            0xFF00A99D,
                          ), // Color secundario para el chat
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          "Hola, bienvenido a SkillSwap",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                // Botón del Bot IA animado
                _buildAIBotButton(primaryGreen),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _skillPill(String text, {Color? backgroundColor, Color? foregroundColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFFF4F8F5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: (foregroundColor ?? const Color(0xFF6BCE7A)).withOpacity(0.18)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: foregroundColor ?? const Color(0xFF4F8D63),
        ),
      ),
    );
  }

  Widget _buildOfferCard(Color green, Map<String, dynamic> userData) {
    final areas = _stringListFromDynamic(userData['areasAprendizaje']);
    final skills = _stringListFromDynamic(userData['subareasSeleccionadas']);
    final offers = _stringListFromDynamic(userData['ofrece']);
    final visibleSkills = skills.isNotEmpty ? skills : offers;

    return Container(
      constraints: const BoxConstraints(minHeight: 240),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: green,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "I OFFER",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Icon(Icons.laptop_chromebook_rounded, size: 52, color: Colors.teal.shade400),
          const SizedBox(height: 10),
          Text(
            areas.isEmpty ? 'Sin áreas seleccionadas' : _previewText(areas, limit: 2),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF334A5F),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: visibleSkills.isEmpty
                ? [
                    _skillPill(
                      'Selecciona subáreas en bienvenida',
                      backgroundColor: Colors.grey.shade100,
                      foregroundColor: Colors.grey.shade600,
                    ),
                  ]
                : visibleSkills.map((skill) => _skillPill(skill)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNeedCard(Map<String, dynamic> userData) {
    final needs = _stringListFromDynamic(userData['necesita']);
    final areas = _stringListFromDynamic(userData['areasAprendizaje']);

    return Container(
      constraints: const BoxConstraints(minHeight: 240),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          // ignore: deprecated_member_use
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF00A99D),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "I NEED",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Icon(Icons.forum_rounded, size: 52, color: Colors.lightGreen.shade600),
          const SizedBox(height: 10),
          Text(
            needs.isEmpty ? 'Lo que quieres aprender' : _previewText(needs, limit: 2),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF334A5F),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: needs.isEmpty
                ? [
                    _skillPill(
                      'Agrega lo que quieres aprender',
                      backgroundColor: Colors.grey.shade100,
                      foregroundColor: Colors.grey.shade600,
                    ),
                  ]
                : needs.map((skill) => _skillPill(skill, backgroundColor: const Color(0xFFE9F7F1))).toList(),
          ),
          if (needs.isEmpty && areas.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _previewText(areas, limit: 2),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFindMatchButton(Color green) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        color: green,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          "Find a Match",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMatchCard(
    BuildContext context, {
    required String name,
    required String needs,
    required String offers,
    required String imageUrl,
    required String userId,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          // ignore: deprecated_member_use
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          StreamBuilder(
            stream: FirebaseDatabase.instance.ref("status/$userId").onValue,
            builder: (context, snapshot) {
              bool isOnline = false;
              if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                final dynamic value = snapshot.data!.snapshot.value;
                if (value is Map) {
                  isOnline = value["presence"] == "online";
                } else if (value is Map<dynamic, dynamic>) {
                  isOnline = value["presence"] == "online";
                }
              }

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildUserAvatar(imageUrl, name, radius: 35),
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      height: 18,
                      width: 18,
                      decoration: BoxDecoration(
                        color: isOnline
                            ? const Color(0xFF4CAF50)
                            : Colors.grey.shade400,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: isOnline
                            ? [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.4),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF334A5F),
                      ),
                    ),
                    const Spacer(),
                    StreamBuilder(
                      stream: FirebaseDatabase.instance
                          .ref("status/$userId")
                          .onValue,
                      builder: (context, snapshot) {
                        if (snapshot.hasData &&
                            snapshot.data!.snapshot.value != null) {
                          final dynamic value = snapshot.data!.snapshot.value;
                          bool online = false;
                          dynamic lastSeen;

                          if (value is Map) {
                            online = value["presence"] == "online";
                            lastSeen = value["last_seen"];
                          } else if (value is Map<dynamic, dynamic>) {
                            online = value["presence"] == "online";
                            lastSeen = value["last_seen"];
                          }

                          if (online) {
                            return const Text(
                              "Activo(a)",
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4CAF50),
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          } else if (lastSeen != null) {
                            try {
                              int lastSeenTimestamp = 0;
                              if (lastSeen is int) {
                                lastSeenTimestamp = lastSeen;
                              } else if (lastSeen is double) {
                                lastSeenTimestamp = lastSeen.toInt();
                              }

                              if (lastSeenTimestamp == 0) {
                                return const SizedBox.shrink();
                              }

                              DateTime date =
                                  DateTime.fromMillisecondsSinceEpoch(
                                    lastSeenTimestamp,
                                  );
                              final now = DateTime.now();
                              final diff = now.difference(date);

                              String status = "";
                              if (diff.inMinutes < 1) {
                                status = "Reciente";
                              } else if (diff.inMinutes < 60) {
                                status = "${diff.inMinutes}m";
                              } else if (diff.inHours < 24) {
                                status =
                                    "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
                              } else {
                                status = "${date.day}/${date.month}";
                              }

                              return Text(
                                status,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            } catch (e) {
                              return const SizedBox.shrink();
                            }
                          }
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Color(0xFF334A5F)),
                    children: [
                      const TextSpan(
                        text: "Needs: ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6BCE7A),
                        ),
                      ),
                      TextSpan(text: needs),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Color(0xFF334A5F)),
                    children: [
                      const TextSpan(
                        text: "Offers: ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6BCE7A),
                        ),
                      ),
                      TextSpan(text: offers),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: _favoriteIds.contains(userId)
                    ? 'Quitar de favoritos'
                    : 'Agregar a favoritos',
                onPressed: _favoritesLoaded
                    ? () => _toggleFavorito(userId)
                    : null,
                icon: Icon(
                  _favoriteIds.contains(userId)
                      ? Icons.star
                      : Icons.star_border,
                  color: _favoriteIds.contains(userId)
                      ? Colors.amber
                      : Colors.grey,
                ),
              ),
              IconButton(
                tooltip: 'Calificar usuario',
                onPressed: () => CalificacionesScreen.mostrarDialogoCalificar(
                  context,
                  userId,
                  name,
                ),
                icon: const Icon(
                  Icons.star_rate_rounded,
                  color: Color(0xFF00A99D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingReminder() {
    // Buscar la próxima reunión aceptada
    Map<String, dynamic>? nextMeeting;
    DateTime? nextDate;
    final now = DateTime.now();

    _events.forEach((date, events) {
      for (var event in events) {
        if (event['status'] == 'accepted') {
          try {
            final dt = DateTime.parse(event['meetingDate']);
            if (dt.isAfter(now)) {
              if (nextDate == null || dt.isBefore(nextDate!)) {
                nextDate = dt;
                nextMeeting = event;
              }
            }
          } catch (e) {
            debugPrint("Error parsing meeting date: $e");
          }
        }
      }
    });

    if (nextMeeting == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6BCE7A), Color(0xFF00A99D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00A99D).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.event_available, color: Colors.white, size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Próxima reunión programada",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Con ${nextMeeting!['senderName'] ?? 'Usuario'}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${nextDate!.day}/${nextDate!.month} a las ${nextDate!.hour}:${nextDate!.minute.toString().padLeft(2, '0')}",
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CalendarioScreen(
                    otherUserId: nextMeeting!['senderId'] == FirebaseAuth.instance.currentUser?.uid
                        ? nextMeeting!['receiverId']
                        : nextMeeting!['senderId'],
                    otherUserName: nextMeeting!['senderId'] == FirebaseAuth.instance.currentUser?.uid
                        ? nextMeeting!['receiverName']
                        : nextMeeting!['senderName'],
                  ),
                ),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("VER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Las funciones antiguas _buildCalendarView han sido movidas a lib/widgets/calendario_view.dart

  // --- Widget del Bot IA Animado ---
  Widget _buildAIBotButton(Color green) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/ai'),
      child: AnimatedBuilder(
        animation: _botAnimationController,
        builder: (context, child) {
          return ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              height: 70, // Un poco más grande para que resalte la imagen
              width: 70,
              decoration: BoxDecoration(
                color: Colors
                    .white, // Fondo blanco para que resalte el robot verde
                shape: BoxShape.circle,
                boxShadow: [
                  // Brillo parpadeante animado
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: green.withOpacity(_glowAnimation.value),
                    blurRadius: 20 * _scaleAnimation.value,
                    spreadRadius: 5 * _scaleAnimation.value,
                  ),
                  // Sombra base
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(5), // Espacio para el borde blanco
              child: ClipOval(
                child: Image.asset(
                  'assets/Chatbot_SkillSwap.png', // Tu imagen proporcionada
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(IconData icon, String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF6BCE7A).withOpacity(0.3)
              : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? const Color(0xFF6BCE7A) : Colors.amber,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFF6BCE7A)
                  : const Color(0xFF334A5F),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}