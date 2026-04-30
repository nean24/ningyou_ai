/// Represents an authenticated or anonymous application user.
class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.isAnonymous,
    this.email,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String? email;
  final String? avatarUrl;
  final bool isAnonymous;

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    bool? isAnonymous,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }

  @override
  String toString() =>
      'AppUser(id: $id, name: $name, isAnonymous: $isAnonymous)';
}
