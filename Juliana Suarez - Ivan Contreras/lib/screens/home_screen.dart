import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../widgets/court_card.dart';
import '../widgets/category_item.dart';
import '../firestore_service.dart';

const List<Map<String, dynamic>> categories = [
  {'icon': Icons.sports_soccer, 'label': 'Fútbol'},
  {'icon': Icons.sports_tennis, 'label': 'Pádel'},
  {'icon': Icons.sports_baseball, 'label': 'Tenis'},
  {'icon': Icons.sports_basketball, 'label': 'Basket'},
];

const List<Court> courts = [
  Court(name: 'Fair Play', price: '50.000', rating: '4.3', category: 'Fútbol', accentColor: AppColors.green, sportIcon: Icons.sports_soccer, image: 'assets/images/futfairplay.png'),
  Court(name: 'La Academia', price: '45.000', rating: '4.5', category: 'Fútbol', accentColor: AppColors.green, sportIcon: Icons.sports_soccer, image: 'assets/images/futlaacademia.png'),
  Court(name: 'Complejo Deportivo Olé', price: '40.000', rating: '4.2', category: 'Fútbol', accentColor: AppColors.green, sportIcon: Icons.sports_soccer, image: 'assets/images/futole.png'),
  Court(name: 'Campo Deportivo La 12', price: '35.000', rating: '4.0', category: 'Fútbol', accentColor: AppColors.green, sportIcon: Icons.sports_soccer, image: 'assets/images/futcampo12.png'),
  Court(name: 'Canchas Wembley', price: '45.000', rating: '4.4', category: 'Fútbol', accentColor: AppColors.green, sportIcon: Icons.sports_soccer, image: 'assets/images/futwembley.png'),
  Court(name: 'Niza Club', price: '60.000', rating: '4.8', category: 'Pádel', accentColor: Color(0xFF4A90D9), sportIcon: Icons.sports_tennis, image: 'assets/images/padnizaclub.png'),
  Court(name: 'Club Cazadores', price: '70.000', rating: '4.7', category: 'Pádel', accentColor: Color(0xFF4A90D9), sportIcon: Icons.sports_tennis, image: 'assets/images/padclubcazadores.png'),
  Court(name: 'Pro Padel Club', price: '65.000', rating: '4.6', category: 'Pádel', accentColor: Color(0xFF4A90D9), sportIcon: Icons.sports_tennis, image: 'assets/images/padpropadel.png'),
  Court(name: 'Zenter Cúcuta', price: '60.000', rating: '4.5', category: 'Pádel', accentColor: Color(0xFF4A90D9), sportIcon: Icons.sports_tennis, image: 'assets/images/padzenter.png'),
  Court(name: 'North Padel Club', price: '55.000', rating: '4.4', category: 'Pádel', accentColor: Color(0xFF4A90D9), sportIcon: Icons.sports_tennis, image: 'assets/images/padnorthpadel.png'),
  Court(name: 'Club Cazadores Tenis', price: '45.000', rating: '4.9', category: 'Tenis', accentColor: Color(0xFFE8A838), sportIcon: Icons.sports_baseball, image: 'assets/images/tenclubcazadores.png'),
  Court(name: 'Tenis Golf Club', price: '50.000', rating: '4.7', category: 'Tenis', accentColor: Color(0xFFE8A838), sportIcon: Icons.sports_baseball, image: 'assets/images/tentenisgolf.png'),
  Court(name: 'Academia El Bosque', price: '40.000', rating: '4.5', category: 'Tenis', accentColor: Color(0xFFE8A838), sportIcon: Icons.sports_baseball, image: 'assets/images/tenacademiabosque.png'),
  Court(name: 'Complejo Fabiola Zuluaga', price: '45.000', rating: '4.8', category: 'Tenis', accentColor: Color(0xFFE8A838), sportIcon: Icons.sports_baseball, image: 'assets/images/tenfabiola.png'),
  Court(name: 'Hunters Club', price: '55.000', rating: '4.6', category: 'Tenis', accentColor: Color(0xFFE8A838), sportIcon: Icons.sports_baseball, image: 'assets/images/tenhunters.png'),
  Court(name: 'Coliseo Baloncesto', price: '35.000', rating: '4.6', category: 'Basket', accentColor: Color(0xFFE05C3A), sportIcon: Icons.sports_basketball, image: 'assets/images/bascoliseocucuta.png'),
  Court(name: 'Cañoneros de Cúcuta', price: '40.000', rating: '4.5', category: 'Basket', accentColor: Color(0xFFE05C3A), sportIcon: Icons.sports_basketball, image: 'assets/images/bascanoneros.png'),
  Court(name: 'Club Pasión Baloncesto', price: '30.000', rating: '4.3', category: 'Basket', accentColor: Color(0xFFE05C3A), sportIcon: Icons.sports_basketball, image: 'assets/images/baspasion.png'),
  Court(name: 'Coliseo Barrio El Contento', price: '25.000', rating: '4.1', category: 'Basket', accentColor: Color(0xFFE05C3A), sportIcon: Icons.sports_basketball, image: 'assets/images/bascontento.png'),
  Court(name: 'Coliseo Niña Ceci', price: '30.000', rating: '4.4', category: 'Basket', accentColor: Color(0xFFE05C3A), sportIcon: Icons.sports_basketball, image: 'assets/images/basninaceci.png'),
];

