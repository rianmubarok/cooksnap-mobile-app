# Backup Folder

Folder ini untuk menyimpan file backup PocketBase secara lokal.

## Cara Restore ke Railway

1. Buat backup ZIP dari `pb_data/`:
   ```powershell
   Compress-Archive -Path "..\pb_data\data.db", "..\pb_data\auxiliary.db" -DestinationPath "backup_cooksnap.zip" -Force
   ```

2. Buka admin panel Railway: `https://xxxx.up.railway.app/_/`

3. Settings → Backups → Upload backup → pilih file ZIP → Restore

## ⚠️ Catatan
- File `.zip` di folder ini **tidak akan di-push ke GitHub** (sudah di-ignore)
- Jangan simpan data sensitif lainnya di sini
