/// Model representasi record koleksi `app_config` di PocketBase.
class AppConfig {
  final String latestVersion;
  final String minimumVersion;
  final bool forceUpdate;
  final String updateMessage;
  final String apkUrl;
  final bool isMaintenance;
  final String maintenanceMessage;

  const AppConfig({
    required this.latestVersion,
    required this.minimumVersion,
    required this.forceUpdate,
    required this.updateMessage,
    required this.apkUrl,
    required this.isMaintenance,
    required this.maintenanceMessage,
  });

  factory AppConfig.fromMap(Map<String, dynamic> map) {
    return AppConfig(
      latestVersion: map['latest_version'] as String? ?? '1.0.0',
      minimumVersion: map['minimum_version'] as String? ?? '1.0.0',
      forceUpdate: map['force_update'] as bool? ?? false,
      updateMessage: map['update_message'] as String? ??
          'Versi baru CookSnap tersedia.',
      apkUrl: map['apk_url'] as String? ?? '',
      isMaintenance: map['is_maintenance'] as bool? ?? false,
      maintenanceMessage: map['maintenance_message'] as String? ??
          'Server sedang dalam perbaikan. Silakan coba lagi nanti.',
    );
  }
}
