class UserModel {
  final String id;
  final String username;
  final String email;
  final String name;
  final String avatar;
  final bool isPremium;
  final DateTime? premiumUntil;
  final int dailyScanCount;
  final String lastScanDate;
  final List<String> pantry;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.name,
    required this.avatar,
    this.isPremium = false,
    this.premiumUntil,
    this.dailyScanCount = 0,
    this.lastScanDate = '',
    this.pantry = const [],
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      avatar: map['avatar'] ?? '',
      isPremium: map['is_premium'] ?? false,
      premiumUntil: map['premium_until'] != null && map['premium_until'].toString().isNotEmpty 
          ? DateTime.tryParse(map['premium_until']) 
          : null,
      dailyScanCount: map['daily_scan_count'] ?? 0,
      lastScanDate: map['last_scan_date'] ?? '',
      pantry: _parsePantryIds(map['pantry']),
    );
  }

  /// PocketBase `pantry` is a relation — usually IDs, sometimes expanded records.
  static List<String> _parsePantryIds(dynamic raw) {
    if (raw == null) return const [];
    if (raw is String) return raw.isEmpty ? const [] : [raw];
    if (raw is! List) return const [];
    return raw
        .map((e) {
          if (e is String) return e;
          if (e is Map) {
            final id = e['id'];
            if (id is String) return id;
          }
          return null;
        })
        .whereType<String>()
        .toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'name': name,
      'avatar': avatar,
      'is_premium': isPremium,
      'premium_until': premiumUntil?.toIso8601String() ?? '',
      'daily_scan_count': dailyScanCount,
      'last_scan_date': lastScanDate,
      'pantry': pantry,
    };
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? name,
    String? avatar,
    bool? isPremium,
    DateTime? premiumUntil,
    int? dailyScanCount,
    String? lastScanDate,
    List<String>? pantry,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      isPremium: isPremium ?? this.isPremium,
      premiumUntil: premiumUntil ?? this.premiumUntil,
      dailyScanCount: dailyScanCount ?? this.dailyScanCount,
      lastScanDate: lastScanDate ?? this.lastScanDate,
      pantry: pantry ?? this.pantry,
    );
  }
}
