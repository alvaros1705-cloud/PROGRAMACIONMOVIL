import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';

class InterfazMatch {
  static const Color primaryGreen = Color(0xFF6BCE7A);
  static const Color secondaryTeal = Color(0xFF00A99D);

  static String getMatchId(String uid1, String uid2) {
    List<String> ids = [uid1, uid2];
    ids.sort();
    return ids.join('_');
  }

  static Future<void> mostrarEstadoSolicitud(BuildContext context, String targetUid, String targetName, String targetPhoto) async {
    if (context.mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => PantallaSolicitudEnviada(
          targetName: targetName,
          targetUid: targetUid,
          targetPhoto: targetPhoto,
        ),
      );
    }
  }

  static Future<void> enviarSolicitud(BuildContext context, String targetUid, String targetName, String targetPhoto) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final matchId = getMatchId(currentUser.uid, targetUid);

    await FirebaseFirestore.instance.collection('solicitudes').doc(matchId).set({
      'from': currentUser.uid,
      'to': targetUid,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
      'users': [currentUser.uid, targetUid],
    }, SetOptions(merge: true));

    if (context.mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => PantallaSolicitudEnviada(
          targetName: targetName,
          targetUid: targetUid,
          targetPhoto: targetPhoto,
        ),
      );
    }
  }

  static Future<void> aceptarSolicitud(BuildContext context, String matchId, Map<String, dynamic> matchData) async {
    await FirebaseFirestore.instance.collection('solicitudes').doc(matchId).update({
      'status': 'accepted',
      'acceptedAt': FieldValue.serverTimestamp(),
    });

    if (context.mounted) {
      // Mostrar pantalla de Match Aceptado
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PantallaMatchAceptado(matchData: matchData),
        ),
      );
    }
  }
}

class PantallaSolicitudEnviada extends StatelessWidget {
  final String targetName;
  final String targetUid;
  final String targetPhoto;

