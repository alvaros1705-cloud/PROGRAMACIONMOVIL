import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

const List<String> _areaOrder = [
  'tecnologia',
  'arte_diseno',
  'comunicacion',
  'negocios',
  'bienestar',
  'musica',
  'ciencia',
  'medicina',
  'matematicas',
];

const Map<String, Map<String, dynamic>> _skillAreas = {
  'tecnologia': {
    'es': 'Tecnología',
    'en': 'Technology',
    'icon': Icons.code,
    'color': Color(0xFFA5D6A7),
    'subareasEs': [
      'Desarrollo Web',
      'Desarrollo Móvil',
      'Inteligencia Artificial',
      'Machine Learning',
      'Ciberseguridad',
      'Cloud Computing',
      'Data Science',
      'Blockchain',
      'Internet de las Cosas (IoT)',
      'Realidad Virtual / Realidad Aumentada',
      'DevOps',
      'Robótica',
      'Programación Backend',
      'Programación Frontend',
      'Bases de Datos',
      'Automatización',
      'Big Data',
      'Criptografía',
      'UX/UI para Tecnología',
      'Redes y Telecomunicaciones',
    ],
    'subareasEn': [
      'Web Development',
      'Mobile Development',
      'Artificial Intelligence',
      'Machine Learning',
      'Cybersecurity',
      'Cloud Computing',
      'Data Science',
      'Blockchain',
      'Internet of Things (IoT)',
      'Virtual Reality / Augmented Reality',
      'DevOps',
      'Robotics',
      'Backend Development',
      'Frontend Development',
      'Databases',
      'Automation',
      'Big Data',
      'Cryptography',
      'UX/UI for Technology',
      'Networking and Telecommunications',
    ],
  },
  'arte_diseno': {
    'es': 'Arte y Diseño',
    'en': 'Art and Design',
    'icon': Icons.palette,
    'color': Color(0xFFFFCCBC),
    'subareasEs': [
      'Diseño Gráfico',
      'Ilustración Digital',
      'Animación 2D/3D',
      'Diseño UI/UX',
      'Fotografía',
      'Diseño de Moda',
      'Diseño Industrial',
      'Arte Digital (NFTs)',
      'Tipografía',
      'Motion Graphics',
      'Diseño de Interiores',
      'Escultura',
      'Pintura Digital',
      'Diseño de Personajes',
      'Branding',
      'Diseño Editorial',
      'Videoarte',
      'Arte Generativo',
      'Diseño de Joyería',
      'Concept Art',
    ],
    'subareasEn': [
      'Graphic Design',
      'Digital Illustration',
      '2D/3D Animation',
      'UI/UX Design',
      'Photography',
      'Fashion Design',
      'Industrial Design',
      'Digital Art (NFTs)',
      'Typography',
      'Motion Graphics',
      'Interior Design',
      'Sculpture',
      'Digital Painting',
      'Character Design',
      'Branding',
      'Editorial Design',
      'Video Art',
      'Generative Art',
      'Jewelry Design',
      'Concept Art',
    ],
  },
  'comunicacion': {
    'es': 'Bienotas',
    'en': 'Communications',
    'icon': Icons.chat_bubble_outline,
    'color': Color(0xFFB2EBF2),
    'subareasEs': [
      'Comunicación Digital',
      'Periodismo Digital',
      'Marketing de Contenidos',
      'Relaciones Públicas',
      'Community Management',
      'Psicología Social',
      'Coaching Personal',
      'Oratoria y Comunicación',
      'Redacción Creativa',
      'Podcasting',
      'Producción de Contenido',
      'Gestión de Redes Sociales',
      'Mediación y Resolución de Conflictos',
      'Comunicación Organizacional',
      'Influencer Marketing',
      'Storytelling',
      'Comunicación No Verbal',
      'Periodismo de Investigación',
      'Locución',
      'Gestión de Crisis',
    ],
    'subareasEn': [
      'Digital Communication',
      'Digital Journalism',
      'Content Marketing',
      'Public Relations',
      'Community Management',
      'Social Psychology',
      'Personal Coaching',
      'Public Speaking and Communication',
      'Creative Writing',
      'Podcasting',
      'Content Production',
      'Social Media Management',
      'Mediation and Conflict Resolution',
      'Organizational Communication',
      'Influencer Marketing',
      'Storytelling',
      'Nonverbal Communication',
      'Investigative Journalism',
      'Voice Acting',
      'Crisis Management',
    ],
  },
  'negocios': {
    'es': 'Negocios',
    'en': 'Business',
    'icon': Icons.business_center,
    'color': Color(0xFFFFF9C4),
    'subareasEs': [
      'Emprendimiento',
      'Marketing Digital',
      'Finanzas',
      'Administración de Empresas',
      'Ventas',
      'E-commerce',
      'Gestión de Proyectos',
      'Recursos Humanos',
      'Contabilidad',
      'Estrategia Empresarial',
      'Innovación y Disruptión',
      'Negocios Internacionales',
      'Logística y Cadena de Suministro',
      'Análisis Financiero',
      'Liderazgo',
      'Franquicias',
      'Startups',
      'Negociación',
      'Gestión de Riesgos',
      'Sostenibilidad Empresarial',
    ],
    'subareasEn': [
      'Entrepreneurship',
      'Digital Marketing',
      'Finance',
      'Business Administration',
      'Sales',
      'E-commerce',
      'Project Management',
      'Human Resources',
      'Accounting',
      'Business Strategy',
      'Innovation and Disruption',
      'International Business',
      'Logistics and Supply Chain',
      'Financial Analysis',
      'Leadership',
      'Franchises',
      'Startups',
      'Negotiation',
      'Risk Management',
      'Corporate Sustainability',
    ],
  },
  'bienestar': {
    'es': 'Bienestar',
    'en': 'Wellness',
    'icon': Icons.filter_vintage,
    'color': Color(0xFFC5CAE9),
    'subareasEs': [
      'Mindfulness y Meditación',
      'Fitness y Entrenamiento',
      'Nutrición',
      'Psicología Positiva',
      'Yoga',
      'Salud Mental',
      'Coaching de Vida',
      'Terapias Alternativas',
      'Sueño y Descanso',
      'Productividad Personal',
      'Gestión del Estrés',
      'Alimentación Saludable',
      'Ejercicio en Casa',
      'Bienestar Emocional',
      'Terapia Holística',
      'Motivación Personal',
      'Autoestima',
      'Relaciones Saludables',
      'Hábitos Saludables',
      'Balance Vida-Trabajo',
    ],
    'subareasEn': [
      'Mindfulness and Meditation',
      'Fitness and Training',
      'Nutrition',
      'Positive Psychology',
      'Yoga',
      'Mental Health',
      'Life Coaching',
      'Alternative Therapies',
      'Sleep and Rest',
      'Personal Productivity',
      'Stress Management',
      'Healthy Eating',
      'Home Exercise',
      'Emotional Wellbeing',
      'Holistic Therapy',
      'Personal Motivation',
      'Self-Esteem',
      'Healthy Relationships',
      'Healthy Habits',
      'Work-Life Balance',
    ],
  },
  'musica': {
    'es': 'Música',
    'en': 'Music',
    'icon': Icons.music_note,
    'color': Color(0xFFFFE0B2),
    'subareasEs': [
      'Producción Musical',
      'Composición',
      'Canto',
      'Ingeniería de Audio',
      'DJ y Mezcla',
      'Teoría Musical',
      'Instrumentos (Guitarra, Piano, etc.)',
      'Música Electrónica',
      'Canto Coral',
      'Sound Design',
      'Musicoterapia',
      'Marketing Musical',
      'Gestión de Artistas',
      'Edición Musical',
      'Arreglos Musicales',
      'Música para Videojuegos',
      'Canto Lírico',
      'Beatmaking',
      'Historia de la Música',
      'Performance Escénica',
    ],
    'subareasEn': [
      'Music Production',
      'Composition',
      'Singing',
      'Audio Engineering',
      'DJing and Mixing',
      'Music Theory',
      'Instruments (Guitar, Piano, etc.)',
      'Electronic Music',
      'Choral Singing',
      'Sound Design',
      'Music Therapy',
      'Music Marketing',
      'Artist Management',
      'Music Editing',
      'Musical Arrangements',
      'Video Game Music',
      'Operatic Singing',
      'Beatmaking',
      'Music History',
      'Stage Performance',
    ],
  },
  'ciencia': {
    'es': 'Ciencia',
    'en': 'Science',
    'icon': Icons.science,
    'color': Color(0xFFD1C4E9),
    'subareasEs': [
      'Física',
      'Química',
      'Biología',
      'Astronomía',
      'Matemáticas Avanzadas',
      'Genética',
      'Neurociencia',
      'Ecología',
      'Biotecnología',
      'Ciencia de Datos',
      'Meteorología',
      'Geología',
      'Bioquímica',
      'Astrofísica',
      'Investigación Científica',
      'Ciencia Ambiental',
      'Microbiología',
      'Paleontología',
      'Química Orgánica',
      'Física Cuántica',
    ],
    'subareasEn': [
      'Physics',
      'Chemistry',
      'Biology',
      'Astronomy',
      'Advanced Mathematics',
      'Genetics',
      'Neuroscience',
      'Ecology',
      'Biotechnology',
      'Data Science',
      'Meteorology',
      'Geology',
      'Biochemistry',
      'Astrophysics',
      'Scientific Research',
      'Environmental Science',
      'Microbiology',
      'Paleontology',
      'Organic Chemistry',
      'Quantum Physics',
    ],
  },
  'medicina': {
    'es': 'Medicina',
    'en': 'Medicine',
    'icon': Icons.medical_services,
    'color': Color(0xFFF8BBD0),
    'subareasEs': [
      'Medicina General',
      'Cardiología',
      'Pediatría',
      'Cirugía',
      'Nutrición Clínica',
      'Psicología Clínica',
      'Enfermería',
      'Farmacología',
      'Odontología',
      'Dermatología',
      'Traumatología',
      'Ginecología',
      'Oncología',
      'Medicina Deportiva',
      'Salud Pública',
      'Terapia Física',
      'Radiología',
      'Anatomía',
      'Inmunología',
      'Epidemiología',
    ],
    'subareasEn': [
      'General Medicine',
      'Cardiology',
      'Pediatrics',
      'Surgery',
      'Clinical Nutrition',
      'Clinical Psychology',
      'Nursing',
      'Pharmacology',
      'Dentistry',
      'Dermatology',
      'Traumatology',
      'Gynecology',
      'Oncology',
      'Sports Medicine',
      'Public Health',
      'Physical Therapy',
      'Radiology',
      'Anatomy',
      'Immunology',
      'Epidemiology',
    ],
  },
  'matematicas': {
    'es': 'Matemáticas',
    'en': 'Mathematics',
    'icon': Icons.calculate,
    'color': Color(0xFFB39DDB),
    'subareasEs': [
      'Álgebra',
      'Geometría',
      'Cálculo Diferencial',
      'Cálculo Integral',
      'Estadística y Probabilidad',
      'Trigonometría',
      'Álgebra Lineal',
      'Matemáticas Discretas',
      'Ecuaciones Diferenciales',
      'Análisis Matemático',
      'Teoría de Números',
      'Geometría Analítica',
      'Optimización y Programación Lineal',
      'Matemáticas Financieras',
      'Lógica Matemática',
      'Topología',
      'Matemáticas Aplicadas',
      'Criptografía Matemática',
      'Combinatoria',
      'Matemáticas para Ingeniería y Ciencias',
    ],
    'subareasEn': [
      'Algebra',
      'Geometry',
      'Differential Calculus',
      'Integral Calculus',
      'Statistics and Probability',
      'Trigonometry',
      'Linear Algebra',
      'Discrete Mathematics',
      'Differential Equations',
      'Mathematical Analysis',
      'Number Theory',
      'Analytic Geometry',
      'Optimization and Linear Programming',
      'Financial Mathematics',
      'Mathematical Logic',
      'Topology',
      'Applied Mathematics',
      'Mathematical Cryptography',
      'Combinatorics',
      'Mathematics for Engineering and Sciences',
    ],
  },
};

