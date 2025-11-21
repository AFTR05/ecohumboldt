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

  // Cargar historial
  Future<void> _loadHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;

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

  // Filtrar historial del día
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

  // -------------------------------------------------------------------------
  // CALENDARIO REHECHO - PERFECTO
  // -------------------------------------------------------------------------
  Widget _calendarWidget() {
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    final firstWeekday = firstDay.weekday; // 1 = Lunes
    final daysInMonth = DateUtils.getDaysInMonth(currentMonth.year, currentMonth.month);

    final List<Widget> rows = [];
    int dayNumber = 1;

    // Cantidad de casillas vacías antes del día 1
    int leadingEmpty = firstWeekday - 1;

    // Construir las 6 semanas (6 filas)
    for (int week = 0; week < 6; week++) {
      List<Widget> weekRow = [];

      for (int weekday = 0; weekday < 7; weekday++) {
        if (leadingEmpty > 0) {
          weekRow.add(const Expanded(child: SizedBox()));
          leadingEmpty--;
        } else if (dayNumber > daysInMonth) {
          weekRow.add(const Expanded(child: SizedBox()));
        } else {
          final DateTime dayDate = DateTime(currentMonth.year, currentMonth.month, dayNumber);
          final bool isSelected = selectedDate.day == dayNumber &&
              selectedDate.month == currentMonth.month &&
              selectedDate.year == currentMonth.year;

          weekRow.add(
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDate = dayDate;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? const Color(0xFF2E7D32) : Colors.transparent,
                  ),
                  child: Center(
                    child: Text(
                      "$dayNumber",
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );

          dayNumber++;
        }
      }

      rows.add(Row(children: weekRow));
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Month Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 28),
                onPressed: () {
                  setState(() {
                    currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
                    selectedDate = DateTime(currentMonth.year, currentMonth.month, 1);
                  });
                },
              ),
              Text(
                DateFormat("MMMM yyyy", "es").format(currentMonth).toUpperCase(),
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 28),
                onPressed: () {
                  setState(() {
                    currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
                    selectedDate = DateTime(currentMonth.year, currentMonth.month, 1);
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Weekdays Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ["L", "M", "X", "J", "V", "S", "D"]
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
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

  // Tarjeta bonita
  Widget _historyCard(String title, String time, int points) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
        border: Border.all(color: Colors.green.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
              ),
            ),
            child: const Icon(Icons.eco_rounded, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 16),
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
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "+$points",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ready = !isLoading && _localeInitialized;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Historial de puntos",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
      body: !ready
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _calendarWidget(),
                const SizedBox(height: 20),
                if (filteredHistory.isEmpty)
                  const Center(
                    child: Text(
                      "No hay puntos para este día",
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                  )
                else
                  ...filteredHistory.map((data) {
                    return _historyCard(
                      data["description"] ?? "Actividad",
                      _formatTime(data["date"] ?? ""),
                      data["points"] ?? 0,
                    );
                  }),
              ],
            ),
    );
  }
}
