import 'package:employee_management/models/employee.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class EmployeeDatabase {
  static final EmployeeDatabase instance = EmployeeDatabase._init();
  static Database? _database;

  EmployeeDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('employee_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // Create the employees table
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE employees(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        position TEXT,
        startDate TEXT,
        endDate TEXT
      )
    ''');
  }

  // Insert a new employee
  Future<int> insertEmployee(Employee employee) async {
    final db = await instance.database;
    return await db.insert('employees', employee.toMap());
  }

  // Get all current employees (no end date)
  Future<List<Employee>> getCurrentEmployees() async {
    final db = await instance.database;
    final maps = await db.query(
      'employees',
      where: 'endDate IS NULL', // Only employees without an end date
    );
    return List.generate(maps.length, (i) {
      return Employee.fromMap(maps[i]);
    });
  }

  // Get all previous employees (with end date)
  Future<List<Employee>> getPreviousEmployees() async {
    final db = await instance.database;
    final maps = await db.query(
      'employees',
      where: 'endDate IS NOT NULL', // Employees with an end date
    );
    return List.generate(maps.length, (i) {
      return Employee.fromMap(maps[i]);
    });
  }

  // Get all employees (current + previous)
  Future<List<Employee>> getAllEmployees() async {
    final db = await instance.database;
    final maps = await db.query('employees');
    return List.generate(maps.length, (i) {
      return Employee.fromMap(maps[i]);
    });
  }

  // Update employee's end date to mark them as a previous employee
  Future<int> updateEmployeeEndDate(int id, String endDate) async {
    final db = await instance.database;
    return await db.update(
      'employees',
      {'endDate': endDate},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete an employee by ID
  Future<int> deleteEmployee(int id) async {
    final db = await instance.database;
    return await db.delete(
      'employees',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Close the database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