const List<Map<String, dynamic>> suggestions = [
  {'title': 'Fair Play', 'subtitle': 'La mejor cancha de fútbol en Cúcuta', 'image': 'assets/images/futfairplay.png', 'color': AppColors.green},
  {'title': 'Niza Club', 'subtitle': 'Pádel de alto nivel', 'image': 'assets/images/padnizaclub.png', 'color': Color(0xFF4A90D9)},
  {'title': 'Complejo Fabiola Zuluaga', 'subtitle': 'Canchas de tenis premium', 'image': 'assets/images/tenfabiola.png', 'color': Color(0xFFE8A838)},
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final PageController _pageController = PageController();
  int _currentSlide = 0;
  final FirestoreService _firestoreService = FirestoreService();

  String get _firstName {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? 'Jugador';
    return name.split(' ').first;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  List<Court> get _filteredCourts {
    final selectedLabel = categories[_selectedCategoryIndex]['label'];
    return courts.where((c) {
      final matchesCategory = c.category == selectedLabel;
      final matchesSearch = _searchQuery.isEmpty ||
          c.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  Future<void> _sendWhatsApp({
    required String courtName,
    required String hour,
    required String price,
    required String userName,
    required String cedula,
    required String phone,
  }) async {
    final message = Uri.encodeComponent(
      '🏟️ *NUEVA RESERVA - GameOn*\n\n'
      '📍 *Cancha:* $courtName\n'
      '⏰ *Hora:* $hour\n'
      '💰 *Precio:* $price\n'
      '👤 *Nombre:* $userName\n'
      '🪪 *Cédula:* $cedula\n'
      '📱 *Teléfono:* $phone\n\n'
      '✅ Reserva generada desde la app GameOn',
    );
    final url = Uri.parse('https://wa.me/573015832838?text=$message');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _showCourtDetails(BuildContext context, Court court) {
    String? selectedHour;
    Set<String> occupiedHours = {};
    bool loadingHours = true;

    final List<String> hours = [
      '6:00 AM', '7:00 AM', '8:00 AM', '9:00 AM',
      '10:00 AM', '2:00 PM', '3:00 PM', '4:00 PM',
      '5:00 PM', '6:00 PM', '7:00 PM', '8:00 PM',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Cargar horas ocupadas al abrir
            if (loadingHours) {
              loadingHours = false;
              _firestoreService.getOccupiedHours(court.name).then((hours) {
                setModalState(() => occupiedHours = hours);
              });
            }

            return DraggableScrollableSheet(
              initialChildSize: 0.85,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (_, controller) {
                return SingleChildScrollView(
                  controller: controller,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(court.image, width: double.infinity, height: 160, fit: BoxFit.cover),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: court.accentColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Icon(court.sportIcon, color: court.accentColor, size: 26)),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(court.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('\$${court.price}/h', style: TextStyle(color: court.accentColor, fontWeight: FontWeight.bold, fontSize: 15)),
                          ])),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                            child: Row(children: [const Icon(Icons.star_rounded, color: Colors.orange, size: 16), const SizedBox(width: 4), Text(court.rating, style: const TextStyle(fontWeight: FontWeight.bold))]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),
                      Row(children: [const Icon(Icons.schedule, color: AppColors.green, size: 20), const SizedBox(width: 8), const Text("Horarios", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))]),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.green.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                        child: Column(children: [
                          Row(children: [const Icon(Icons.circle, color: AppColors.green, size: 8), const SizedBox(width: 8), const Text('Lun - Vie: 6:00 AM - 10:00 PM', style: TextStyle(fontSize: 13))]),
                          const SizedBox(height: 6),
                          Row(children: [const Icon(Icons.circle, color: AppColors.green, size: 8), const SizedBox(width: 8), const Text('Sáb - Dom: 7:00 AM - 8:00 PM', style: TextStyle(fontSize: 13))]),
                        ]),
                      ),
                      const SizedBox(height: 16),
                      Row(children: [
                        const Icon(Icons.access_time, color: AppColors.green, size: 20),
                        const SizedBox(width: 8),
                        const Text("Selecciona una hora", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        // Leyenda
                        Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(3))),
                        const SizedBox(width: 4),
                        Text("Ocupada", style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                      ]),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: hours.map((hour) {
                          final isSelected = selectedHour == hour;
                          final isOccupied = occupiedHours.contains(hour);

                          return GestureDetector(
                            onTap: isOccupied ? null : () => setModalState(() => selectedHour = hour),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isOccupied
                                    ? Colors.grey[200]
                                    : isSelected
                                        ? AppColors.green
                                        : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isOccupied
                                      ? Colors.grey[300]!
                                      : isSelected
                                          ? AppColors.green
                                          : AppColors.green.withOpacity(0.4),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isOccupied)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: Icon(Icons.lock, size: 12, color: Colors.grey[400]),
                                    ),
                                  Text(
                                    hour,
                                    style: TextStyle(
                                      color: isOccupied
                                          ? Colors.grey[400]
                                          : isSelected
                                              ? Colors.white
                                              : AppColors.green,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      if (selectedHour != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: AppColors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.green.withOpacity(0.3))),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            const Icon(Icons.check_circle, color: AppColors.green, size: 18),
                            const SizedBox(width: 8),
                            Text("Hora seleccionada: $selectedHour", style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.bold)),
                          ]),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _showReservationForm(context, court.name, selectedHour!, '\$${court.price}/h', court.category);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(color: AppColors.green, borderRadius: BorderRadius.circular(14)),
                            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Icon(Icons.calendar_month, color: Colors.white, size: 22),
                              SizedBox(width: 10),
                              Text("Confirmar Reserva", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                            ]),
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
    );
  }

  void _showReservationForm(BuildContext context, String courtName, String hour, String price, String category) {
    final nameController = TextEditingController();
    final idController = TextEditingController();
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final rootContext = context;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (builderContext) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 100),
          padding: EdgeInsets.only(bottom: MediaQuery.of(builderContext).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 20),
                  const Text("Datos de la reserva", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("$courtName — $hour", style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 20),
                  _buildFormField(controller: nameController, label: "Nombre completo", icon: Icons.person_outline, validator: (v) => v!.isEmpty ? "Ingresa tu nombre" : null),
                  const SizedBox(height: 14),
                  _buildFormField(controller: idController, label: "Cédula", icon: Icons.badge_outlined, keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? "Ingresa tu cédula" : null),
                  const SizedBox(height: 14),
                  _buildFormField(controller: phoneController, label: "Teléfono", icon: Icons.phone_outlined, keyboardType: TextInputType.phone, validator: (v) => v!.isEmpty ? "Ingresa tu teléfono" : null),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () async {
                      if (formKey.currentState!.validate()) {
                        try {
                          await _firestoreService.saveReservation(
                            courtName: courtName,
                            hour: hour,
                            price: price,
                            category: category,
                            userName: nameController.text,
                            userCedula: idController.text,
                            userPhone: phoneController.text,
                          );
                          await _sendWhatsApp(
                            courtName: courtName,
                            hour: hour,
                            price: price,
                            userName: nameController.text,
                            cedula: idController.text,
                            phone: phoneController.text,
                          );
                          Navigator.pop(builderContext);
                          ScaffoldMessenger.of(rootContext).showSnackBar(
                            SnackBar(
                              content: Text('✅ Reserva confirmada en $courtName a las $hour'),
                              backgroundColor: AppColors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(rootContext).showSnackBar(
                            SnackBar(content: Text('❌ Error al reservar: $e'), backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(color: AppColors.green, borderRadius: BorderRadius.circular(14)),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Colors.white, size: 22),
                          SizedBox(width: 10),
                          Text("Reservar ahora", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormField({required TextEditingController controller, required String label, required IconData icon, TextInputType keyboardType = TextInputType.text, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.green),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.green, width: 2)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(200),
        child: _buildAppBar(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildCategoryRow(),
          const SizedBox(height: 16),
          _buildSlider(),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text("${_filteredCourts.length} canchas disponibles", style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildGrid()),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.only(top: 55, left: 20, right: 20, bottom: 20),
      decoration: const BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("¡Hola, $_firstName! 👋", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16)),
                const SizedBox(height: 4),
                const Text("Reserva tu cancha", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ]),
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.white, size: 30),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: const Row(children: [
                        Icon(Icons.notifications, color: AppColors.green),
                        SizedBox(width: 8),
                        Text("Notificaciones"),
                      ]),
                      content: const Text("No tienes notificaciones nuevas por el momento."),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cerrar", style: TextStyle(color: AppColors.green)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: "Buscar cancha en Cúcuta...",
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.close, color: Colors.grey, size: 20), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); })
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(categories.length, (i) {
        return CategoryItem(
          icon: categories[i]['icon'],
          label: categories[i]['label'],
          isSelected: i == _selectedCategoryIndex,
          onTap: () => setState(() => _selectedCategoryIndex = i),
        );
      }),
    );
  }

  Widget _buildSlider() {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            itemCount: suggestions.length,
            onPageChanged: (i) => setState(() => _currentSlide = i),
            itemBuilder: (_, i) {
              final s = suggestions[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(s['image'], fit: BoxFit.cover),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(s['title'], style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text(s['subtitle'], style: const TextStyle(color: Colors.white70, fontSize: 13)),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: AppColors.green, borderRadius: BorderRadius.circular(20)),
                              child: const Text("Ver cancha", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(suggestions.length, (i) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentSlide == i ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentSlide == i ? AppColors.green : Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildGrid() {
    final filteredCourts = _filteredCourts;
    if (filteredCourts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text("No hay canchas disponibles", style: TextStyle(color: Colors.grey[500], fontSize: 15)),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.82,
      ),
      itemCount: filteredCourts.length,
      itemBuilder: (_, i) => GestureDetector(
        onTap: () => _showCourtDetails(context, filteredCourts[i]),
        child: CourtCard(court: filteredCourts[i]),
      ),
    );
  }
}