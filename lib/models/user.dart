/// Represents a student user account in Souq.
class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.studentId,
    this.phone = '',
    this.iban = '',
  });

  final String id;
  final String name;
  final String email;
  final String studentId;
  final String phone;
  final String iban;

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? studentId,
    String? phone,
    String? iban,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      studentId: studentId ?? this.studentId,
      phone: phone ?? this.phone,
      iban: iban ?? this.iban,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'studentId': studentId,
      'phone': phone,
      'iban': iban,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      studentId: map['studentId'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      iban: map['iban'] as String? ?? '',
    );
  }
}
