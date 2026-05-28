import 'package:pocketbase/pocketbase.dart';
import '../models/app_config_model.dart';

/// Mengambil konfigurasi aplikasi dari koleksi `app_config` di PocketBase.
///
/// Koleksi ini bersifat publik (tanpa auth) sehingga bisa dipanggil
/// bahkan sebelum user login — cocok untuk pengecekan di splash screen.
class AppConfigService {
  final PocketBase _pb;

  AppConfigService(this._pb);

  /// Mengambil config pertama dari koleksi `app_config`.
  /// Jika koleksi kosong atau terjadi error, mengembalikan null.
  Future<AppConfig?> fetchConfig() async {
    try {
      final result = await _pb.collection('app_config').getList(
        page: 1,
        perPage: 1,
      );
      if (result.items.isEmpty) return null;
      return AppConfig.fromMap(result.items.first.data);
    } catch (e) {
      // Jika server tidak bisa diakses, biarkan app tetap jalan
      // (degraded mode — tidak blokir user saat offline)
      return null;
    }
  }
}
