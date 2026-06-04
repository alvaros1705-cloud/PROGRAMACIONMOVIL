import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'widgets/base64_image.dart';

class CalendarioScreen extends StatefulWidget {
  final String? otherUserId;
  final String? otherUserName;

  const CalendarioScreen({
    super.key,
    this.otherUserId,
    this.otherUserName,
  });

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Mapa de todas las reuniones agrupadas por día
  Map<DateTime, List<dynamic>> _events = {};
  
  // Mapa de contactos con los que hay reuniones: {userId: userName}
  Map<String, String> _contacts = {};
  
  // Filtro seleccionado de usuario (ID de usuario o null para 'todos')
  String? _selectedFilterContactId;
  
  StreamSubscription? _reunionesSubscription;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime(_focusedDay.year, _focusedDay.month, _focusedDay.day);
    
    // Si se pasa un filtro por constructor, lo activamos por defecto
    if (widget.otherUserId != null) {
      _selectedFilterContactId = widget.otherUserId;
      if (widget.otherUserName != null) {
        _contacts[widget.otherUserId!] = widget.otherUserName!;
      }
    }
    
    _listenToEvents();
  }

  @override
  void dispose() {
    _reunionesSubscription?.cancel();
    super.dispose();
  }

  void _listenToEvents() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _reunionesSubscription = FirebaseFirestore.instance
        .collection('reuniones')
        .snapshots()
        .listen((snapshot) {
      Map<DateTime, List<dynamic>> newEvents = {};
      Map<String, String> userNames = {};

      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          if (data['meetingDate'] == null) continue;

          final senderId = data['senderId'];
          final receiverId = data['receiverId'];

          // Solo procesar si el usuario actual es emisor o receptor
          if (senderId == user.uid || receiverId == user.uid) {
            final DateTime date = DateTime.parse(data['meetingDate']);
            final DateTime dayOnly = DateTime(date.year, date.month, date.day);
            
            final otherId = senderId == user.uid ? receiverId : senderId;
            final otherName = senderId == user.uid 
                ? (data['receiverName'] ?? "Usuario")
                : (data['senderName'] ?? "Usuario");

            userNames[otherId] = otherName;

            final eventData = Map<String, dynamic>.from(data);
            eventData['id'] = doc.id;
            eventData['otherId'] = otherId;
            eventData['otherName'] = otherName;

            if (newEvents[dayOnly] == null) newEvents[dayOnly] = [];
            newEvents[dayOnly]!.add(eventData);
          }
        } catch (e) {
          debugPrint("Error al procesar reunión en calendario: $e");
        }
      }

      // Si se pasa un filtro por constructor, nos aseguramos de que esté en la lista
      if (widget.otherUserId != null && widget.otherUserName != null) {
        userNames[widget.otherUserId!] = widget.otherUserName!;
      }

      if (mounted) {
        setState(() {
          _events = newEvents;
          _contacts = userNames;
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _updateMeetingStatus(String meetingId, String chatId, String status) async {
    try {
      // Actualizar en la colección global 'reuniones'
      await FirebaseFirestore.instance
          .collection('reuniones')
          .doc(meetingId)
          .update({'status': status});

      // Actualizar en el mensaje de chat correspondiente para consistencia
      await FirebaseFirestore.instance
          .collection('chat')
          .doc(chatId)
          .collection('mensajes')
          .doc(meetingId)
          .update({'status': status});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status == 'accepted' ? 'Encuentro aceptado' : 'Encuentro rechazado'),
            backgroundColor: status == 'accepted' ? const Color(0xFF6BCE7A) : Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error al actualizar estado del encuentro: $e");
    }
  }

  Widget _buildAvatarLetter(String name) {
    return Text(
      name.isNotEmpty ? name[0].toUpperCase() : '?',
      style: const TextStyle(color: Color(0xFF334A5F), fontWeight: FontWeight.bold),
    );
  }

  Widget _buildUserAvatar(String photo, String name, {double radius = 20}) {
    final photoTrimmed = photo.trim();
    if (photoTrimmed.startsWith('http')) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey.shade200,
        backgroundImage: NetworkImage(photoTrimmed),
      );
    }
    if (photoTrimmed.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey.shade200,
        child: ClipOval(
          child: Base64Image(
            base64Data: photoTrimmed,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF6BCE7A).withOpacity(0.2),
      child: _buildAvatarLetter(name),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF6BCE7A);
    const Color darkText = Color(0xFF334A5F);
    const Color accentTeal = Color(0xFF00A99D);
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

    // Filtrar los eventos según el usuario seleccionado
    Map<DateTime, List<dynamic>> filteredEvents = {};
    _events.forEach((day, list) {
      final filteredList = list.where((event) {
        if (_selectedFilterContactId == null) return true;
        return event['otherId'] == _selectedFilterContactId;
      }).toList();
      if (filteredList.isNotEmpty) {
        filteredEvents[day] = filteredList;
      }
    });

    final selectedDateOnly = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    final dayEvents = filteredEvents[selectedDateOnly] ?? [];

    // Calcular cuántas programaciones pendientes tiene el usuario actual
    int pendingCount = 0;
    _events.forEach((date, events) {
      for (var event in events) {
        if (event["status"] == "pending" && event["receiverId"] == currentUserId) {
          pendingCount++;
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.otherUserId != null ? "Calendario con ${widget.otherUserName}" : "Mi Calendario",
          style: const TextStyle(fontWeight: FontWeight.bold, color: darkText),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: darkText),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF9FBFC),
          image: DecorationImage(
            image: AssetImage('assets/Fondo_SkillSwap.png'),
            fit: BoxFit.cover,
            opacity: 0.05,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: primaryGreen))
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Banner de recordatorio si hay pendientes ---
                      if (pendingCount > 0)
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: accentTeal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: accentTeal, width: 1),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.notifications_active, color: accentTeal),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "¡Hola! Tienes $pendingCount encuentro(s) pendiente(s) por responder. Selecciona los días con marcadores naranjas para responder.",
                                  style: const TextStyle(
                                    color: darkText,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // --- FILTRAR POR CONTACTO (Dropdown) ---
                      if (widget.otherUserId == null) ...[
                        const Text(
                          "Filtrar encuentros:",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: darkText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey.shade300),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedFilterContactId ?? 'todos',
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down, color: primaryGreen),
                              style: const TextStyle(
                                color: darkText,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              items: [
                                const DropdownMenuItem<String>(
                                  value: 'todos',
                                  child: Text("Todos los encuentros"),
                                ),
                                ..._contacts.entries.map((entry) {
                                  return DropdownMenuItem<String>(
                                    value: entry.key,
                                    child: Text("Encuentros con ${entry.value}"),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedFilterContactId = value == 'todos' ? null : value;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // --- CALENDARIO ---
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(10),
                        child: TableCalendar(
                          locale: 'es_ES',
                          firstDay: DateTime.utc(2024, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          focusedDay: _focusedDay,
                          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                          calendarFormat: _calendarFormat,
                          eventLoader: (day) {
                            final dateKey = DateTime(day.year, day.month, day.day);
                            return filteredEvents[dateKey] ?? [];
                          },
                          startingDayOfWeek: StartingDayOfWeek.monday,
                          headerStyle: const HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            titleTextStyle: TextStyle(
                              color: accentTeal,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            leftChevronIcon: Icon(Icons.chevron_left, color: accentTeal),
                            rightChevronIcon: Icon(Icons.chevron_right, color: accentTeal),
                          ),
                          calendarStyle: CalendarStyle(
                            todayDecoration: BoxDecoration(
                              color: primaryGreen.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            todayTextStyle: const TextStyle(
                              color: darkText,
                              fontWeight: FontWeight.bold,
                            ),
                            selectedDecoration: const BoxDecoration(
                              color: primaryGreen,
                              shape: BoxShape.circle,
                            ),
                            markerDecoration: const BoxDecoration(
                              color: accentTeal,
                              shape: BoxShape.circle,
                            ),
                            markersMaxCount: 3,
                          ),
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                          },
                          onFormatChanged: (format) {
                            setState(() {
                              _calendarFormat = format;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 25),

                      // --- LISTADO DE EVENTOS DEL DÍA ---
                      Text(
                        "Encuentros para el ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: darkText,
                        ),
                      ),
                      const SizedBox(height: 15),

                      if (dayEvents.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: dayEvents.length,
                          itemBuilder: (context, index) {
                            final event = dayEvents[index];
                            final String status = event['status'] ?? 'pending';
                            final String otherName = event['otherName'] ?? 'Usuario';
                            final String photo = event['senderId'] == currentUserId
                                ? (event['receiverPhoto'] ?? '')
                                : (event['senderPhoto'] ?? '');
                            final DateTime meetingDate = DateTime.parse(event['meetingDate']).toLocal();
                            final String timeStr = "${meetingDate.hour}:${meetingDate.minute.toString().padLeft(2, '0')}";
                            final bool isPendingForMe = status == 'pending' && event['receiverId'] == currentUserId;

                            Color statusColor = Colors.orange;
                            String statusText = "Pendiente";
                            IconData statusIcon = Icons.timer;

                            if (status == 'accepted') {
                              statusColor = primaryGreen;
                              statusText = "Confirmada";
                              statusIcon = Icons.check_circle;
                            } else if (status == 'declined') {
                              statusColor = Colors.redAccent;
                              statusText = "Rechazada";
                              statusIcon = Icons.cancel;
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: statusColor.withOpacity(0.3),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      _buildUserAvatar(photo, otherName, radius: 24),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Encuentro con $otherName",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: darkText,
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(statusIcon, color: statusColor, size: 16),
                                                const SizedBox(width: 6),
                                                Text(
                                                  statusText,
                                                  style: TextStyle(
                                                    color: statusColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        timeStr,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: darkText,
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  // Si está pendiente de mi aprobación, muestro los botones de acción
                                  if (isPendingForMe) ...[
                                    const SizedBox(height: 15),
                                    const Divider(height: 1),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton.icon(
                                          onPressed: () => _updateMeetingStatus(
                                            event['id'],
                                            event['chatId'] ?? "",
                                            'declined',
                                          ),
                                          icon: const Icon(Icons.close, color: Colors.redAccent, size: 18),
                                          label: const Text("Rechazar", style: TextStyle(color: Colors.redAccent)),
                                          style: TextButton.styleFrom(
                                            backgroundColor: Colors.redAccent.withOpacity(0.1),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        ElevatedButton.icon(
                                          onPressed: () => _updateMeetingStatus(
                                            event['id'],
                                            event['chatId'] ?? "",
                                            'accepted',
                                          ),
                                          icon: const Icon(Icons.check, color: Colors.white, size: 18),
                                          label: const Text("Aceptar", style: TextStyle(color: Colors.white)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: primaryGreen,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            elevation: 0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: const Center(
                            child: Column(
                              children: [
                                Icon(Icons.calendar_today_outlined, color: Colors.grey, size: 36),
                                SizedBox(height: 12),
                                Text(
                                  "No hay encuentros programados para hoy",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
