import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_colors.dart';
import '../firestore_service.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String _selectedFilter = 'Todas';
  final List<String> _filters = ['Todas', 'Confirmada', 'Pendiente', 'Cancelada'];
  final FirestoreService _firestoreService = FirestoreService();

  IconData _getSportIcon(String category) {
    switch (category) {
      case 'Fútbol': return Icons.sports_soccer;
      case 'Pádel': return Icons.sports_tennis;
      case 'Tenis': return Icons.sports_baseball;
      case 'Basket': return Icons.sports_basketball;
      default: return Icons.sports;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Confirmada': return AppColors.green;
      case 'Pendiente': return const Color(0xFFE8A838);
      case 'Cancelada': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      const months = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return isoDate;
    }
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
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: const Row(
            children: [
              Icon(Icons.calendar_month_rounded, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Mis Reservas",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("Historial de reservas",
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _filters.map((filter) {
                final isSelected = filter == _selectedFilter;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFilter = filter),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.green : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
                        ],
                      ),
                      child: Text(
                        filter,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestoreService.getUserReservations(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.green));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today, size: 60, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text("No tienes reservas aún",
                            style: TextStyle(color: Colors.grey[500], fontSize: 15)),
                        const SizedBox(height: 8),
                        Text("¡Reserva tu primera cancha!",
                            style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                      ],
                    ),
                  );
                }

                final allDocs = snapshot.data!.docs;
                final filteredDocs = _selectedFilter == 'Todas'
                    ? allDocs
                    : allDocs.where((d) => d['status'] == _selectedFilter).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.filter_list, size: 60, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text("No hay reservas $_selectedFilter",
                            style: TextStyle(color: Colors.grey[500], fontSize: 15)),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Row(
                        children: [
                          const Icon(Icons.receipt_long, color: AppColors.green, size: 16),
                          const SizedBox(width: 4),
                          Text("${filteredDocs.length} reservas",
                              style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredDocs.length,
                        itemBuilder: (_, i) {
                          final doc = filteredDocs[i];
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
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(_getSportIcon(category), color: statusColor, size: 28),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(data['courtName'] ?? '',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                          const SizedBox(height: 4),
                                          Text(_formatDate(data['date'] ?? ''),
                                              style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                          Text(data['hour'] ?? '',
                                              style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(status,
                                          style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Divider(height: 1),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(data['price'] ?? '',
                                        style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                                    SizedBox(
                                      width: 120,
                                      height: 36,
                                      child: status == 'Cancelada'
                                          ? Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                                              ),
                                              child: const Center(
                                                child: Text("Cancelada",
                                                    style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                                              ),
                                            )
                                          : GestureDetector(
                                              onTap: () async {
                                                if (status == 'Pendiente') {
                                                  await _firestoreService.cancelReservation(doc.id);
                                                }
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: status == 'Pendiente'
                                                      ? Colors.red.withOpacity(0.1)
                                                      : AppColors.green.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(20),
                                                  border: Border.all(
                                                    color: status == 'Pendiente'
                                                        ? Colors.red.withOpacity(0.3)
                                                        : AppColors.green.withOpacity(0.3),
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    status == 'Pendiente' ? "Cancelar" : "Ver detalles",
                                                    style: TextStyle(
                                                      color: status == 'Pendiente' ? Colors.red : AppColors.green,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}