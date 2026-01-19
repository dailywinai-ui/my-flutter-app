#!/usr/bin/env bash
set -euo pipefail

if [ ! -f env.json ]; then
  echo "Missing env.json. Copy env.example.json -> env.json and fill SUPABASE values."
  exit 1
fi

SUPABASE_URL="$(python3 -c "import json;print(json.load(open('env.json'))['SUPABASE_URL'])")"
SUPABASE_ANON_KEY="$(python3 -c "import json;print(json.load(open('env.json'))['SUPABASE_ANON_KEY'])")"

flutter run -d chrome \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"
