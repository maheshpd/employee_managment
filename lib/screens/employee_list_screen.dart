import 'package:employee_management/employee_database.dart';
import 'package:employee_management/models/employee.dart';
import 'package:employee_management/screens/add_edit_employee_screen.dart';
import 'package:employee_management/screens/edit_employee_screen.dart';
import 'package:flutter/material.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  // Declare the lists to hold current and previous employees
  Future<List<Employee>> currentEmployees =
      EmployeeDatabase.instance.getCurrentEmployees();
  Future<List<Employee>> previousEmployees =
      EmployeeDatabase.instance.getPreviousEmployees();

  @override
  void initState() {
    super.initState();
    // loadEmployees();
  }

  Future<void> deleteEmployee(int id) async {
    await EmployeeDatabase.instance.deleteEmployee(id);
    setState(() {
      currentEmployees = EmployeeDatabase.instance.getCurrentEmployees();
      previousEmployees = EmployeeDatabase.instance.getPreviousEmployees();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee List'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder(
        future: Future.wait([currentEmployees, previousEmployees]),
        builder: (context, AsyncSnapshot<List<List<Employee>>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentList = snapshot.data![0];
          final previousList = snapshot.data![1];

          // Check if both current and previous employees lists are empty
          if (currentList.isEmpty && previousList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Placeholder Image
                  Image.asset(
                    'assets/no.png', // Replace with your image path
                    height: 150,
                  ),
                  const SizedBox(height: 16),

                  // No Records Text
                  const Text(
                    'No employee records found',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
            );
          }

          return ListView(
            children: [
              // Current Employees Section
              if (currentList.isNotEmpty)
                const ListTile(
                  title: Text("Current employees",
                      style: TextStyle(color: Colors.blue)),
                ),
              ...currentList.map((employee) => Dismissible(
                    key: Key(employee.id.toString()),
                    onDismissed: (diraction) {
                      // Save the employee data temporarily to restore if needed
                      final removedEmployee = employee;

                      // Delete the employee from the database
                      setState(() {
                        deleteEmployee(employee.id!);
                      });
                      

                      // Show a SnackBar with an Undo option
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${employee.name} dismissed"),
                          action: SnackBarAction(
                            label: "Undo",
                            textColor: Colors.white,
                            onPressed: () {
                              // Re-add the employee to the database
                              EmployeeDatabase.instance
                                  .insertEmployee(removedEmployee);
                              // Reload the employee lists to reflect the undo
                              setState(() {
                                currentEmployees = EmployeeDatabase.instance
                                    .getCurrentEmployees();
                                previousEmployees = EmployeeDatabase.instance
                                    .getPreviousEmployees();
                              });
                            },
                          ),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: ListTile(
                      title: Text(employee.name),
                      subtitle: Text(
                          "${employee.position}\nFrom ${employee.startDate}"),
                      onTap: () async {
                        // Navigate to edit screen and wait for the result
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditEmployeeScreen(employee: employee),
                          ),
                        );

                        // If result is true, reload employees list
                        if (result == true) {
                          setState(() {
                            // reload employee lists to reflect updates
                            currentEmployees =
                                EmployeeDatabase.instance.getCurrentEmployees();
                            previousEmployees = EmployeeDatabase.instance
                                .getPreviousEmployees();
                          });
                        }
                      },
                    ),
                  )),

              // Previous Employees Section
              if (previousList.isNotEmpty)
                const ListTile(
                  title: Text("Previous employees",
                      style: TextStyle(color: Colors.blue)),
                ),
              ...previousList.map((employee) => Dismissible(
                    key: Key(employee.id.toString()),
                    onDismissed: (diraction) {
                      // Save the employee data temporarily to restore if needed
                      final removedEmployee = employee;

                      // Delete the employee from the database
                      setState(() {
                         deleteEmployee(employee.id!);
                      });
                     

                      // Show a SnackBar with an Undo option
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${employee.name} dismissed"),
                          action: SnackBarAction(
                            label: "Undo",
                            textColor: Colors.white,
                            onPressed: () {
                              // Re-add the employee to the database
                              EmployeeDatabase.instance
                                  .insertEmployee(removedEmployee);
                              // Reload the employee lists to reflect the undo
                              setState(() {
                                currentEmployees = EmployeeDatabase.instance
                                    .getCurrentEmployees();
                                previousEmployees = EmployeeDatabase.instance
                                    .getPreviousEmployees();
                              });
                            },
                          ),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: ListTile(
                      title: Text(employee.name),
                      subtitle: Text(
                        "${employee.position}\nFrom ${employee.startDate} - ${employee.endDate ?? ''}",
                      ),
                    ),
                  )),
            ],
          );
        },
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: GestureDetector(
          onTap: () async {
            final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AddEmployeeDetailsScreen()));
            // If result is `true`, refresh the employee list
            if (result == true) {
              setState(() {
                // Reload the employee lists from the provider
                currentEmployees =
                    EmployeeDatabase.instance.getCurrentEmployees();
                previousEmployees =
                    EmployeeDatabase.instance.getPreviousEmployees();
              });
            }
          },
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
                color: Colors.blue, borderRadius: BorderRadius.circular(12)),
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
