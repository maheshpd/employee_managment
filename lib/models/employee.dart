class Employee {
  final int? id;
  final String name;
  final String position;
  final String startDate;
  final String? endDate; // Nullable field for previous employees

  Employee({
    this.id,
    required this.name,
    required this.position,
    required this.startDate,
    this.endDate,
  });

  // Convert Employee to Map for SQLite insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'startDate': startDate,
      'endDate': endDate,
    };
  }

  // Convert Map to Employee
  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'],
      name: map['name'],
      position: map['position'],
      startDate: map['startDate'],
      endDate: map['endDate'],
    );
  }

  // Helper method to check if the employee is current
  bool get isCurrentEmployee => endDate == null;

  // Helper method to check if the employee is previous
  bool get isPreviousEmployee => endDate != null;
}
