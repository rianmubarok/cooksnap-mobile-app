#!/bin/sh
set -e

# Jika env var superuser tersedia, buat/timpa superuser otomatis saat startup
if [ -n "$PB_SUPERUSER_EMAIL" ] && [ -n "$PB_SUPERUSER_PASSWORD" ]; then
  echo "→ Setting up superuser: $PB_SUPERUSER_EMAIL"
  /pb/pocketbase superuser upsert "$PB_SUPERUSER_EMAIL" "$PB_SUPERUSER_PASSWORD"
  echo "→ Superuser ready."
fi

# Jalankan PocketBase
exec /pb/pocketbase serve --http=0.0.0.0:8080
