import 'package:employee_management/employee_database.dart';
import 'package:employee_management/models/employee.dart';
import 'package:employee_management/widgets/date_picker.dart';
import 'package:employee_management/widgets/no_date_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class EditEmployeeScreen extends ConsumerStatefulWidget {
  final Employee employee;
  const EditEmployeeScreen({super.key,required this.employee});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EditEmployeeScreenState();
}

class _EditEmployeeScreenState extends ConsumerState<EditEmployeeScreen> {
  final TextEditingController _nameController = TextEditingController();
  DateTime? _endDate;
  String _selectedRole = "Select role";
  DateTime? selectedDate;
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.employee.name;
    _selectedRole = widget.employee.position;
    startDateController.text = widget.employee.startDate;
    endDateController.text = widget.employee.endDate ?? '';
  }


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

  Future<void> _updateEmployee() async {
    // Update the employee in the database
    await EmployeeDatabase.instance.updateEmployeeEndDate(widget.employee.id!,endDateController.text.trim());

    // Go back to the previous screen
    Navigator.pop(context, true); // Pass true to indicate an update
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
            onPressed: _updateEmployee,
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