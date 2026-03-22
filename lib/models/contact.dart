class Contact {
  final int? id;
  final String name;
  final String phone;
  final String email;
  final String? photoPath;
  final DateTime createdAt;

  Contact({
    this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.photoPath,
    required this.createdAt,
  });

  Contact copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    String? photoPath,
    DateTime? createdAt,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      photoPath: photoPath ?? this.photoPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'photoPath': photoPath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      email: map['email'],
      photoPath: map['photoPath'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}