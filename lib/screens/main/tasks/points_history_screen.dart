import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class PointsHistoryScreen extends StatefulWidget {
  const PointsHistoryScreen({super.key});

  @override
  State<PointsHistoryScreen> createState() => _PointsHistoryScreenState();
}

class _PointsHistoryScreenState extends State<PointsHistoryScreen> {
  DateTime selectedDate = DateTime.now();
  DateTime currentMonth = DateTime(DateTime.now().year, DateTime.now().month);

  List<QueryDocumentSnapshot> allDocs = [];
  bool isLoading = true;
  bool _localeInitialized = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting("es").then((_) {
      setState(() => _localeInitialized = true);
    });
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("points_history")
        .orderBy("date", descending: true)
        .get();

    setState(() {
      allDocs = snapshot.docs;
      isLoading = false;
    });
  }

  // Historial filtrado por día
  List<Map<String, dynamic>> get filteredHistory {
    return allDocs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .where((data) {
          try {
            final date = DateTime.parse(data["date"]);
            return date.year == selectedDate.year &&
                date.month == selectedDate.month &&
                date.day == selectedDate.day;
          } catch (_) {
            return false;
          }
        })
        .toList();
  }

  String _formatTime(String raw) {
    try {
      final date = DateTime.parse(raw);
      return DateFormat("hh:mm a").format(date);
    } catch (_) {
      return raw;
    }
  }

  // ----------------- CALENDARIO ESTILO RETOS -----------------
  Widget _calendarWidget() {
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    final firstWeekday = firstDay.weekday; // Lunes = 1
    final daysInMonth =
        DateUtils.getDaysInMonth(currentMonth.year, currentMonth.month);

    List<Widget> rows = [];
    int dayNum = 1;
    int leadingEmpty = firstWeekday - 1;

    for (int week = 0; week < 6; week++) {
      List<Widget> weekRow = [];

      for (int w = 0; w < 7; w++) {
        if (leadingEmpty > 0) {
          weekRow.add(const Expanded(child: SizedBox()));
          leadingEmpty--;
        } else if (dayNum > daysInMonth) {
          weekRow.add(const Expanded(child: SizedBox()));
        } else {
          final date =
              DateTime(currentMonth.year, currentMonth.month, dayNum);

          final bool isSelected = selectedDate.day == dayNum &&
              selectedDate.month == currentMonth.month &&
              selectedDate.year == currentMonth.year;

          weekRow.add(
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => selectedDate = date),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? const Color(0xFF2E7D32)
                        : Colors.transparent,
                  ),
                  child: Center(
                    child: Text(
                      "$dayNum",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );

          dayNum++;
        }
      }

      rows.add(Row(children: weekRow));
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          // Header de mes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _calendarBtn(Icons.chevron_left, () {
                setState(() {
                  currentMonth =
                      DateTime(currentMonth.year, currentMonth.month - 1);
                  selectedDate = DateTime(
                      currentMonth.year, currentMonth.month, 1);
                });
              }),
              Text(
                DateFormat("MMMM yyyy", "es")
                    .format(currentMonth)
                    .toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF2E7D32),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _calendarBtn(Icons.chevron_right, () {
                setState(() {
                  currentMonth =
                      DateTime(currentMonth.year, currentMonth.month + 1);
                  selectedDate = DateTime(
                      currentMonth.year, currentMonth.month, 1);
                });
              }),
            ],
          ),

          const SizedBox(height: 10),

          // Días de la semana
          Row(
            children: ["L", "M", "X", "J", "V", "S", "D"]
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 10),

          Column(children: rows),
        ],
      ),
    );
  }

  Widget _calendarBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.green.withOpacity(0.12),
        ),
        child: Icon(icon, color: Colors.green),
      ),
    );
  }

  // ----------------- TARJETA ESTILO RETOS -----------------
  Widget _historyCard(String title, String time, int points) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          // Ícono tipo Retos
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.25),
                  blurRadius: 12,
                )
              ],
            ),
            child: const Icon(Icons.eco_rounded,
                color: Colors.white, size: 26),
          ),

          const SizedBox(width: 16),

          // Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Puntos
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "+$points",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          )
        ],
      ),
    );
  }

  // ------------------------ BUILD ------------------------
  @override
  Widget build(BuildContext context) {
    final ready = !isLoading && _localeInitialized;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F2),

      // HEADER TIPO MAINNAVIGATION: BLANCO, TÍTULO VERDE OSCURO
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: true, // muestra la flecha de back
        iconTheme: const IconThemeData(
          color: Color(0xFF2E4631), // color de la flecha
        ),
        title: const Text(
          "Historial de puntos",
          style: TextStyle(
            color: Color(0xFF2E4631),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),

      body: !ready
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(18),
              children: [
                _calendarWidget(),
                const SizedBox(height: 22),

                if (filteredHistory.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Text(
                        "Sin puntos registrados este día",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  )
                else
                  ...filteredHistory.map(
                    (data) => _historyCard(
                      data["description"] ?? "Actividad",
                      _formatTime(data["date"] ?? ""),
                      data["points"] ?? 0,
                    ),
                  ),
              ],
            ),
    );
  }
}
