import 'package:employee_management/employee_provider.dart';
import 'package:employee_management/models/employee.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:employee_management/widgets/date_picker.dart';
import 'package:employee_management/widgets/no_date_dialog.dart';

class AddEmployeeDetailsScreen extends ConsumerStatefulWidget {
  const AddEmployeeDetailsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddEmployeeDetailsScreenState();
}

class _AddEmployeeDetailsScreenState
    extends ConsumerState<AddEmployeeDetailsScreen> {
  final TextEditingController _nameController = TextEditingController();
  DateTime? _endDate;
  String _selectedRole = "Select role";
  DateTime? selectedDate;
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();

  final List<String> _roles = {
    'Product Designer',
    'Flutter Developer',
    'QA Tester',
    'Product Owner'
  }.toList();

  void showCalendarDialog(BuildContext context) async {
    DateTime? selected = await showDialog<DateTime>(
      context: context,
      builder: (context) => const CalendarDialog(),
    );
    if (selected != null) {
      setState(() {
        selectedDate = selected;
        // Update the TextEditingController with the selected date
        startDateController.text =
            DateFormat('dd MMM yyyy').format(selectedDate!);
      });
    }
  }

  void endCalendarDialog(BuildContext context) async {
    DateTime? selected = await showDialog<DateTime>(
      context: context,
      builder: (context) => const NoDateSelection(),
    );
    if (selected != null) {
      setState(() {
        _endDate = selected;
        // Update the TextEditingController with the selected date
        endDateController.text = DateFormat('dd MMM yyyy').format(_endDate!);
      });
    }
  }

  // Function to show the bottom sheet with options
  void _showRoleBottomSheet() {
    List<String> uniqueRoles = _roles.toSet().toList();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20), // Rounded top corners
        ),
      ),
      builder: (BuildContext context) {
        return SizedBox(
          height: 250,
          child: ListView.builder(
            itemCount: uniqueRoles.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(uniqueRoles[index]),
                onTap: () {
                  setState(() {
                    _selectedRole = uniqueRoles[index];
                  });
                  Navigator.pop(context); // Close the bottom sheet
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Add Employee Details'),
        backgroundColor: Colors.blue,
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.blue),
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          ElevatedButton(
            onPressed: () async {
              final name = _nameController.text;
              final role = _selectedRole;
              final startDate = startDateController.text.trim();
              final endDate = endDateController.text.isNotEmpty
                  ? endDateController.text.trim()
                  : null;
              if (name.isEmpty || role.isEmpty || startDate.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All Field is required'),
                    backgroundColor: Colors.green,
                  ),
                );
                return;
              }

              // Create a new Employee object
              final newEmployee = Employee(
                name: name,
                position: role,
                startDate: startDate,
                endDate: endDate, // Optional for current employee
              );

              // Insert employee into the database using EmployeeDatabase
              try {
                await ref
                    .read(employeeNotifierProvider.notifier)
                    .addEmployee(newEmployee);
                Navigator.pop(context, true);
              } catch (e) {
                // Handle error (show error message)
                print('Error inserting employee: $e');
              }
            },
            style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blue),
            child: const Text('Save'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Employee Name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Employee name',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            GestureDetector(
              onTap: _showRoleBottomSheet,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: _selectedRole,
                  prefixIcon: const Icon(Icons.work),
                  border: const OutlineInputBorder(),
                ),
                child: Text(
                  _selectedRole,
                  style: TextStyle(
                    fontSize: 16,
                    color: _selectedRole == "Select role"
                        ? Colors.grey
                        : Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Date Pickers
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Start Date',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    controller: startDateController, // Use the controller here,
                    readOnly: true,
                    onTap: () => showCalendarDialog(context),
                  ),
                ),
                const SizedBox(width: 16),
                const Text('→'),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'End Date',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    controller: endDateController, // Use the controller here,
                    readOnly: true,
                    onTap: () => endCalendarDialog(context),
                  ),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
