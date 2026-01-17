import 'package:flutter/material.dart';

class CustomCalendarAppbar extends StatefulWidget {
  final Function(DateTime) onDateChanged;
  final DateTime selectedDate;

  const CustomCalendarAppbar({
    Key? key,
    required this.onDateChanged,
    required this.selectedDate,
  }) : super(key: key);

  @override
  State<CustomCalendarAppbar> createState() => _CustomCalendarAppbarState();
}

class _CustomCalendarAppbarState extends State<CustomCalendarAppbar> {
  late DateTime currentMonth;

  @override
  void initState() {
    super.initState();
    currentMonth = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
    );
  }

  void previousMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
    });
  }

  void nextMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDay = DateTime(currentMonth.year, currentMonth.month + 1, 0);
    final daysInMonth = lastDay.day;
    final startingDayOfWeek = firstDay.weekday;

    return PreferredSize(
      preferredSize: Size.fromHeight(350),
      child: Container(
        color: Colors.green,
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Header dengan bulan/tahun dan navigasi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: previousMonth,
                ),
                Text(
                  '${_getMonthName(currentMonth.month)} ${currentMonth.year}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right, color: Colors.white),
                  onPressed: nextMonth,
                ),
              ],
            ),
            SizedBox(height: 8),
            // Hari-hari dalam seminggu (header)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                  .map(
                    (day) => SizedBox(
                      width: 40,
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: 8),
            // Grid kalender
            GridView.count(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              shrinkWrap: true,
              childAspectRatio: 1.2,
              children: [
                // Empty cells untuk hari sebelum bulan dimulai
                for (int i = 0; i < startingDayOfWeek; i++) Container(),
                // Hari-hari dalam bulan
                for (int day = 1; day <= daysInMonth; day++)
                  GestureDetector(
                    onTap: () {
                      final selectedDate = DateTime(
                        currentMonth.year,
                        currentMonth.month,
                        day,
                      );
                      widget.onDateChanged(selectedDate);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            widget.selectedDate.year == currentMonth.year &&
                                widget.selectedDate.month ==
                                    currentMonth.month &&
                                widget.selectedDate.day == day
                            ? Colors.orange
                            : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '$day',
                          style: TextStyle(
                            color:
                                widget.selectedDate.year == currentMonth.year &&
                                    widget.selectedDate.month ==
                                        currentMonth.month &&
                                    widget.selectedDate.day == day
                                ? Colors.white
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}