const Map<String, Map<String, String>> _uiText = {
  'headerStep1': {'es': 'Paso 1: Tu Base', 'en': 'Step 1: Your Base'},
  'headerStep2': {'es': 'Paso 2: Conocimientos', 'en': 'Step 2: Skills'},
  'skip': {'es': 'Omitir', 'en': 'Skip'},
  'welcomeTitle': {
    'es': 'BIENVENIDO A TU\nCAMINO INTERCAMBIO \nDE HABILIDADES',
    'en': 'WELCOME TO YOUR\nSKILLSWAP JOURNEY',
  },
  'welcomeBody': {
    'es': 'Completa tu perfil para obtener las coincidencias perfectas. Te preguntaremos tus intereses para personalizar tu experiencia.',
    'en': 'Complete your profile to get the best matches. We will ask about your interests to personalize your experience.',
  },
  'nameLabel': {'es': 'Introduce tu nombre', 'en': 'Enter your name'},
  'nameHint': {'es': 'Tu Nombre', 'en': 'Your name'},
  'languageLabel': {'es': 'Selecciona tu idioma nativo', 'en': 'Select your native language'},
  'languageHint': {'es': 'Seleccionar Idioma', 'en': 'Select language'},
  'continue': {'es': 'Siguiente', 'en': 'Continue'},
  'back': {'es': 'Atrás', 'en': 'Back'},
  'step2Title': {
    'es': '¿QUÉ CONOCIMIENTO\nPUEDES COMPARTIR?',
    'en': 'WHAT KNOWLEDGE\nCAN YOU SHARE?',
  },
  'step2Subtitle': {'es': 'Selecciona hasta 5 áreas', 'en': 'Select up to 5 areas'},
  'areaLabel': {'es': 'Áreas seleccionadas', 'en': 'Selected areas'},
  'subareaLabel': {'es': 'Subárea', 'en': 'Sub-area'},
  'subareaHint': {'es': 'Selecciona una subárea', 'en': 'Select a sub-area'},
  'save': {'es': 'Guardar y continuar', 'en': 'Save and continue'},
  'loadingTitle': {'es': 'Preparando tu experiencia...', 'en': 'Preparing your experience...'},
  'loadingSubtitle': {'es': 'Estamos personalizando SkillSwap para ti', 'en': 'We are personalizing SkillSwap for you'},
  'loadingFooter': {'es': 'SkillSwap v1.2', 'en': 'SkillSwap v1.2'},
  'loadingAuthors': {'es': 'Autores: SkillSwap Team', 'en': 'Authors: SkillSwap Team'},
  'confirmTitle': {'es': 'Confirmar áreas', 'en': 'Confirm areas'},
  'confirmSave': {'es': '¿Seguro que quieres agregar estas áreas?', 'en': 'Are you sure you want to add these areas?'},
  'yes': {'es': 'Sí, guardar', 'en': 'Yes, save'},
  'no': {'es': 'Cancelar', 'en': 'Cancel'},
  'noSelection': {'es': 'Selecciona al menos una área para continuar.', 'en': 'Select at least one area to continue.'},
  'saveError': {'es': 'No se pudo guardar la información. Intenta de nuevo.', 'en': 'Could not save the information. Please try again.'},
};

