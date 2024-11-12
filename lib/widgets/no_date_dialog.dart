import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NoDateSelection extends StatefulWidget {
  const NoDateSelection({super.key});

  @override
  State<NoDateSelection> createState() => _NoDateSelectionState();
}

class _NoDateSelectionState extends State<NoDateSelection> {
  DateTime selectedDate = DateTime.now();
  bool isTodaySelected = true; // Track if the "Today" button is selected
  bool isNoDateSelected = false; // Track if the "No Date" button is selected

  void _selectToday() {
    setState(() {
      selectedDate = DateTime.now();
      isTodaySelected = true;
      isNoDateSelected = false;
    });
  }

  void _clearDate() {
    setState(() {
      isNoDateSelected = true;
      isTodaySelected = false;
    });
  }

 
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: 120,
                  child: TextButton(
                    onPressed: _clearDate,
                    style: TextButton.styleFrom(
                      backgroundColor:
                          isNoDateSelected ? Colors.blue : Colors.grey[300],
                      foregroundColor:
                          isNoDateSelected ? Colors.white : Colors.blue,
                    ),
                    child: const Text("No date"),
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: TextButton(
                    onPressed: _selectToday,
                    style: TextButton.styleFrom(
                      backgroundColor:
                          isTodaySelected ? Colors.blue : Colors.grey[300],
                      foregroundColor:
                          isTodaySelected ? Colors.white : Colors.blue,
                    ),
                    child: const Text("Today"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CalendarDatePicker(
              initialDate: selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
              onDateChanged: (date) {
                setState(() {
                  selectedDate = date;
                  isTodaySelected = false;
                  isNoDateSelected = false;
                });
              },
              selectableDayPredicate: (day) => true,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month,
                      color: Colors.blue,
                    ),
                    Text(
                      isNoDateSelected
                          ? 'No date'
                          : DateFormat('dd MMM yyyy').format(selectedDate),
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
                      onPressed: () => Navigator.of(context)
                          .pop(isNoDateSelected ? null : selectedDate),
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


