import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';
import 'dart:convert';

// La pantalla de perfil real del usuario con animaciones y fondo.
// Lee y guarda los datos en la colección "usuarios" de Cloud Firestore,
// usando como ID el uid del usuario autenticado.
class ventana_perfil extends StatefulWidget {
  const ventana_perfil({super.key});

  @override
  State<ventana_perfil> createState() => _ventana_perfilState();
}

class _ventana_perfilState extends State<ventana_perfil>
    with SingleTickerProviderStateMixin {
  // Controladores de texto
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _acercaDeController = TextEditingController();
  final TextEditingController _habilidadesController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _rolController = TextEditingController();
  final TextEditingController _fechaNacController = TextEditingController();

  late TabController _tabController;
  bool _isEditing = false;

  // Paleta de colores
  final Color primaryGreen = const Color(0xFF6BCE7A);
  final Color secondaryTeal = const Color(0xFF00A99D);
  final Color darkText = const Color(0xFF334A5F);
  final Color lightGray = const Color(0xFFF5F7F9);
  final Color cardBg = const Color(0xFFFAFCFB);

  bool _isLoading = true;
  bool _isSaving = false;
  String _email = '';
  String _uid = '';
  String _idiomaPreferido = 'es';
  String? _photoUrl;
  String? _bannerUrl;
  File? _imageFile;

  List<Map<String, dynamic>> _experiencias = [];
  List<Map<String, dynamic>> _publicaciones = [];
  List<String> _areasAprendizaje = [];
  Map<String, String> _subareasPorArea = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _cargarPerfil();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _acercaDeController.dispose();
    _habilidadesController.dispose();
    _ubicacionController.dispose();
    _telefonoController.dispose();
    _rolController.dispose();
    _fechaNacController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // ─── Imagen de perfil ───────────────────────────────────────────────────────
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      final result = await FlutterImageCompress.compressWithFile(
        pickedFile.path,
        quality: 40,
        minWidth: 500,
        minHeight: 500,
      );
      if (result != null) {
        final base64String = base64Encode(result);
        setState(() {
          _imageFile = File(pickedFile.path);
          _photoUrl = base64String;
        });
        await _guardarFotoFirestore(base64String);
      }
    }
  }

  Future<void> _guardarFotoFirestore(String base64Image) async {
    if (_uid.isEmpty) return;
    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(_uid)
          .set({
        'photoUrl': base64Image,
        'fotoUrl': base64Image,
        'actualizadoEn': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (mounted) {
        _showSnack("Foto de perfil actualizada correctamente.", isError: false);
      }
    } catch (e) {
      debugPrint('Error al guardar foto: $e');
    }
  }

  Future<void> _pickBanner() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final result = await FlutterImageCompress.compressWithFile(
        pickedFile.path,
        quality: 35,
        minWidth: 800,
        minHeight: 400,
      );
      if (result != null) {
        setState(() => _bannerUrl = base64Encode(result));
      }
    }
  }

  // ─── Firestore: Cargar ───────────────────────────────────────────────────────
  Future<void> _cargarPerfil() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    _uid = user.uid;
    _email = user.email ?? '';
    final docRef =
        FirebaseFirestore.instance.collection('usuarios').doc(_uid);
    try {
      final snapshot = await docRef.get();
      if (snapshot.exists) {
        final data = snapshot.data() ?? <String, dynamic>{};
        _nombreController.text = (data['nombre'] ?? '').toString();
        _rolController.text = (data['rol'] ?? '').toString();
        _acercaDeController.text = (data['acercaDe'] ?? '').toString();
        _idiomaPreferido = (data['idiomaPreferido'] ?? 'es').toString();
        _areasAprendizaje =
            List<String>.from(data['areasAprendizaje'] ?? const []);
        final subareasData = data['subareasPorArea'];
        if (subareasData is Map) {
          _subareasPorArea = subareasData.map((key, value) {
            if (value is List) {
              return MapEntry(
                  key.toString(), value.map((i) => i.toString()).join(', '));
            }
            return MapEntry(key.toString(), value.toString());
          });
        }
        final habilidadesGuardadas = (data['habilidades'] ?? '').toString();
        _habilidadesController.text = habilidadesGuardadas.isNotEmpty
            ? habilidadesGuardadas
            : _subareasPorArea.values.join(', ');
        _ubicacionController.text = (data['ubicacion'] ?? '').toString();
        _telefonoController.text = (data['telefono'] ?? '').toString();
        _fechaNacController.text = (data['fechaNacimiento'] ?? '').toString();
        final f1 = data['photoUrl']?.toString() ?? '';
        final f2 = data['fotoUrl']?.toString() ?? '';
        _photoUrl = f1.isNotEmpty ? f1 : (f2.isNotEmpty ? f2 : null);
        _bannerUrl = data['bannerUrl'];
        _experiencias =
            List<Map<String, dynamic>>.from(data['experiencias'] ?? []);
        _publicaciones =
            List<Map<String, dynamic>>.from(data['publicaciones'] ?? []);
      } else {
        await docRef.set({
          'uid': _uid,
          'email': _email,
          'nombre': _email.split('@').first,
          'rol': 'Usuario SkillSwap',
          'acercaDe': '¡Hola! Estoy usando SkillSwap.',
          'idiomaPreferido': _idiomaPreferido,
          'areasAprendizaje': _areasAprendizaje,
          'subareasPorArea': _subareasPorArea,
          'habilidades': '',
          'ubicacion': '',
          'telefono': '',
          'fechaNacimiento': '',
          'photoUrl': '',
          'bannerUrl': '',
          'experiencias': [],
          'publicaciones': [],
          'creadoEn': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Firestore: Guardar ──────────────────────────────────────────────────────
  Future<void> _guardarPerfil() async {
    if (_uid.isEmpty) return;
    setState(() => _isSaving = true);
    try {
      Map<String, dynamic> datos = {
        'nombre': _nombreController.text.trim(),
        'rol': _rolController.text.trim(),
        'acercaDe': _acercaDeController.text.trim(),
        'idiomaPreferido': _idiomaPreferido,
        'areasAprendizaje': _areasAprendizaje,
        'subareasPorArea': _subareasPorArea,
        'habilidades': _habilidadesController.text.trim(),
        'ubicacion': _ubicacionController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'fechaNacimiento': _fechaNacController.text.trim(),
        'bannerUrl': _bannerUrl ?? '',
        'experiencias': _experiencias,
        'publicaciones': _publicaciones,
        'actualizadoEn': FieldValue.serverTimestamp(),
      };
      if (_photoUrl != null && _photoUrl!.isNotEmpty) {
        datos['photoUrl'] = _photoUrl;
        datos['fotoUrl'] = _photoUrl;
      }
      if (datos['habilidades'].toString().trim().isEmpty &&
          _subareasPorArea.isNotEmpty) {
        datos['habilidades'] = _subareasPorArea.values.join(', ');
      }
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(_uid)
          .set(datos, SetOptions(merge: true));
      setState(() => _isEditing = false);
      if (!mounted) return;
      _showSnack('¡Perfil actualizado con éxito!', isError: false);
    } catch (e) {
      debugPrint('Error: $e');
      _showSnack('Error al guardar. Intenta de nuevo.', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(msg)),
        ]),
        backgroundColor: isError ? Colors.redAccent : secondaryTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ─── Bottom Sheet de Formulario ──────────────────────────────────────────────
  void _mostrarFormulario({required bool esExperiencia, int? index}) {
    final tituloCtrl = TextEditingController(
        text: index != null
            ? (esExperiencia
                ? _experiencias[index]['titulo']
                : _publicaciones[index]['titulo'])
            : '');
    final segundoCtrl = TextEditingController(
        text: index != null
            ? (esExperiencia
                ? _experiencias[index]['entidad']
                : _publicaciones[index]['fecha'])
            : '');
    final descCtrl = TextEditingController(
        text: index != null
            ? (esExperiencia
                ? _experiencias[index]['descripcion']
                : _publicaciones[index]['descripcion'])
            : '');
    String? archivoBase64 = index != null
        ? (esExperiencia
            ? _experiencias[index]['archivo']
            : _publicaciones[index]['archivo'])
        : null;
    String? nombreArchivo = index != null
        ? (esExperiencia
            ? _experiencias[index]['archivoNombre']
            : _publicaciones[index]['archivoNombre'])
        : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              top: 24,
              left: 20,
              right: 20,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 30,
                  offset: const Offset(0, -6),
                )
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Título del formulario
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: secondaryTeal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          esExperiencia
                              ? Icons.work_outline_rounded
                              : Icons.article_outlined,
                          color: secondaryTeal,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        index == null
                            ? (esExperiencia
                                ? 'Nueva Experiencia'
                                : 'Nueva Publicación')
                            : (esExperiencia
                                ? 'Editar Experiencia'
                                : 'Editar Publicación'),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: darkText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Campo 1: Título / Cargo
                  _buildFormField(
                    controller: tituloCtrl,
                    label: esExperiencia ? 'Cargo o Título' : 'Título',
                    hint: esExperiencia
                        ? 'ej. Desarrollador Flutter Senior'
                        : 'ej. Introducción a Flutter',
                    icon: Icons.title_rounded,
                  ),
                  const SizedBox(height: 16),

                  // Campo 2: Empresa / Fecha-Enlace
                  _buildFormField(
                    controller: segundoCtrl,
                    label: esExperiencia ? 'Empresa / Lugar' : 'Fecha o Enlace',
                    hint: esExperiencia
                        ? 'ej. Google Inc. · 2022 – Presente'
                        : 'ej. 2024 · https://medium.com/...',
                    icon: esExperiencia
                        ? Icons.business_rounded
                        : Icons.link_rounded,
                  ),
                  const SizedBox(height: 16),

                  // Campo 3: Descripción
                  _buildFormField(
                    controller: descCtrl,
                    label: 'Descripción',
                    hint: esExperiencia
                        ? 'Describe tus responsabilidades y logros...'
                        : 'Describe el contenido de esta publicación...',
                    icon: Icons.notes_rounded,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 20),

                  // Adjuntar archivo
                  GestureDetector(
                    onTap: () async {
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles();
                      if (result != null) {
                        File file = File(result.files.single.path!);
                        setSheet(() {
                          nombreArchivo = result.files.single.name;
                          archivoBase64 =
                              base64Encode(file.readAsBytesSync());
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: nombreArchivo != null
                            ? primaryGreen.withOpacity(0.08)
                            : lightGray,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: nombreArchivo != null
                              ? primaryGreen.withOpacity(0.4)
                              : Colors.grey.shade200,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            nombreArchivo != null
                                ? Icons.check_circle_outline
                                : Icons.upload_file_rounded,
                            color: nombreArchivo != null
                                ? primaryGreen
                                : Colors.grey.shade500,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              nombreArchivo ?? 'Adjuntar documento o imagen',
                              style: TextStyle(
                                color: nombreArchivo != null
                                    ? darkText
                                    : Colors.grey.shade500,
                                fontSize: 14,
                                fontWeight: nombreArchivo != null
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (nombreArchivo != null)
                            GestureDetector(
                              onTap: () => setSheet(() {
                                archivoBase64 = null;
                                nombreArchivo = null;
                              }),
                              child: Icon(Icons.close,
                                  size: 18, color: Colors.grey.shade400),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Botones
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text('Cancelar',
                              style: TextStyle(
                                  color: darkText.withOpacity(0.6),
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            if (tituloCtrl.text.trim().isEmpty) {
                              _showSnack('El título no puede estar vacío.',
                                  isError: true);
                              return;
                            }
                            final nuevoItem = <String, dynamic>{
                              'titulo': tituloCtrl.text.trim(),
                              esExperiencia ? 'entidad' : 'fecha':
                                  segundoCtrl.text.trim(),
                              'descripcion': descCtrl.text.trim(),
                              'archivo': archivoBase64,
                              'archivoNombre': nombreArchivo,
                            };
                            setState(() {
                              if (index == null) {
                                esExperiencia
                                    ? _experiencias.add(nuevoItem)
                                    : _publicaciones.add(nuevoItem);
                              } else {
                                esExperiencia
                                    ? _experiencias[index] = nuevoItem
                                    : _publicaciones[index] = nuevoItem;
                              }
                            });
                            Navigator.pop(ctx);
                            _guardarPerfil();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: secondaryTeal,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            elevation: 4,
                            shadowColor: secondaryTeal.withOpacity(0.4),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save_rounded,
                                  color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text('Guardar',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: darkText.withOpacity(0.7))),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(color: darkText, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                TextStyle(color: Colors.grey.shade400, fontSize: 13),
            prefixIcon:
                Icon(icon, color: secondaryTeal.withOpacity(0.7), size: 20),
            filled: true,
            fillColor: lightGray,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: secondaryTeal, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // ─── BUILD ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final nombreParaAvatar = _nombreController.text.trim().isEmpty
        ? (_email.isEmpty ? 'User' : _email.split('@').first)
        : _nombreController.text.trim();

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.08), blurRadius: 8)
              ],
            ),
            child: Icon(Icons.arrow_back_ios_new, color: darkText, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08), blurRadius: 8)
                ],
              ),
              child:
                  const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
            ),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                title: const Text('Eliminar Perfil'),
                content: const Text(
                    '¿Estás seguro de que deseas eliminar tu perfil? Esta acción no se puede deshacer.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar')),
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Eliminar',
                          style: TextStyle(color: Colors.red))),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryGreen))
          : Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/Fondo_SkillSwap.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeaderModerno(nombreParaAvatar)
                          .animate()
                          .fadeIn(duration: 600.ms)
                          .slideY(begin: 0.15, end: 0),
                      const SizedBox(height: 8),
                      _buildTabBar().animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 20),
                      _buildTabContent(),
                      const SizedBox(height: 20),
                      _buildBotonesAccion()
                          .animate()
                          .fadeIn(delay: 400.ms)
                          .scale(delay: 400.ms),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // ─── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeaderModerno(String nombre) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar con borde degradado
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                            colors: [primaryGreen, secondaryTeal]),
                      ),
                      padding: const EdgeInsets.all(3),
                      child: Container(
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white),
                        padding: const EdgeInsets.all(2),
                        child: ClipOval(
                          child: _imageFile != null
                              ? Image.file(_imageFile!, fit: BoxFit.cover)
                              : (_photoUrl != null && _photoUrl!.isNotEmpty
                                  ? (_photoUrl!.startsWith('http')
                                      ? Image.network(_photoUrl!,
                                          fit: BoxFit.cover)
                                      : Builder(builder: (context) {
                                          try {
                                            String base64Data = _photoUrl!;
                                            if (base64Data.contains(',')) {
                                              base64Data = base64Data
                                                  .split(',')
                                                  .last;
                                            }
                                            return Image.memory(
                                                base64Decode(base64Data),
                                                fit: BoxFit.cover);
                                          } catch (_) {
                                            return _avatarPlaceholder(nombre);
                                          }
                                        }))
                                  : _avatarPlaceholder(nombre)),
                        ),
                      ),
                    ),
                    // Ícono de cámara
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: secondaryTeal,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt,
                            color: Colors.white, size: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _nombreController,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: darkText),
                      decoration: InputDecoration(
                        hintText: 'Tu nombre',
                        hintStyle: TextStyle(
                            color: darkText.withOpacity(0.3), fontSize: 20),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: 2),
                    TextField(
                      controller: _rolController,
                      style: TextStyle(
                          fontSize: 13,
                          color: darkText.withOpacity(0.55),
                          fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: 'Tu profesión o rol',
                        hintStyle: TextStyle(
                            color: darkText.withOpacity(0.3), fontSize: 13),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Info mini
          Wrap(
            spacing: 18,
            runSpacing: 6,
            children: [
              _buildInfoMini(Icons.location_on_outlined,
                  _ubicacionController.text.isEmpty
                      ? 'Sin ubicación'
                      : _ubicacionController.text),
              _buildInfoMini(Icons.link, 'tuportfolio.com'),
              _buildInfoMini(
                  Icons.calendar_today_outlined, 'Miembro desde 2024'),
            ],
          ),
          const SizedBox(height: 14),
          // Estadísticas
          Row(
            children: [
              _buildStatBadge('1,234', 'Conexiones'),
              const SizedBox(width: 24),
              _buildStatBadge('567', 'Seguidores'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _avatarPlaceholder(String nombre) {
    return Container(
      color: primaryGreen.withOpacity(0.15),
      alignment: Alignment.center,
      child: Text(
        nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U',
        style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: secondaryTeal),
      ),
    );
  }

  Widget _buildInfoMini(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: darkText.withOpacity(0.4)),
        const SizedBox(width: 4),
        Text(text,
            style: TextStyle(fontSize: 12, color: darkText.withOpacity(0.55))),
      ],
    );
  }

  Widget _buildStatBadge(String value, String label) {
    return Row(
      children: [
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: darkText,
                fontSize: 15)),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                color: darkText.withOpacity(0.55), fontSize: 13)),
      ],
    );
  }

  // ─── TabBar ──────────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: lightGray,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: darkText.withOpacity(0.5),
        indicator: BoxDecoration(
          gradient:
              LinearGradient(colors: [primaryGreen, secondaryTeal]),
          borderRadius: BorderRadius.circular(14),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        padding: const EdgeInsets.all(4),
        labelStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        tabs: const [
          Tab(text: 'Acerca de'),
          Tab(text: 'Experiencia'),
          Tab(text: 'Publicaciones'),
        ],
      ),
    );
  }

  // ─── TabContent ──────────────────────────────────────────────────────────────
  Widget _buildTabContent() {
    return [
      _buildAcercaDeTab(),
      _buildExperienciaTab(),
      _buildPublicacionesTab(),
    ][_tabController.index];
  }

  // ─── Tab: Acerca de ──────────────────────────────────────────────────────────
  Widget _buildAcercaDeTab() {
    List<String> skills = _habilidadesController.text
        .split(',')
        .where((s) => s.trim().isNotEmpty)
        .toList();
    if (skills.isEmpty) skills = ['Flutter', 'Dart', 'Firebase'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildEditCard(
            title: 'Sobre mí',
            icon: Icons.person_outline_rounded,
            child: TextField(
              controller: _acercaDeController,
              maxLines: null,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Escribe algo sobre ti...',
                hintStyle: TextStyle(
                    color: darkText.withOpacity(0.3), fontSize: 14),
              ),
              style: TextStyle(
                  height: 1.6, color: darkText.withOpacity(0.8), fontSize: 14),
            ),
          ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.08, end: 0),
          const SizedBox(height: 16),
          _buildEditCard(
            title: 'Habilidades',
            icon: Icons.workspace_premium_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _habilidadesController,
                  decoration: InputDecoration(
                    hintText: 'Agrega habilidades separadas por coma',
                    hintStyle: TextStyle(
                        fontSize: 12, color: darkText.withOpacity(0.3)),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() {}),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: skills.asMap().entries.map((entry) {
                    return _buildSkillChip(entry.value.trim())
                        .animate()
                        .fadeIn(delay: (300 + (entry.key * 80)).ms)
                        .scale();
                  }).toList(),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.08, end: 0),
          const SizedBox(height: 16),
          _buildEditCard(
            title: 'Datos de contacto',
            icon: Icons.contact_phone_outlined,
            child: Column(
              children: [
                _buildSimpleField(
                    Icons.phone, 'Teléfono', _telefonoController),
                _buildSimpleField(
                    Icons.location_on, 'Ubicación', _ubicacionController),
                _buildSimpleField(
                    Icons.cake_outlined, 'Fecha de Nacimiento', _fechaNacController),
              ],
            ),
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.08, end: 0),
        ],
      ),
    );
  }

  // ─── Tab: Experiencia ────────────────────────────────────────────────────────
  Widget _buildExperienciaTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Botón principal para agregar
          _buildAddButton(
            label: 'Agregar Experiencia',
            icon: Icons.add_business_outlined,
            onTap: () => _mostrarFormulario(esExperiencia: true),
          ),
          const SizedBox(height: 20),

          // Lista vacía
          if (_experiencias.isEmpty)
            _buildEmptyState(
              icon: Icons.work_history_outlined,
              message: 'No tienes experiencias añadidas aún.',
              subMessage: 'Toca el botón de arriba para agregar tu primera experiencia laboral.',
            )
          else
            ..._experiencias.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildItemCard(
                title: item['titulo'] ?? '',
                subtitle: item['entidad'] ?? '',
                description: item['descripcion'] ?? '',
                archivo: item['archivoNombre'],
                onEdit: () =>
                    _mostrarFormulario(esExperiencia: true, index: index),
                onDelete: () {
                  setState(() => _experiencias.removeAt(index));
                  _guardarPerfil();
                },
                iconData: Icons.work_outline_rounded,
                accentColor: secondaryTeal,
              ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1, end: 0);
            }),
        ],
      ),
    );
  }

  // ─── Tab: Publicaciones ──────────────────────────────────────────────────────
  Widget _buildPublicacionesTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildAddButton(
            label: 'Nueva Publicación',
            icon: Icons.post_add_rounded,
            onTap: () => _mostrarFormulario(esExperiencia: false),
          ),
          const SizedBox(height: 20),

          if (_publicaciones.isEmpty)
            _buildEmptyState(
              icon: Icons.article_outlined,
              message: 'Aún no tienes publicaciones.',
              subMessage: 'Comparte tu conocimiento añadiendo artículos, proyectos o recursos.',
            )
          else
            ..._publicaciones.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildItemCard(
                title: item['titulo'] ?? '',
                subtitle: item['fecha'] ?? '',
                description: item['descripcion'] ?? '',
                archivo: item['archivoNombre'],
                onEdit: () =>
                    _mostrarFormulario(esExperiencia: false, index: index),
                onDelete: () {
                  setState(() => _publicaciones.removeAt(index));
                  _guardarPerfil();
                },
                iconData: Icons.article_outlined,
                accentColor: primaryGreen,
              ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1, end: 0);
            }),
        ],
      ),
    );
  }

  Widget _buildAddButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: secondaryTeal.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryTeal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required String subMessage,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: darkText.withOpacity(0.6)),
          ),
          const SizedBox(height: 6),
          Text(
            subMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12,
                color: darkText.withOpacity(0.4),
                height: 1.5),
          ),
        ],
      ),
    );
  }

  // ─── Card de ítem ────────────────────────────────────────────────────────────
  Widget _buildItemCard({
    required String title,
    required String subtitle,
    required String description,
    String? archivo,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    required IconData iconData,
    required Color accentColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con degradado sutil
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accentColor.withOpacity(0.08), Colors.white],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: accentColor.withOpacity(0.2), blurRadius: 8)
                      ],
                    ),
                    child: Icon(iconData, color: accentColor, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: darkText,
                                letterSpacing: -0.2)),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(subtitle,
                              style: TextStyle(
                                  color: accentColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 0.3)),
                        ],
                      ],
                    ),
                  ),
                  // Acciones en burbujas pequeñas
                  _smallActionButton(
                      Icons.edit_note_rounded, Colors.blue.shade400, onEdit),
                  const SizedBox(width: 8),
                  _smallActionButton(
                      Icons.delete_sweep_outlined, Colors.red.shade400, onDelete),
                ],
              ),
            ),
            if (description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                child: Text(
                  description,
                  style: TextStyle(
                      color: darkText.withOpacity(0.65),
                      fontSize: 14,
                      height: 1.5),
                ),
              ),
            if (archivo != null)
              Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: lightGray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.description_outlined,
                        size: 16, color: accentColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        archivo,
                        style: TextStyle(
                            fontSize: 12,
                            color: darkText.withOpacity(0.7),
                            fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _smallActionButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  // ─── Botones de acción (pie de página) ───────────────────────────────────────
  Widget _buildBotonesAccion() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildBotonLlamativo(
              label: 'AGREGAR',
              icon: Icons.add_circle_outline,
              color: secondaryTeal,
              onPressed: () {
                final tab = _tabController.index;
                if (tab == 1) {
                  _mostrarFormulario(esExperiencia: true);
                } else if (tab == 2) {
                  _mostrarFormulario(esExperiencia: false);
                } else {
                  _showSnack(
                      'Cambia a Experiencia o Publicaciones para agregar.',
                      isError: false);
                }
              },
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _buildBotonLlamativo(
              label: _isSaving ? 'GUARDANDO...' : 'GUARDAR',
              icon: _isSaving ? Icons.hourglass_empty : Icons.save_rounded,
              color: primaryGreen,
              onPressed: _isSaving ? null : _guardarPerfil,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonLlamativo({
    required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white, size: 18),
      label: Text(label,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: Colors.white,
              fontSize: 13)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        disabledBackgroundColor: color.withOpacity(0.5),
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        shadowColor: color.withOpacity(0.4),
      ),
    );
  }

  // ─── Componentes reutilizables ───────────────────────────────────────────────
  Widget _buildEditCard({
    required String title,
    required Widget child,
    IconData? icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: secondaryTeal),
                const SizedBox(width: 8),
              ],
              Text(title,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: darkText)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildSkillChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: primaryGreen.withOpacity(0.2), width: 1),
      ),
      child: Text(label,
          style: TextStyle(
              color: secondaryTeal,
              fontWeight: FontWeight.w600,
              fontSize: 12)),
    );
  }

  Widget _buildSimpleField(
      IconData icon, String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 18, color: primaryGreen),
          labelText: label,
          labelStyle: TextStyle(
              fontSize: 12, color: darkText.withOpacity(0.45)),
          border: InputBorder.none,
          isDense: true,
        ),
        style: TextStyle(fontSize: 14, color: darkText),
      ),
    );
  }

  // ─── Helpers de fondo (retrocompatibilidad con otros widgets) ─────────────────
  BoxDecoration _fondoSkillSwapDecoration({double radius = 20}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      image: const DecorationImage(
        image: AssetImage('assets/Fondo_SkillSwap.png'),
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildFondoOverlay({
    required Widget child,
    double radius = 20,
    double overlayOpacity = 0.88,
  }) {
    return Container(
      decoration: _fondoSkillSwapDecoration(radius: radius),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(overlayOpacity),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: Colors.white.withOpacity(0.4)),
        ),
        child: child,
      ),
    );
  }
}  