class BienvenidaPerfil extends StatefulWidget {
  const BienvenidaPerfil({super.key});

  @override
  State<BienvenidaPerfil> createState() => _BienvenidaPerfilState();
}

class _BienvenidaPerfilState extends State<BienvenidaPerfil> {
  final TextEditingController _nameController = TextEditingController();

  int _currentStep = 0;
  String _selectedLanguage = 'es';
  bool _isLoading = true;
  final bool _isSaving = false;
  String _uid = '';
  
  // Variables para la imagen de perfil
  String? _photoUrl;
  File? _imageFile;

  final Set<String> _selectedAreas = <String>{};
  final Map<String, Set<String>> _selectedSubareas = <String, Set<String>>{};

  final Color primaryGreen = const Color(0xFF6BCE7A);
  final Color darkText = const Color(0xFF1D1B20);
  final Color greyText = const Color(0xFF49454F);

  @override
  void initState() {
    super.initState();
    _cargarEstadoInicial();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _t(String key) {
    return _uiText[key]?[_selectedLanguage] ?? _uiText[key]?['es'] ?? key;
  }

  Map<String, dynamic> _areaData(String key) => _skillAreas[key]!;

  String _areaLabel(String key) => _areaData(key)[_selectedLanguage == 'en' ? 'en' : 'es'] as String;

  // Método para seleccionar y procesar la imagen (igual que en ventana_perfil)
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (pickedFile != null) {
      final result = await FlutterImageCompress.compressWithFile(
        pickedFile.path,
        quality: 40,
        minWidth: 400,
        minHeight: 400,
      );

      if (result != null) {
        final base64String = base64Encode(result);
        setState(() {
          _imageFile = File(pickedFile.path);
          _photoUrl = base64String;
        });
      }
    }
  }

