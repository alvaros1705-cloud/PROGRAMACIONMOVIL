import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../firestore_service.dart';

class CourtLocation {
  final String name;
  final String category;
  final IconData icon;
  final Color color;
  final String distance;
  final String price;
  final String description;
  final int capacity;
  final String mapsUrl;
  final String scheduleWeekday;
  final String scheduleWeekend;
  final List<String> availableHours;

  const CourtLocation({
    required this.name,
    required this.category,
    required this.icon,
    required this.color,
    required this.distance,
    required this.price,
    required this.description,
    required this.capacity,
    required this.mapsUrl,
    required this.scheduleWeekday,
    required this.scheduleWeekend,
    required this.availableHours,
  });
}

const List<CourtLocation> courtLocations = [
  CourtLocation(name: 'Fair Play', category: 'Fútbol', icon: Icons.sports_soccer, color: AppColors.green, distance: '1.2 km', price: '\$50.000/h', description: 'Cancha de fútbol sintética de alto rendimiento con iluminación nocturna.', capacity: 14, mapsUrl: 'https://maps.app.goo.gl/cy3wt4FnRYiVFR8t8', scheduleWeekday: 'Lun - Vie: 6:00 AM - 10:00 PM', scheduleWeekend: 'Sáb - Dom: 7:00 AM - 8:00 PM', availableHours: ['6:00 AM', '7:00 AM', '9:00 AM', '2:00 PM', '4:00 PM', '7:00 PM']),
  CourtLocation(name: 'La Academia', category: 'Fútbol', icon: Icons.sports_soccer, color: AppColors.green, distance: '2.5 km', price: '\$45.000/h', description: 'Escenario deportivo ideal para entrenamientos y partidos amistosos.', capacity: 14, mapsUrl: 'https://maps.app.goo.gl/5Ymac4qaW1i9yBoZ8', scheduleWeekday: 'Lun - Vie: 6:00 AM - 10:00 PM', scheduleWeekend: 'Sáb - Dom: 7:00 AM - 9:00 PM', availableHours: ['6:00 AM', '8:00 AM', '10:00 AM', '3:00 PM', '6:00 PM']),
  CourtLocation(name: 'Complejo Deportivo Olé', category: 'Fútbol', icon: Icons.sports_soccer, color: AppColors.green, distance: '3.0 km', price: '\$40.000/h', description: 'Complejo deportivo con múltiples canchas de fútbol y zonas de descanso.', capacity: 14, mapsUrl: 'https://maps.app.goo.gl/U5UyLgykgKB9cqzY8', scheduleWeekday: 'Lun - Vie: 7:00 AM - 9:00 PM', scheduleWeekend: 'Sáb - Dom: 7:00 AM - 8:00 PM', availableHours: ['7:00 AM', '9:00 AM', '11:00 AM', '3:00 PM', '5:00 PM']),
  CourtLocation(name: 'Campo Deportivo La 12', category: 'Fútbol', icon: Icons.sports_soccer, color: AppColors.green, distance: '1.8 km', price: '\$35.000/h', description: 'Cancha de fútbol en excelente ubicación con fácil acceso.', capacity: 14, mapsUrl: 'https://maps.app.goo.gl/gYjfwefQsfh73hKa8', scheduleWeekday: 'Lun - Vie: 6:00 AM - 10:00 PM', scheduleWeekend: 'Sáb - Dom: 8:00 AM - 8:00 PM', availableHours: ['6:00 AM', '8:00 AM', '2:00 PM', '5:00 PM', '8:00 PM']),
  CourtLocation(name: 'Canchas Wembley', category: 'Fútbol', icon: Icons.sports_soccer, color: AppColors.green, distance: '2.2 km', price: '\$45.000/h', description: 'Canchas de fútbol de alta calidad inspiradas en el famoso estadio.', capacity: 14, mapsUrl: 'https://maps.app.goo.gl/ibLZXJKozdg2XJrv6', scheduleWeekday: 'Lun - Vie: 6:00 AM - 10:00 PM', scheduleWeekend: 'Sáb - Dom: 7:00 AM - 9:00 PM', availableHours: ['6:00 AM', '7:00 AM', '10:00 AM', '4:00 PM', '7:00 PM']),
  CourtLocation(name: 'Niza Club', category: 'Pádel', icon: Icons.sports_tennis, color: Color(0xFF4A90D9), distance: '0.8 km', price: '\$60.000/h', description: 'Club de pádel con canchas profesionales y ambiente premium.', capacity: 4, mapsUrl: 'https://maps.app.goo.gl/q2FqBnTtRUaSxYQdA', scheduleWeekday: 'Lun - Vie: 7:00 AM - 9:00 PM', scheduleWeekend: 'Sáb - Dom: 8:00 AM - 7:00 PM', availableHours: ['7:00 AM', '9:00 AM', '11:00 AM', '3:00 PM', '5:00 PM']),
  CourtLocation(name: 'Club Cazadores Pádel', category: 'Pádel', icon: Icons.sports_tennis, color: Color(0xFF4A90D9), distance: '3.1 km', price: '\$70.000/h', description: 'Canchas de pádel en excelentes condiciones con vestidores.', capacity: 4, mapsUrl: 'https://maps.app.goo.gl/9TE25V4WWd2EnfXK6', scheduleWeekday: 'Lun - Vie: 6:00 AM - 10:00 PM', scheduleWeekend: 'Sáb - Dom: 7:00 AM - 8:00 PM', availableHours: ['6:00 AM', '8:00 AM', '1:00 PM', '4:00 PM', '7:00 PM']),
  CourtLocation(name: 'Pro Padel Club', category: 'Pádel', icon: Icons.sports_tennis, color: Color(0xFF4A90D9), distance: '2.0 km', price: '\$65.000/h', description: 'Club profesional de pádel con entrenadores certificados.', capacity: 4, mapsUrl: 'https://maps.app.goo.gl/abB2ErW3stynvkU67', scheduleWeekday: 'Lun - Vie: 7:00 AM - 10:00 PM', scheduleWeekend: 'Sáb - Dom: 8:00 AM - 8:00 PM', availableHours: ['7:00 AM', '9:00 AM', '12:00 PM', '3:00 PM', '6:00 PM']),
  CourtLocation(name: 'Zenter Cúcuta', category: 'Pádel', icon: Icons.sports_tennis, color: Color(0xFF4A90D9), distance: '1.5 km', price: '\$60.000/h', description: 'Centro deportivo moderno con canchas de pádel de primer nivel.', capacity: 4, mapsUrl: 'https://maps.app.goo.gl/tsXVBgjFmkAh7zQn7', scheduleWeekday: 'Lun - Vie: 6:00 AM - 10:00 PM', scheduleWeekend: 'Sáb - Dom: 7:00 AM - 9:00 PM', availableHours: ['6:00 AM', '8:00 AM', '10:00 AM', '2:00 PM', '5:00 PM']),
  CourtLocation(name: 'North Padel Club', category: 'Pádel', icon: Icons.sports_tennis, color: Color(0xFF4A90D9), distance: '4.0 km', price: '\$55.000/h', description: 'Club de pádel en el norte de Cúcuta con excelentes instalaciones.', capacity: 4, mapsUrl: 'https://maps.app.goo.gl/77u6xMaX639x62iPA', scheduleWeekday: 'Lun - Vie: 7:00 AM - 9:00 PM', scheduleWeekend: 'Sáb - Dom: 8:00 AM - 7:00 PM', availableHours: ['7:00 AM', '9:00 AM', '11:00 AM', '4:00 PM', '6:00 PM']),
  CourtLocation(name: 'Club Cazadores Tenis', category: 'Tenis', icon: Icons.sports_baseball, color: Color(0xFFE8A838), distance: '3.1 km', price: '\$45.000/h', description: 'Canchas de tenis en arcilla con iluminación para juego nocturno.', capacity: 4, mapsUrl: 'https://maps.app.goo.gl/9TE25V4WWd2EnfXK6', scheduleWeekday: 'Lun - Vie: 7:00 AM - 9:00 PM', scheduleWeekend: 'Sáb - Dom: 8:00 AM - 6:00 PM', availableHours: ['7:00 AM', '10:00 AM', '2:00 PM', '5:00 PM']),
  CourtLocation(name: 'Tenis Golf Club', category: 'Tenis', icon: Icons.sports_baseball, color: Color(0xFFE8A838), distance: '2.8 km', price: '\$50.000/h', description: 'Canchas de tenis de alta calidad con ambiente exclusivo.', capacity: 4, mapsUrl: 'https://maps.app.goo.gl/kyxBRZQMpqabucua7', scheduleWeekday: 'Lun - Vie: 7:00 AM - 9:00 PM', scheduleWeekend: 'Sáb - Dom: 8:00 AM - 7:00 PM', availableHours: ['7:00 AM', '9:00 AM', '11:00 AM', '3:00 PM', '6:00 PM']),
  CourtLocation(name: 'Academia El Bosque', category: 'Tenis', icon: Icons.sports_baseball, color: Color(0xFFE8A838), distance: '3.5 km', price: '\$40.000/h', description: 'Academia de tenis con programas para todas las edades.', capacity: 4, mapsUrl: 'https://maps.app.goo.gl/xk7UPiKWgEg1iFHk8', scheduleWeekday: 'Lun - Vie: 6:00 AM - 9:00 PM', scheduleWeekend: 'Sáb - Dom: 7:00 AM - 6:00 PM', availableHours: ['6:00 AM', '8:00 AM', '10:00 AM', '4:00 PM', '6:00 PM']),
  CourtLocation(name: 'Complejo Fabiola Zuluaga', category: 'Tenis', icon: Icons.sports_baseball, color: Color(0xFFE8A838), distance: '2.0 km', price: '\$45.000/h', description: 'Complejo deportivo en honor a la tenista colombiana Fabiola Zuluaga.', capacity: 4, mapsUrl: 'https://maps.app.goo.gl/vUDw2HXaGq9ViQ8b7', scheduleWeekday: 'Lun - Vie: 7:00 AM - 10:00 PM', scheduleWeekend: 'Sáb - Dom: 8:00 AM - 8:00 PM', availableHours: ['7:00 AM', '9:00 AM', '12:00 PM', '3:00 PM', '7:00 PM']),
  CourtLocation(name: 'Hunters Club', category: 'Tenis', icon: Icons.sports_baseball, color: Color(0xFFE8A838), distance: '4.5 km', price: '\$55.000/h', description: 'Club exclusivo con canchas de tenis y servicios premium.', capacity: 4, mapsUrl: 'https://maps.app.goo.gl/DpL2P5HrsWVdEimB7', scheduleWeekday: 'Lun - Vie: 7:00 AM - 9:00 PM', scheduleWeekend: 'Sáb - Dom: 8:00 AM - 7:00 PM', availableHours: ['7:00 AM', '10:00 AM', '1:00 PM', '4:00 PM', '6:00 PM']),
  CourtLocation(name: 'Coliseo Baloncesto', category: 'Basket', icon: Icons.sports_basketball, color: Color(0xFFE05C3A), distance: '4.0 km', price: '\$35.000/h', description: 'Coliseo cubierto con cancha reglamentaria de baloncesto.', capacity: 10, mapsUrl: 'https://maps.app.goo.gl/D4u8TbMrjiHDcDwn6', scheduleWeekday: 'Lun - Vie: 8:00 AM - 8:00 PM', scheduleWeekend: 'Sáb - Dom: 9:00 AM - 6:00 PM', availableHours: ['8:00 AM', '10:00 AM', '12:00 PM', '4:00 PM', '6:00 PM']),
  CourtLocation(name: 'Cañoneros de Cúcuta', category: 'Basket', icon: Icons.sports_basketball, color: Color(0xFFE05C3A), distance: '2.5 km', price: '\$40.000/h', description: 'Cancha del equipo profesional de baloncesto de Cúcuta.', capacity: 10, mapsUrl: 'https://maps.app.goo.gl/3ZjzU1iHJuxRo2sR7', scheduleWeekday: 'Lun - Vie: 7:00 AM - 9:00 PM', scheduleWeekend: 'Sáb - Dom: 8:00 AM - 7:00 PM', availableHours: ['7:00 AM', '9:00 AM', '11:00 AM', '3:00 PM', '6:00 PM']),
  CourtLocation(name: 'Club Pasión Baloncesto', category: 'Basket', icon: Icons.sports_basketball, color: Color(0xFFE05C3A), distance: '3.0 km', price: '\$30.000/h', description: 'Club deportivo con cancha de baloncesto y ambiente familiar.', capacity: 10, mapsUrl: 'https://maps.app.goo.gl/5RcQyaULFbEMs3Qc9', scheduleWeekday: 'Lun - Vie: 8:00 AM - 8:00 PM', scheduleWeekend: 'Sáb - Dom: 9:00 AM - 6:00 PM', availableHours: ['8:00 AM', '10:00 AM', '2:00 PM', '5:00 PM']),
  CourtLocation(name: 'Coliseo Barrio El Contento', category: 'Basket', icon: Icons.sports_basketball, color: Color(0xFFE05C3A), distance: '1.5 km', price: '\$25.000/h', description: 'Coliseo comunitario con cancha de baloncesto techada.', capacity: 10, mapsUrl: 'https://maps.app.goo.gl/b3buxr4iwfrHaJyh6', scheduleWeekday: 'Lun - Vie: 8:00 AM - 8:00 PM', scheduleWeekend: 'Sáb - Dom: 9:00 AM - 5:00 PM', availableHours: ['8:00 AM', '10:00 AM', '12:00 PM', '4:00 PM']),
  CourtLocation(name: 'Coliseo Niña Ceci', category: 'Basket', icon: Icons.sports_basketball, color: Color(0xFFE05C3A), distance: '2.0 km', price: '\$30.000/h', description: 'Coliseo deportivo con excelente iluminación y cancha reglamentaria.', capacity: 10, mapsUrl: 'https://maps.app.goo.gl/NhjE1L73QiubXYwD8', scheduleWeekday: 'Lun - Vie: 7:00 AM - 9:00 PM', scheduleWeekend: 'Sáb - Dom: 8:00 AM - 6:00 PM', availableHours: ['7:00 AM', '9:00 AM', '11:00 AM', '3:00 PM', '5:00 PM']),
];

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String _selectedCategory = 'Todos';
  final List<String> _categories = ['Todos', 'Fútbol', 'Pádel', 'Tenis', 'Basket'];
  final FirestoreService _firestoreService = FirestoreService();

  List<CourtLocation> get _filteredCourts {
    if (_selectedCategory == 'Todos') return courtLocations;
    return courtLocations.where((c) => c.category == _selectedCategory).toList();
  }

  Future<void> _openMaps(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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

  void _showCourtDetails(BuildContext context, CourtLocation court) {
    String? selectedHour;
    Set<String> occupiedHours = {};
    bool loadingHours = true;
    final rootContext = context;

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
                      Row(
                        children: [
                          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: court.color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Icon(court.icon, color: court.color, size: 30)),
                          const SizedBox(width: 14),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(court.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(court.category, style: TextStyle(color: court.color, fontWeight: FontWeight.w500)),
                          ])),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),
                      _buildDetailRow(Icons.description_outlined, "Descripción", court.description),
                      const SizedBox(height: 10),
                      _buildDetailRow(Icons.attach_money, "Precio", court.price),
                      const SizedBox(height: 10),
                      _buildDetailRow(Icons.people_outline, "Capacidad", "${court.capacity} jugadores"),
                      const SizedBox(height: 10),
                      _buildDetailRow(Icons.location_on_outlined, "Distancia", court.distance),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),
                      Row(children: [const Icon(Icons.schedule, color: AppColors.green, size: 20), const SizedBox(width: 8), const Text("Horarios", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))]),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.green.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                        child: Column(children: [
                          Row(children: [const Icon(Icons.circle, color: AppColors.green, size: 8), const SizedBox(width: 8), Text(court.scheduleWeekday, style: const TextStyle(fontSize: 13))]),
                          const SizedBox(height: 6),
                          Row(children: [const Icon(Icons.circle, color: AppColors.green, size: 8), const SizedBox(width: 8), Text(court.scheduleWeekend, style: const TextStyle(fontSize: 13))]),
                        ]),
                      ),
                      const SizedBox(height: 16),
                      Row(children: [
                        const Icon(Icons.access_time, color: AppColors.green, size: 20),
                        const SizedBox(width: 8),
                        const Text("Selecciona una hora", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(3))),
                        const SizedBox(width: 4),
                        Text("Ocupada", style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                      ]),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: court.availableHours.map((hour) {
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
                            _showReservationForm(rootContext, court.name, selectedHour!, court.price, court.category);
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
                        const SizedBox(height: 12),
                      ],
                      GestureDetector(
                        onTap: () => _openMaps(court.mapsUrl),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.green.withOpacity(0.4))),
                          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.map_rounded, color: AppColors.green, size: 22),
                            SizedBox(width: 10),
                            Text("Ver en Google Maps", style: TextStyle(color: AppColors.green, fontSize: 15, fontWeight: FontWeight.bold)),
                          ]),
                        ),
                      ),
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
                            SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.green, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ])),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Container(
          padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 18),
          decoration: const BoxDecoration(
            color: AppColors.green,
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
          ),
          child: const Row(
            children: [
              Icon(Icons.map_rounded, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text("Canchas cercanas", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text("Cúcuta, Norte de Santander", style: TextStyle(color: Colors.white70, fontSize: 12)),
              ]),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (_, i) {
                final isSelected = _categories[i] == _selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = _categories[i]),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.green : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
                    ),
                    child: Text(_categories[i], style: TextStyle(color: isSelected ? Colors.white : Colors.grey[700], fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, fontSize: 13)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.green, size: 16),
                const SizedBox(width: 4),
                Text("${_filteredCourts.length} canchas — toca para ver detalles", style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredCourts.length,
              itemBuilder: (_, i) {
                final court = _filteredCourts[i];
                return GestureDetector(
                  onTap: () => _showCourtDetails(context, court),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      children: [
                        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: court.color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Icon(court.icon, color: court.color, size: 28)),
                        const SizedBox(width: 14),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(court.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(court.price, style: TextStyle(color: court.color, fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 2),
                          Row(children: [const Icon(Icons.schedule, color: Colors.grey, size: 13), const SizedBox(width: 3), Text(court.scheduleWeekday, style: TextStyle(color: Colors.grey[600], fontSize: 11))]),
                        ])),
                        Column(children: [
                          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Text(court.distance, style: const TextStyle(color: AppColors.green, fontSize: 12, fontWeight: FontWeight.bold))),
                          const SizedBox(height: 8),
                          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                        ]),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}