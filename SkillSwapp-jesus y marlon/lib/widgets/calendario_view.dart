import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CalendarioView extends StatefulWidget {
  final Map<DateTime, List<dynamic>> events;
  final Function(DateTime, DateTime) onDaySelected;
  final DateTime focusedDay;
  final DateTime? selectedDay;

  const CalendarioView({
    super.key,
    required this.events,
    required this.onDaySelected,
    required this.focusedDay,
    this.selectedDay,
  });

  @override
  State<CalendarioView> createState() => _CalendarioViewState();
}

class _CalendarioViewState extends State<CalendarioView> {
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
    final List<Map<String, dynamic>> pendingMeetings = [];

    widget.events.forEach((date, events) {
      for (var event in events) {
        if (event["status"] == "pending" && event["receiverId"] == currentUserId) {
          pendingMeetings.add(event);
        }
      }
    });

    return Column(
      children: [
        if (pendingMeetings.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF00A99D).withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFF00A99D), width: 1),
              ),
              child: Row(
                children: [
                   const Icon(Icons.notifications_active, color: Color(0xFF00A99D)),
                   const SizedBox(width: 12),
                   Expanded(
                     child: Text(
                       "¡Hola! Tienes ${pendingMeetings.length} programación(es) pendiente(s) de: ${pendingMeetings.map((e) => e["senderName"] ?? "Alguien").join(", ")}",
                       style: const TextStyle(
                         color: Color(0xFF334A5F),
                         fontWeight: FontWeight.bold,
                       ),
                     ),
                   ),
                ],
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            image: const DecorationImage(
              image: AssetImage('assets/Fondo_SkillSwap.png'),
              fit: BoxFit.cover,
              opacity: 0.1,
            ),
          ),
          child: TableCalendar(
            locale: 'es_ES',
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: widget.focusedDay,
            selectedDayPredicate: (day) => isSameDay(widget.selectedDay, day),
            calendarFormat: _calendarFormat,
            eventLoader: (day) => widget.events[DateTime(day.year, day.month, day.day)] ?? [],
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                color: Color(0xFF00A99D),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFF00A99D)),
              rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFF00A99D)),
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: const Color(0xFF6BCE7A).withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Color(0xFF00A99D),
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: Color(0xFF6BCE7A),
                shape: BoxShape.circle,
              ),
              markersMaxCount: 3,
            ),
            onDaySelected: widget.onDaySelected,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              // Usually handled by parent
            },
          ),
        ),
        const SizedBox(height: 20),
        if (widget.selectedDay != null &&
            widget.events[DateTime(widget.selectedDay!.year, widget.selectedDay!.month, widget.selectedDay!.day)] != null)
          ...(widget.events[DateTime(widget.selectedDay!.year, widget.selectedDay!.month, widget.selectedDay!.day)]!)
              .map((event) {
                DateTime meetingDate;
                try {
                  meetingDate = DateTime.parse(event['meetingDate']).toLocal();
                } catch (e) {
                  meetingDate = DateTime.now();
                }
                
                return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: event["status"] == "accepted"
                            ? const Color(0xFF6BCE7A)
                            : Colors.orange,
                        width: 1.5,
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: event["status"] == "accepted"
                            ? const Color(0xFF6BCE7A)
                            : Colors.orange,
                        child: Icon(
                          event["status"] == "accepted" ? Icons.check : Icons.timer,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        "Reunión con ${event["senderName"] ?? "Usuario"}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Estado: ${event["status"] == "accepted" ? "Confirmada" : "Pendiente"}",
                      ),
                      trailing: Text(
                        "${meetingDate.hour}:${meetingDate.minute.toString().padLeft(2, '0')}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                })
        else
          Container(
            padding: const EdgeInsets.all(20),
            child: const Text(
              "No hay eventos para este día",
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ),
      ],
    );
  }
}
