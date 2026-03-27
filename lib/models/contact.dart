class Contact {
  final int? id;
  final String name;
  final String phone;
  final String email;
  final String? photoPath;
  final DateTime createdAt;

  const Contact({
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
    Object? photoPath = _noPhotoPathValue,
    DateTime? createdAt,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      photoPath: photoPath == _noPhotoPathValue
          ? this.photoPath
          : photoPath as String?,
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
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String,
      photoPath: map['photoPath'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

const Object _noPhotoPathValue = Object();