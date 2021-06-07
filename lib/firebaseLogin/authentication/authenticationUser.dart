//-----------------------------------------------------------------------------
// class User
//-----------------------------------------------------------------------------
class AuthenticationUser {
  const AuthenticationUser({required this.id, this.email, this.name, this.photo});
  static const empty = AuthenticationUser(id: ''); // empty representa un usuari no autenticat.

  final String? email;
  final String id;
  final String? name;
  final String? photo;

  bool get isEmpty => this == AuthenticationUser.empty;
  bool get isNotEmpty => this != AuthenticationUser.empty;
}

//-----------------------------------------------------------------------------
// class CacheUser
//-----------------------------------------------------------------------------
class CacheUser {
  CacheUser() : _cache = <String, Object>{};

  final Map<String, Object> _cache;

  void write<T extends Object>({required String key, required T value}) {
    _cache[key] = value;
  }

  T? read<T extends Object>({required String key}) {
    final value = _cache[key];
    if (value is T) return value;
    return null;
  }
}
