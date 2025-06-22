class NavySyncUser {
  final String id;
  final String profilePictureUrl;
  final String name;
  final List<String> roles;

  NavySyncUser({
    required this.id,
    required this.profilePictureUrl,
    required this.name,
    required this.roles,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profilePictureUrl': profilePictureUrl,
      'name': name,
      'roles': roles, // admin
    };
  }

  factory NavySyncUser.fromMap(Map<String, dynamic> map) {
    return NavySyncUser(
      id: map['id'] ?? '',
      profilePictureUrl: map['profilePictureUrl'] ?? '',
      name: map['name'] ?? '',
      roles: List<String>.from(map['roles'] ?? ['unassigned']),
    );
  }
}
