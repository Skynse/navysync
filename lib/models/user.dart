class NavySyncUser {
  final String id;
  final String profilePictureUrl;
  final String name;
  final String role; // 'admin', unassigned',

  NavySyncUser({
    required this.id,
    required this.profilePictureUrl,
    required this.name,
    required this.role, // 'admin', 'unassigned', etc.
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profilePictureUrl': profilePictureUrl,
      'name': name,
      'role': role,
    };
  }

  factory NavySyncUser.fromMap(Map<String, dynamic> map) {
    return NavySyncUser(
      id: map['id'] ?? '',
      profilePictureUrl: map['profilePictureUrl'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'unassigned', // default to 'unassigned'
    );
  }
}
