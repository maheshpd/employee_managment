import 'package:employee_management/models/employee.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'employee_database.dart';

// EmployeeState class to represent different states of employee data
class EmployeeState {
  final List<Employee> currentEmployees;
  final List<Employee> previousEmployees;
  final bool isLoading;
  final String? error;

  EmployeeState({
    required this.currentEmployees,
    required this.previousEmployees,
    this.isLoading = false,
    this.error,
  });

  // Copy constructor for updating state
  EmployeeState copyWith({
    List<Employee>? currentEmployees,
    List<Employee>? previousEmployees,
    bool? isLoading,
    String? error,
  }) {
    return EmployeeState(
      currentEmployees: currentEmployees ?? this.currentEmployees,
      previousEmployees: previousEmployees ?? this.previousEmployees,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// EmployeeNotifier to manage employee operations
class EmployeeNotifier extends StateNotifier<EmployeeState> {
  final EmployeeDatabase _db = EmployeeDatabase.instance;

  EmployeeNotifier() : super(EmployeeState(currentEmployees: [], previousEmployees: []));

  // Fetch current employees from the database
  Future<void> fetchCurrentEmployees() async {
    state = state.copyWith(isLoading: true);
    try {
      final currentEmployees = await _db.getCurrentEmployees();
      state = state.copyWith(currentEmployees: currentEmployees, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Fetch previous employees from the database
  Future<void> fetchPreviousEmployees() async {
    state = state.copyWith(isLoading: true);
    try {
      final previousEmployees = await _db.getPreviousEmployees();
      state = state.copyWith(previousEmployees: previousEmployees, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Add a new employee
  Future<void> addEmployee(Employee employee) async {
    try {
      await _db.insertEmployee(employee);
      // After adding, fetch current employees again
      fetchCurrentEmployees();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Update employee's end date (move to previous employee)
  Future<void> updateEmployeeEndDate(int id, String endDate) async {
    try {
      await _db.updateEmployeeEndDate(id, endDate);
      // After updating, fetch both current and previous employees
      fetchCurrentEmployees();
      fetchPreviousEmployees();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Delete an employee
  Future<void> deleteEmployee(int id) async {
    try {
      await _db.deleteEmployee(id);
      // After deleting, fetch current employees again
      fetchCurrentEmployees();
      fetchPreviousEmployees();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

// Define a provider for EmployeeNotifier
final employeeNotifierProvider =
    StateNotifierProvider<EmployeeNotifier, EmployeeState>((ref) => EmployeeNotifier());
