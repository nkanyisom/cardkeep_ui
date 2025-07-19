class User {
  final String id;
  final String email;
  final DateTime? createdAt;
  final List<String> roles;

  const User({
    required this.id,
    required this.email,
    this.createdAt,
    this.roles = const ['ROLE_USER'],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      email: json['email'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      roles: json['roles'] != null
          ? List<String>.from(json['roles'] as List)
          : const ['ROLE_USER'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'createdAt': createdAt?.toIso8601String(),
      'roles': roles,
    };
  }

  User copyWith({
    String? id,
    String? email,
    DateTime? createdAt,
    List<String>? roles,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      roles: roles ?? this.roles,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.email == email &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(id, email, createdAt);
}