  const PantallaSolicitudEnviada({super.key, required this.targetName, required this.targetUid, required this.targetPhoto});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
      ),
      child: Stack(
        children: [
          // Fondo con destellos (usando el asset existente)
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: Image.asset('assets/Fondo_SkillSwap.png', fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              children: [
                const SizedBox(height: 15),
                // Handle del bottom sheet
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 30),
                // Icono superior (Avión de papel)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    color: Color(0xFF6BCE7A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 35),
                ),
                const SizedBox(height: 25),
                const Text(
                  "Solicitud enviada",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2A3D50),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 15),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.4),
                    children: [
                      TextSpan(
                        text: "$targetName ",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const TextSpan(text: "fue notificada de tu interés.\n"),
                      const TextSpan(text: "Cuando acepte, podrán comenzar a intercambiar habilidades."),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                // Sección de Avatares con Conector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _AvatarConReloj(uid: currentUserId ?? ''),
                    // Línea punteada con reloj
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Row(
                            children: List.generate(15, (index) => Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                height: 1.5,
                                color: Colors.green.withOpacity(0.3),
                              ),
                            )),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.green.withOpacity(0.2)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                )
                              ],
                            ),
                            child: const Icon(Icons.alarm, color: Color(0xFF6BCE7A), size: 24),
                          ),
                        ],
                      ),
                    ),
                    _AvatarSimple(photo: targetPhoto, name: targetName),
                  ],
                ),
                const Spacer(),
                // Tarjeta de Estado (Estilo de la imagen)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Estado del Match",
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                              color: Color(0xFF2A3D50),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7E6),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Text(
                              "Pendiente",
                              style: TextStyle(
                                color: Color(0xFFFFA940),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Esperando respuesta de $targetName.",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 35),
                // Botón Volver
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF2A3D50),
                    elevation: 0,
                    side: BorderSide(color: Colors.grey.shade200),
                    minimumSize: const Size(double.infinity, 58),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: const Text(
                    "Volver al inicio",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PantallaMatchAceptado extends StatelessWidget {
  final Map<String, dynamic> matchData;

  const PantallaMatchAceptado({super.key, required this.matchData});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final otherUid = matchData['from'] == currentUserId ? matchData['to'] : matchData['from'];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset('assets/Fondo_SkillSwap.png', fit: BoxFit.cover),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('usuarios').doc(otherUid).get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final otherData = snapshot.data!.data() as Map<String, dynamic>;
                  final otherName = otherData['nombre'] ?? 'Usuario';
                  final otherPhoto = otherData['photoUrl'] ?? otherData['fotoUrl'] ?? '';
                  final otherOffers = otherData['ofrece'] ?? 'Habilidades';
                  final otherNeeds = otherData['necesita'] ?? 'Conocimiento';

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('usuarios').doc(currentUserId).get(),
                    builder: (context, mySnap) {
                      final myData = mySnap.data?.data() as Map<String, dynamic>?;
                      final myName = myData?['nombre'] ?? 'Tú';
                      final myOffers = myData?['ofrece'] ?? 'Habilidades';
                      final myNeeds = myData?['necesita'] ?? 'Conocimiento';

                      return Column(
                        children: [
                          const SizedBox(height: 50),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("🔥 ", style: TextStyle(fontSize: 32)),
                              Text(
                                "¡Match aceptado!",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF2A3D50),
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Ahora pueden comenzar a chatear y\ncoordinar su intercambio.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 50),
                          // Sección de Avatares con Check
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _AvatarConBorde(uid: currentUserId ?? ''),
                              const SizedBox(width: 15),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF6BCE7A),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check, color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 15),
                              _AvatarConBorde(uid: otherUid),
                            ],
                          ),
                          const SizedBox(height: 30),
                          // Bloque de Información de Habilidades (Diseño Imagen)
                          Row(
                            children: [
                              Expanded(
                                child: _InfoMatchCustom(
                                  label: "Tú",
                                  offers: myOffers,
                                  needs: myNeeds,
                                  isLeft: true,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: _InfoMatchCustom(
                                  label: otherName,
                                  offers: otherOffers,
                                  needs: otherNeeds,
                                  isLeft: false,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          // Botón Ir al Chat
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    receiverId: otherUid,
                                    receiverName: otherName,
                                    receiverPhoto: otherPhoto,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 22),
                            label: const Text(
                              "Ir al chat",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6BCE7A),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 60),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              elevation: 0,
                            ),
                          ),
                          const SizedBox(height: 15),
                          // Botón Ver Perfil
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF2A3D50),
                              minimumSize: const Size(double.infinity, 60),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              "Ver perfil de ${otherName.split(' ')[0]}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoMatchCustom extends StatelessWidget {
  final String label;
  final String offers;
  final String needs;
  final bool isLeft;

  const _InfoMatchCustom({
    required this.label,
    required this.offers,
    required this.needs,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 17,
            color: Color(0xFF2A3D50),
          ),
        ),
        const SizedBox(height: 8),
        _buildSkillLine(isLeft ? "Ofreces: " : "Ofrece: ", offers, const Color(0xFF6BCE7A)),
        const SizedBox(height: 4),
        _buildSkillLine("Necesitas: ", needs, const Color(0xFF00A99D)),
      ],
    );
  }

  Widget _buildSkillLine(String prefix, String text, Color color) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(fontSize: 13, height: 1.2),
        children: [
          TextSpan(text: prefix, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          TextSpan(text: text, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
}

class _AvatarConReloj extends StatelessWidget {
  final String uid;
  const _AvatarConReloj({required this.uid});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('usuarios').doc(uid).get(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final photo = data?['photoUrl'] ?? data?['fotoUrl'] ?? '';
        return Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF6BCE7A), width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                spreadRadius: 2,
              )
            ],
          ),
          child: ClipOval(child: _buildImage(photo)),
        );
      },
    );
  }
}

class _AvatarConBorde extends StatelessWidget {
  final String uid;
  const _AvatarConBorde({required this.uid});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('usuarios').doc(uid).get(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final photo = data?['photoUrl'] ?? data?['fotoUrl'] ?? '';
        return Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF6BCE7A), width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
              )
            ],
          ),
          child: ClipOval(child: _buildImage(photo)),
        );
      },
    );
  }
}

class _AvatarSimple extends StatelessWidget {
  final String photo;
  final String name;
  const _AvatarSimple({required this.photo, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF6BCE7A), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            spreadRadius: 2,
          )
        ],
      ),
      child: ClipOval(child: _buildImage(photo)),
    );
  }
}

class _InfoMatch extends StatelessWidget {
  final String label;
  final String offers;
  final String needs;

  const _InfoMatch({required this.label, required this.offers, required this.needs});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Ofrece: ", style: TextStyle(color: InterfazMatch.primaryGreen, fontSize: 12, fontWeight: FontWeight.bold)),
            Text(offers, style: const TextStyle(fontSize: 12)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Necesita: ", style: TextStyle(color: InterfazMatch.secondaryTeal, fontSize: 12, fontWeight: FontWeight.bold)),
            Text(needs, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ],
    );
  }
}

Widget _buildImage(String photo) {
  if (photo.startsWith('http')) return Image.network(photo, fit: BoxFit.cover);
  if (photo.isNotEmpty) {
    try {
      return Image.memory(base64Decode(photo), fit: BoxFit.cover);
    } catch (_) {}
  }
  return const Icon(Icons.person, size: 40);
}

