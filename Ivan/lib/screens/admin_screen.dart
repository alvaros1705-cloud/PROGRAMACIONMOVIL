import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_colors.dart';

const List<Map<String, dynamic>> establecimientos = [
  {'name': 'Fair Play', 'category': 'Fútbol', 'icon': Icons.sports_soccer, 'color': AppColors.green},
  {'name': 'La Academia', 'category': 'Fútbol', 'icon': Icons.sports_soccer, 'color': AppColors.green},
  {'name': 'Complejo Deportivo Olé', 'category': 'Fútbol', 'icon': Icons.sports_soccer, 'color': AppColors.green},
  {'name': 'Campo Deportivo La 12', 'category': 'Fútbol', 'icon': Icons.sports_soccer, 'color': AppColors.green},
  {'name': 'Canchas Wembley', 'category': 'Fútbol', 'icon': Icons.sports_soccer, 'color': AppColors.green},
  {'name': 'Niza Club', 'category': 'Pádel', 'icon': Icons.sports_tennis, 'color': Color(0xFF4A90D9)},
  {'name': 'Club Cazadores Pádel', 'category': 'Pádel', 'icon': Icons.sports_tennis, 'color': Color(0xFF4A90D9)},
  {'name': 'Pro Padel Club', 'category': 'Pádel', 'icon': Icons.sports_tennis, 'color': Color(0xFF4A90D9)},
  {'name': 'Zenter Cúcuta', 'category': 'Pádel', 'icon': Icons.sports_tennis, 'color': Color(0xFF4A90D9)},
  {'name': 'North Padel Club', 'category': 'Pádel', 'icon': Icons.sports_tennis, 'color': Color(0xFF4A90D9)},
  {'name': 'Club Cazadores Tenis', 'category': 'Tenis', 'icon': Icons.sports_baseball, 'color': Color(0xFFE8A838)},
  {'name': 'Tenis Golf Club', 'category': 'Tenis', 'icon': Icons.sports_baseball, 'color': Color(0xFFE8A838)},
  {'name': 'Academia El Bosque', 'category': 'Tenis', 'icon': Icons.sports_baseball, 'color': Color(0xFFE8A838)},
  {'name': 'Complejo Fabiola Zuluaga', 'category': 'Tenis', 'icon': Icons.sports_baseball, 'color': Color(0xFFE8A838)},
  {'name': 'Hunters Club', 'category': 'Tenis', 'icon': Icons.sports_baseball, 'color': Color(0xFFE8A838)},
  {'name': 'Coliseo Baloncesto', 'category': 'Basket', 'icon': Icons.sports_basketball, 'color': Color(0xFFE05C3A)},
  {'name': 'Cañoneros de Cúcuta', 'category': 'Basket', 'icon': Icons.sports_basketball, 'color': Color(0xFFE05C3A)},
  {'name': 'Club Pasión Baloncesto', 'category': 'Basket', 'icon': Icons.sports_basketball, 'color': Color(0xFFE05C3A)},
  {'name': 'Coliseo Barrio El Contento', 'category': 'Basket', 'icon': Icons.sports_basketball, 'color': Color(0xFFE05C3A)},
  {'name': 'Coliseo Niña Ceci', 'category': 'Basket', 'icon': Icons.sports_basketball, 'color': Color(0xFFE05C3A)},
];

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool _isAuthenticated = false;
  String? _selectedEstablishment;
  final _passwordController = TextEditingController();
  final String _adminPassword = 'gameon2024';

  String _selectedFilter = 'Todas';
  final List<String> _filters = ['Todas', 'Pendiente', 'Confirmada', 'Cancelada'];

  Stream<QuerySnapshot>? _reservationsStream;
  List<QueryDocumentSnapshot> _cachedDocs = [];

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Confirmada': return AppColors.green;
      case 'Pendiente': return const Color(0xFFE8A838);
      case 'Cancelada': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getSportIcon(String category) {
    switch (category) {
      case 'Fútbol': return Icons.sports_soccer;
      case 'Pádel': return Icons.sports_tennis;
      case 'Tenis': return Icons.sports_baseball;
      case 'Basket': return Icons.sports_basketball;
      default: return Icons.sports;
    }
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      const months = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
      return '${date.day} ${months[date.month - 1]} ${date.year} - ${date.hour.toString().padLeft(2,'0')}:${date.minute.toString().padLeft(2,'0')}';
    } catch (_) {
      return isoDate;
    }
  }

  Future<void> _updateStatus(String docId, String newStatus) async {
    await _db.collection('reservations').doc(docId).update({'status': newStatus});
  }

  List<QueryDocumentSnapshot> get _filteredDocs {
    if (_selectedFilter == 'Todas') return _cachedDocs;
    return _cachedDocs.where((d) =>
        (d.data() as Map<String, dynamic>)['status'] == _selectedFilter).toList();
  }

  void _checkPassword() {
    if (_passwordController.text == _adminPassword) {
      setState(() {
        _isAuthenticated = true;
        _selectedFilter = 'Todas';
        _cachedDocs = [];
        _reservationsStream = _db
            .collection('reservations')
            .where('courtName', isEqualTo: _selectedEstablishment)
            .orderBy('createdAt', descending: true)
            .snapshots();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Contraseña incorrecta'), backgroundColor: Colors.red),
      );
    }
  }

  // PANTALLA 1: Lista de establecimientos
  Widget _buildEstablishmentsScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.store, size: 24),
            SizedBox(width: 8),
            Text("GameOn — Establecimientos", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text("Selecciona tu establecimiento",
                style: TextStyle(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: establecimientos.length,
              itemBuilder: (_, i) {
                final est = establecimientos[i];
                final color = est['color'] as Color;
                final icon = est['icon'] as IconData;
                final name = est['name'] as String;
                final category = est['category'] as String;

                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedEstablishment = name;
                    _isAuthenticated = false;
                    _passwordController.clear();
                  }),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                          child: Icon(icon, color: color, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              const SizedBox(height: 2),
                              Text(category, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppColors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.arrow_forward_ios, color: AppColors.green, size: 14),
                        ),
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

  // PANTALLA 2: Login del establecimiento
  Widget _buildLoginScreen() {
    final est = establecimientos.firstWhere((e) => e['name'] == _selectedEstablishment);
    final color = est['color'] as Color;
    final icon = est['icon'] as IconData;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.green),
          onPressed: () => setState(() {
            _selectedEstablishment = null;
            _isAuthenticated = false;
          }),
        ),
      ),
      body: Center(
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 48),
              ),
              const SizedBox(height: 20),
              Text(_selectedEstablishment ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text("Panel de Reservas",
                  style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              const SizedBox(height: 4),
              Text("Ingresa tu contraseña para continuar",
                  style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              const SizedBox(height: 28),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Contraseña",
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.green),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.green, width: 2)),
                ),
                onSubmitted: (_) => _checkPassword(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _checkPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Ingresar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // PANTALLA 3: Reservas del establecimiento
  Widget _buildReservationsScreen() {
    final est = establecimientos.firstWhere((e) => e['name'] == _selectedEstablishment);
    final color = est['color'] as Color;
    final icon = est['icon'] as IconData;

    return StreamBuilder<QuerySnapshot>(
      stream: _reservationsStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _cachedDocs = snapshot.data!.docs;
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.green,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => setState(() {
                _selectedEstablishment = null;
                _isAuthenticated = false;
                _reservationsStream = null;
                _cachedDocs = [];
              }),
            ),
            title: Row(
              children: [
                Icon(icon, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_selectedEstablishment ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => setState(() {
                  _isAuthenticated = false;
                  _selectedEstablishment = null;
                  _reservationsStream = null;
                  _cachedDocs = [];
                }),
                tooltip: "Cerrar sesión",
              ),
            ],
          ),
          body: Column(
            children: [
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: _filters.map((filter) {
                    final isSelected = filter == _selectedFilter;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedFilter = filter),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.green : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
                        ),
                        child: Text(filter, style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        )),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.receipt_long, color: color, size: 16),
                    const SizedBox(width: 6),
                    Text("${_filteredDocs.length} reservas",
                        style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: snapshot.connectionState == ConnectionState.waiting && _cachedDocs.isEmpty
                    ? const Center(child: CircularProgressIndicator(color: AppColors.green))
                    : _filteredDocs.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.calendar_today, size: 60, color: Colors.grey[300]),
                                const SizedBox(height: 12),
                                Text("No hay reservas $_selectedFilter",
                                    style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredDocs.length,
                            itemBuilder: (_, i) {
                              final doc = _filteredDocs[i];
                              final data = doc.data() as Map<String, dynamic>;
                              final status = data['status'] ?? 'Pendiente';
                              final statusColor = _getStatusColor(status);
                              final category = data['category'] ?? 'Fútbol';

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                                  border: Border.all(color: statusColor.withOpacity(0.2)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                                          child: Icon(_getSportIcon(category), color: statusColor, size: 24),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(data['courtName'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                              Text('${data['hour'] ?? ''} — ${data['price'] ?? ''}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                                          child: Text(status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    const Divider(height: 1),
                                    const SizedBox(height: 12),
                                    Row(children: [
                                      const Icon(Icons.person_outline, color: AppColors.green, size: 16),
                                      const SizedBox(width: 6),
                                      Text(data['userName'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500)),
                                    ]),
                                    const SizedBox(height: 4),
                                    Row(children: [
                                      const Icon(Icons.badge_outlined, color: AppColors.green, size: 16),
                                      const SizedBox(width: 6),
                                      Text('CC: ${data['userCedula'] ?? ''}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                      const SizedBox(width: 16),
                                      const Icon(Icons.phone_outlined, color: AppColors.green, size: 16),
                                      const SizedBox(width: 6),
                                      Text(data['userPhone'] ?? '', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                    ]),
                                    const SizedBox(height: 4),
                                    Row(children: [
                                      const Icon(Icons.access_time, color: AppColors.green, size: 16),
                                      const SizedBox(width: 6),
                                      Text(_formatDate(data['date'] ?? ''), style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                    ]),
                                    if (status == 'Pendiente') ...[
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () => _updateStatus(doc.id, 'Confirmada'),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(vertical: 10),
                                                decoration: BoxDecoration(color: AppColors.green, borderRadius: BorderRadius.circular(10)),
                                                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                                  Icon(Icons.check_circle, color: Colors.white, size: 18),
                                                  SizedBox(width: 6),
                                                  Text("Confirmar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                                ]),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () => _updateStatus(doc.id, 'Cancelada'),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(vertical: 10),
                                                decoration: BoxDecoration(
                                                  color: Colors.red.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                                                ),
                                                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                                  Icon(Icons.cancel, color: Colors.red, size: 18),
                                                  SizedBox(width: 6),
                                                  Text("Cancelar", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                                ]),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedEstablishment == null) return _buildEstablishmentsScreen();
    if (!_isAuthenticated) return _buildLoginScreen();
    return _buildReservationsScreen();
  }
}