  Widget _buildProfileAvatar({double radius = 50}) {
    final name = _nameController.text.trim().isEmpty ? 'User' : _nameController.text.trim();
    final fallbackUrl = 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=6BCE7A&color=fff&size=200';

    return Stack(
      children: [
        Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: primaryGreen, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: _imageFile != null
                ? Image.file(_imageFile!, fit: BoxFit.cover)
                : (_photoUrl != null && _photoUrl!.isNotEmpty
                    ? (_photoUrl!.startsWith('http')
                        ? Image.network(_photoUrl!, fit: BoxFit.cover)
                        : Builder(builder: (context) {
                            try {
                              String base64Data = _photoUrl!;
                              if (base64Data.contains(',')) {
                                base64Data = base64Data.split(',').last;
                              }
                              return Image.memory(
                                base64Decode(base64Data),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Image.network(fallbackUrl),
                              );
                            } catch (e) {
                              return Image.network(fallbackUrl);
                            }
                          }))
                    : Image.network(fallbackUrl)),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryGreen,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  List<String> _subareasFor(String key) {
    final list = _areaData(key)[_selectedLanguage == 'en' ? 'subareasEn' : 'subareasEs'] as List<dynamic>;
    return list.map((item) => item.toString()).toList();
  }

  IconData _subareaIcon(String label) {
    final normalized = label.toLowerCase();
    if (normalized.contains('web') || normalized.contains('frontend') || normalized.contains('backend') || normalized.contains('app') || normalized.contains('móvil') || normalized.contains('mobile')) {
      return Icons.language;
    }
    if (normalized.contains('ia') || normalized.contains('inteligencia') || normalized.contains('machine') || normalized.contains('data') || normalized.contains('datos') || normalized.contains('big data')) {
      return Icons.psychology;
    }
    if (normalized.contains('seguridad') || normalized.contains('criptograf') || normalized.contains('redes')) {
      return Icons.security;
    }
    if (normalized.contains('diseño') || normalized.contains('design') || normalized.contains('ui') || normalized.contains('ux') || normalized.contains('branding') || normalized.contains('tipograf')) {
      return Icons.design_services;
    }
    if (normalized.contains('foto') || normalized.contains('ilustr') || normalized.contains('arte') || normalized.contains('pintura') || normalized.contains('concept')) {
      return Icons.image;
    }
    if (normalized.contains('marketing') || normalized.contains('ventas') || normalized.contains('negoci') || normalized.contains('finanz') || normalized.contains('business') || normalized.contains('proyecto')) {
      return Icons.trending_up;
    }
    if (normalized.contains('medicina') || normalized.contains('salud') || normalized.contains('enfer') || normalized.contains('clin')) {
      return Icons.local_hospital;
    }
    if (normalized.contains('musical') || normalized.contains('música') || normalized.contains('music') || normalized.contains('canto') || normalized.contains('audio') || normalized.contains('dj')) {
      return Icons.music_note;
    }
    if (normalized.contains('física') || normalized.contains('química') || normalized.contains('biolog') || normalized.contains('astronom') || normalized.contains('ciencia') || normalized.contains('geología')) {
      return Icons.science;
    }
    if (normalized.contains('math') || normalized.contains('álgebra') || normalized.contains('geometr') || normalized.contains('cálculo') || normalized.contains('estad')) {
      return Icons.calculate;
    }
    if (normalized.contains('bienestar') || normalized.contains('yoga') || normalized.contains('mindfulness') || normalized.contains('salud mental') || normalized.contains('fitness')) {
      return Icons.self_improvement;
    }
    return Icons.star_outline;
  }

  String _defaultName(String email) {
    if (_nameController.text.trim().isNotEmpty) {
      return _nameController.text.trim();
    }
    if (email.contains('@')) {
      return email.split('@').first;
    }
    return 'User';
  }

  List<String> _skillsForFirestore() {
    final values = <String>[];
    for (final areaKey in _areaOrder.where(_selectedAreas.contains)) {
      final subareas = _selectedSubareas[areaKey]?.toList() ?? const <String>[];
      if (subareas.isNotEmpty) {
        values.addAll(subareas);
      } else {
        values.add(_areaLabel(areaKey));
      }
    }
    return values;
  }

  Future<void> _cargarEstadoInicial() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    _uid = user.uid;
    try {
      final doc = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
      final data = doc.data();
      if (data != null) {
        final onboardingCompletado = data['onboardingCompletado'] == true;
        if (onboardingCompletado) {
          if (mounted) Navigator.pushReplacementNamed(context, '/home');
          return;
        }

        _nameController.text = (data['nombre'] ?? '').toString();
        _selectedLanguage = (data['idiomaPreferido'] ?? 'es').toString();

        final areasIds = data['areasAprendizajeIds'];
        if (areasIds is List) {
          _selectedAreas.addAll(areasIds.map((item) => item.toString()));
        }

        final subareasMap = data['subareasPorArea'];
        if (subareasMap is Map) {
          subareasMap.forEach((key, value) {
            final keyString = key.toString();
            if (value is List) {
              _selectedSubareas[keyString] = value.map((item) => item.toString()).toSet();
            } else if (value != null) {
              _selectedSubareas[keyString] = {value.toString()};
            }
          });
        }

        final selectedSkills = data['habilidades'];
        if (_selectedAreas.isNotEmpty && _selectedSubareas.isEmpty && selectedSkills is String && selectedSkills.trim().isNotEmpty) {
          _selectedSubareas[_selectedAreas.first] = selectedSkills.split(',').map((item) => item.trim()).where((item) => item.isNotEmpty).toSet();
        }
      }
    } catch (e) {
      debugPrint('Error cargando onboarding: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _guardarPasoBasico() async {
    if (_uid.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '';
    await FirebaseFirestore.instance.collection('usuarios').doc(_uid).set({
      'uid': _uid,
      'email': email,
      'nombre': _defaultName(email),
      'idiomaPreferido': _selectedLanguage,
      'idiomaPreferidoTexto': _selectedLanguage == 'en' ? 'English' : 'Español',
      'onboardingCompletado': false,
      'onboardingOmitido': false,
      'onboardingVisto': true,
      'actualizadoEn': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _finalizarOnboarding({required bool omitido}) async {
    if (_uid.isEmpty) return;

    setState(() => _currentStep = 2);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    try {
      final user = FirebaseAuth.instance.currentUser;
      final email = user?.email ?? '';
      final skills = _skillsForFirestore();
      final selectedAreaKeys = _areaOrder.where(_selectedAreas.contains).toList();
      final areaLabels = selectedAreaKeys.map(_areaLabel).toList();
      final subareasPorArea = <String, List<String>>{};

      for (final areaKey in selectedAreaKeys) {
        final values = _selectedSubareas[areaKey]?.toList() ?? const <String>[];
        if (values.isNotEmpty) {
          subareasPorArea[areaKey] = values;
        }
      }

      final Map<String, dynamic> firestoreData = {
        'uid': _uid,
        'email': email,
        'nombre': _defaultName(email),
        'idiomaPreferido': _selectedLanguage,
        'idiomaPreferidoTexto': _selectedLanguage == 'en' ? 'English' : 'Español',
        'areasAprendizajeIds': selectedAreaKeys,
        'areasAprendizaje': areaLabels,
        'subareasPorArea': subareasPorArea,
        'subareasSeleccionadas': skills,
        'habilidades': skills.join(', '),
        'especialidad': skills.isNotEmpty ? skills.join(', ') : areaLabels.join(', '),
        'ofrece': skills.isNotEmpty ? skills.join(', ') : areaLabels.join(', '),
        'onboardingCompletado': !omitido && skills.isNotEmpty,
        'onboardingOmitido': omitido,
        'onboardingVisto': true,
        'actualizadoEn': FieldValue.serverTimestamp(),
      };

      if (_photoUrl != null && _photoUrl!.isNotEmpty) {
        firestoreData['photoUrl'] = _photoUrl;
        firestoreData['fotoUrl'] = _photoUrl;
      }

      await FirebaseFirestore.instance.collection('usuarios').doc(_uid).set(firestoreData, SetOptions(merge: true));

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      debugPrint('Error al guardar onboarding: $e');
      if (!mounted) return;
      setState(() => _currentStep = 1);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t('saveError'))),
      );
    }
  }

  Future<void> _confirmarYGuardar() async {
    if (_selectedAreas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t('noSelection'))),
      );
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_t('confirmTitle')),
        content: Text(_t('confirmSave')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(_t('no'))),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text(_t('yes'))),
        ],
      ),
    );

    if (confirmar == true) {
      await _finalizarOnboarding(omitido: false);
    }
  }

  Future<void> _omitir() async {
    if (_uid.isEmpty) return;
    await _finalizarOnboarding(omitido: true);
  }

  Future<void> _abrirSubareas(String areaKey) async {
    final subareas = _subareasFor(areaKey);
    _selectedAreas.add(areaKey);
    _selectedSubareas.putIfAbsent(areaKey, () => <String>{});
    Set<String> tempSelection = Set<String>.from(_selectedSubareas[areaKey] ?? {});

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 16,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  ),
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
                      const SizedBox(height: 14),
                      Text(
                        _areaLabel(areaKey),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _selectedLanguage == 'en'
                            ? 'Select one or more sub-areas'
                            : 'Selecciona una o varias subáreas',
                        style: TextStyle(color: greyText),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.45,
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: subareas.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final label = subareas[index];
                            final selected = tempSelection.contains(label);
                            return InkWell(
                              onTap: () {
                                setModalState(() {
                                  if (selected) {
                                    tempSelection.remove(label);
                                  } else {
                                    tempSelection.add(label);
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: selected ? primaryGreen.withOpacity(0.14) : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: selected ? primaryGreen : Colors.grey.shade300,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: selected ? primaryGreen : Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        _subareaIcon(label),
                                        size: 20,
                                        color: selected ? Colors.white : darkText,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        label,
                                        style: TextStyle(
                                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Checkbox(
                                      value: selected,
                                      onChanged: (_) {
                                        setModalState(() {
                                          if (selected) {
                                            tempSelection.remove(label);
                                          } else {
                                            tempSelection.add(label);
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedSubareas.remove(areaKey);
                                _selectedAreas.remove(areaKey);
                              });
                              Navigator.pop(context, false);
                            },
                            child: Text(_selectedLanguage == 'en' ? 'Remove area' : 'Quitar área'),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(_selectedLanguage == 'en' ? 'Cancel' : 'Cancelar'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: _buttonStyle(primaryGreen),
                            child: Text(_selectedLanguage == 'en' ? 'Save' : 'Guardar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        _selectedAreas.add(areaKey);
        _selectedSubareas[areaKey] = tempSelection;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/Fondo_SkillSwap.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: _isLoading
                ? _buildLoadingScreen()
                : (_currentStep == 0 ? _buildStep1() : _buildStep2()),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return _SkillSwapAnimatedLoading(
      primaryGreen: primaryGreen,
      secondaryBlue: const Color(0xFF00A99D),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          _buildHeader(_t('headerStep1'), showSkip: true, onSkip: _omitir),
          const SizedBox(height: 28),
          Text(
            _t('welcomeTitle'),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: darkText,
              height: 1.1,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: _buildProfileAvatar(radius: 70),
          ),
          const SizedBox(height: 24),
          Text(_t('nameLabel'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: _t('nameHint'),
              fillColor: Colors.white.withOpacity(0.8),
              filled: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(_t('languageLabel'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedLanguage,
                hint: Text(_t('languageHint')),
                isExpanded: true,
                items: [
                  DropdownMenuItem(value: 'es', child: Text(_selectedLanguage == 'en' ? 'Spanish' : 'Español')),
                  DropdownMenuItem(value: 'en', child: Text(_selectedLanguage == 'en' ? 'English' : 'Inglés')),
                ],
                onChanged: (val) {
                  if (val == null) return;
                  setState(() => _selectedLanguage = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 40),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () async {
                await _guardarPasoBasico();
                if (!mounted) return;
                setState(() => _currentStep = 1);
              },
              style: _buttonStyle(primaryGreen),
              child: Text(_t('continue'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          _buildHeader(_t('headerStep2'), showSkip: true, onSkip: _omitir),
          const SizedBox(height: 24),
          Text(
            _t('step2Title'),
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: darkText, height: 1.1),
          ),
          const SizedBox(height: 10),
          Text(
            _t('step2Subtitle'),
            style: TextStyle(fontSize: 16, color: greyText, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 8,
              childAspectRatio: 0.62, // Mayor altura para evitar desbordamientos
            ),
            itemCount: _areaOrder.length,
            itemBuilder: (context, index) {
              final areaKey = _areaOrder[index];
              final isSelected = _selectedAreas.contains(areaKey) || (_selectedSubareas[areaKey]?.isNotEmpty ?? false);
              final areaData = _areaData(areaKey);
              final selectedCount = _selectedSubareas[areaKey]?.length ?? 0;
              return GestureDetector(
                onTap: () {
                  if (!isSelected && _selectedAreas.length >= 5) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_selectedLanguage == 'en' ? 'You can select up to 5 areas.' : 'Puedes seleccionar hasta 5 áreas.')),
                    );
                    return;
                  }
                  _abrirSubareas(areaKey);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 54, // Tamaño fijo para simetría
                      height: 54,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryGreen.withOpacity(0.5) : areaData['color'],
                        shape: BoxShape.circle,
                        border: isSelected ? Border.all(color: primaryGreen, width: 3) : null,
                      ),
                      child: Icon(areaData['icon'] as IconData, color: isSelected ? Colors.white : Colors.black87, size: 24),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 28, // Altura fija para el texto para mantener simetría
                      child: Text(
                        areaData[_selectedLanguage == 'en' ? 'en' : 'es'] as String,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10, 
                          height: 1.1,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: darkText,
                        ),
                      ),
                    ),
                    if (selectedCount > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '$selectedCount ${_selectedLanguage == 'en' ? 'skills' : 'hab.'}',
                          style: TextStyle(fontSize: 9, color: primaryGreen, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          if (_selectedAreas.isNotEmpty) ...[
            Text(
              _t('areaLabel'),
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: darkText),
            ),
            const SizedBox(height: 10),
            ..._selectedAreas.map((areaKey) {
              final subareas = _selectedSubareas[areaKey]?.toList() ?? <String>[];
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.82),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_areaLabel(areaKey), style: TextStyle(fontWeight: FontWeight.bold, color: darkText)),
                      const SizedBox(height: 10),
                      Text(
                        subareas.isEmpty
                            ? (_selectedLanguage == 'en' ? 'Tap the area to choose sub-areas.' : 'Toca el área para elegir subáreas.')
                            : subareas.join(', '),
                        style: TextStyle(color: darkText.withOpacity(0.8)),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
          const SizedBox(height: 10),
          Center(
            child: Image.asset(
              'assets/imsgene_intercambio.png',
              height: 160, 
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextButton(
                  onPressed: () {
                    setState(() => _currentStep = 0);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(_t('back'), style: const TextStyle(fontSize: 15)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 5,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _confirmarYGuardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: Text(
                    _t('save'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildHeader(String stepText, {required bool showSkip, VoidCallback? onSkip}) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 6,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/imagen_skillwasp.jpeg', height: 30),
            const SizedBox(width: 8),
            Text(
              'SkillSwap',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryGreen,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        Text(stepText, style: const TextStyle(fontSize: 14, color: Colors.black54)),
        if (showSkip)
          TextButton(
            onPressed: onSkip,
            child: Text(_t('skip')),
          ),
      ],
    );
  }

  ButtonStyle _buttonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      elevation: 0,
    );
  }
}

class _SkillSwapAnimatedLoading extends StatefulWidget {
  final Color primaryGreen;
  final Color secondaryBlue;

  const _SkillSwapAnimatedLoading({
    required this.primaryGreen,
    required this.secondaryBlue,
  });

  @override
  State<_SkillSwapAnimatedLoading> createState() =>
      _SkillSwapAnimatedLoadingState();
}

class _SkillSwapAnimatedLoadingState extends State<_SkillSwapAnimatedLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const String fullText = "SkillSwap";
    // En bienvenida_perfil usamos el valor del controller para animar las letras
    // Aparecen en el primer 30% de la rotación para que no sea infinito
    int visibleChars = (_controller.value < 0.3) 
        ? ((_controller.value / 0.3) * fullText.length).ceil().clamp(0, fullText.length)
        : fullText.length;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          body: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Fondo solicitado
              Positioned.fill(
                child: Image.asset(
                  'assets/Fondo_SkillSwap.png',
                  fit: BoxFit.cover,
                ),
              ),

              // 2. Capa de oscurecimiento
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.5),
                      ],
                      radius: 1.2,
                    ),
                  ),
                ),
              ),

              // 3. Energía Swirl
              Positioned.fill(
                child: CustomPaint(
                  painter: EnergySwirlPainter(
                    _controller.value,
                    widget.primaryGreen,
                    widget.secondaryBlue,
                  ),
                ),
              ),

              // 4. Estrellas
              Positioned.fill(
                child: CustomPaint(
                  painter: StarParticlePainter(_controller.value),
                ),
              ),

              // 5. Logo en Cápsula + Barra de Progreso Inferior
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Cápsula superior
                      Transform.scale(
                        scale: 1 + 0.02 * (sin(_controller.value * 2 * pi)),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(60),
                            boxShadow: [
                              BoxShadow(
                                color: widget.primaryGreen.withOpacity(0.4),
                                blurRadius: 40,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/IconoSkillSwap.png',
                                width: 55,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.swap_calls,
                                  size: 50,
                                  color: widget.primaryGreen,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(visibleChars, (index) {
                                  String char = fullText[index];
                                  Color charColor = index < 5 
                                      ? widget.primaryGreen 
                                      : widget.secondaryBlue;
                                  
                                  return Text(
                                    char,
                                    style: TextStyle(
                                      color: charColor,
                                      fontSize: 40,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -1,
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Barra inferior persistente
                      const Column(
                        children: [
                          CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 4,
                          ),
                          SizedBox(height: 30),
                          Text(
                            '© 2026 SkillSwap. Todos los derechos reservados.',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class EnergySwirlPainter extends CustomPainter {
  final double progress;
  final Color color1;
  final Color color2;

  EnergySwirlPainter(this.progress, this.color1, this.color2);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.stroke;

    for (int i = 0; i < 5; i++) {
      final radius = (size.width * 0.35) + (i * 45);
      final rotation = progress * 2 * pi * (i.isEven ? 1 : -1);

      paint.strokeWidth = 3.0 + i;
      paint.shader = SweepGradient(
        colors: [
          color1.withOpacity(0.0),
          color1.withOpacity(0.7),
          color2.withOpacity(0.7),
          color1.withOpacity(0.0),
        ],
        stops: const [0.0, 0.4, 0.6, 1.0],
        transform: GradientRotation(rotation),
      ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawCircle(center, radius, paint);
    }

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color1.withOpacity(0.3),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: size.width * 1.0));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), glowPaint);
  }

  @override
  bool shouldRepaint(covariant EnergySwirlPainter oldDelegate) => true;
}

class StarParticlePainter extends CustomPainter {
  final double progress;
  StarParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(1234);
    final paint = Paint();

    for (int i = 0; i < 80; i++) {
      final x = ((random.nextDouble() * size.width) + (progress * 20)) % size.width;
      final y = ((random.nextDouble() * size.height) + (progress * 50)) % size.height;
      final radius = random.nextDouble() * 3.0;
      final opacity = (0.3 + 0.6 * (sin(progress * 6.28 + i))).clamp(0.0, 1.0);

      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant StarParticlePainter oldDelegate) => true;
}

