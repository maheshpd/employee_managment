import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarDialog extends StatefulWidget {
  const CalendarDialog({super.key});

  @override
  State<CalendarDialog> createState() => _CalendarDialogState();
}

class _CalendarDialogState extends State<CalendarDialog> {
  DateTime selectedDate = DateTime.now();
  String selectedButton = "Today"; // Keeps track of the selected button

  void _setDate(DateTime date, String buttonName) {
    setState(() {
      selectedDate = date;
      selectedButton = buttonName;
    });
  }

  void _setToday() {
    _setDate(DateTime.now(), "Today");
  }

  void _setNextMonday() {
    DateTime today = DateTime.now();
    int daysUntilNextMonday = (8 - today.weekday) % 7;
    _setDate(today.add(Duration(days: daysUntilNextMonday)), "Next Monday");
  }

  void _setAfterOneWeek() {
    _setDate(DateTime.now().add(const Duration(days: 7)), "After 1 week");
  }

  void _setNextTuesday() {
    DateTime today = DateTime.now();
    int daysUntilNextTuesday = (9 - today.weekday) % 7;
    _setDate(today.add(Duration(days: daysUntilNextTuesday)), "Next Tuesday");
  }

  Color _getButtonColor(String buttonName) {
    return selectedButton == buttonName ? Colors.blue : Colors.grey[300]!;
  }

  Color _getTextColor(String buttonName) {
    return selectedButton == buttonName ? Colors.white : Colors.blue;
  }

  Widget _buildButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: 120, // Set the fixed width for each button
      height: 50, // Set the fixed height for each button
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _getButtonColor(label),
          textStyle: TextStyle(color: _getTextColor(label)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Optional: rounded corners
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(color: _getTextColor(label)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildButton("Today", _setToday),
                _buildButton("Next Monday", _setNextMonday),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildButton("Next Tuesday", _setNextTuesday),
                _buildButton("After 1 week", _setAfterOneWeek),
              ],
            ),
            const SizedBox(height: 16),
            CalendarDatePicker(
              initialDate: selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2101),
              onDateChanged: (date) {
                _setDate(date, "");
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_month,color: Colors.blue,),
                    Text(
                      DateFormat('dd MMM yyyy').format(selectedDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(selectedDate),
                      style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blue),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

