# Win Daily

Win Daily is a calm journaling app for iOS that helps you notice your own life before it passes you by. One win a day. Private. No streaks, no guilt, no audience. Just an archive of the days you showed up.

**Live on the App Store** → [windaily.ca](https://windaily.ca)

## What the app does

- Log one daily win — what actually happened, not the highlight reel
- Reflect with optional mood tracking and reflection prompts
- Browse your history on a calendar view with win dots
- See insights — stats, mood patterns, and your personal trends
- Create and share win cards
- Edit and revisit past wins

## Why it exists

When life gets busy, progress becomes invisible. Social media shows you the finish line — never the gap between the intent and the result. Win Daily captures that gap. The 5-minute run. The hard day you showed up anyway. The conversation that reminded you that you were alive.

Win Daily is a place to reconnect with what makes us human. The everyday moments we often forget but when compounded over time become an archive of a life well lived.

## Tech stack

- **Flutter / Dart** — cross-platform app framework
- **Supabase** — authentication and database
- **Codemagic** — CI/CD pipeline
- **App Store** — iOS distribution (live)
- **Google Play Store** — Android distribution (coming soon)

## Branching

- `main` — production, always matches the live App Store build
- `dev` — active development, features and fixes land here first

## Local development

### Prerequisites

- Flutter SDK (stable)
- Dart (bundled with Flutter)
- Git
- macOS + Xcode (for iOS builds)
- Android Studio + SDK (for Android builds)

Verify your setup:

```bash
flutter --version
flutter doctor
```

### Setup

```bash
git clone https://github.com/dailywinai-ui/my-flutter-app.git
cd my-flutter-app
git checkout dev
flutter clean
flutter pub get
```

### Environment configuration

Authentication and data access require Supabase runtime values. Create a local env file:

```bash
cp env.example.json env.json
```

Edit `env.json` with values provided privately by the maintainer:

```json
{
  "SUPABASE_URL": "https://<project-ref>.supabase.co",
  "SUPABASE_ANON_KEY": "<anon-public-key>"
}
```

Use the anon public key — never the service role key in client apps.

### Running the app

**Web (recommended for local review):**

```bash
./run_web.sh
```

**iOS (macOS only):**

```bash
flutter run
```

**Android:**

```bash
flutter run -d android \
  --dart-define=SUPABASE_URL="$(python3 -c "import json;print(json.load(open('env.json'))['SUPABASE_URL'])")" \
  --dart-define=SUPABASE_ANON_KEY="$(python3 -c "import json;print(json.load(open('env.json'))['SUPABASE_ANON_KEY'])")"
```

## Security

This repo intentionally does not commit secrets.

- `env.json` is local-only and gitignored
- Do not commit keys, tokens, or credentials
- Do not paste keys into PRs, issues, or logs
- If keys are ever exposed, rotate them immediately
- Anything that looks like a token (often starts with `eyJ...`) must be redacted before sharing

## Project structure

```
lib/
  main.dart              — app entry + Supabase initialization
  services/              — auth and Supabase services
  presentation/          — screens and views
  widgets/               — shared widgets
  utils/                 — helpers and utilities
assets/                  — images, SVGs, fonts
ios/, android/           — native platform folders
codemagic.yaml           — CI/CD configuration
env.example.json         — env template (safe to commit)
env.json                 — local env (gitignored)
run_web.sh               — local web launcher
```

## Deployment

- iOS builds produced via Codemagic
- Distributed through the App Store
- Android builds via Codemagic (in progress)

## Troubleshooting

**"Supabase not initialized"**

Ensure `env.json` exists with real values and run via `./run_web.sh`.

**"Failed to fetch auth/v1/..."**

Verify your Supabase project is active and the URL/key match the same project.

**"No space left on device"**

```bash
flutter clean
rm -rf build .dart_tool
rm -rf /tmp/flutter_tools.*
```

## Contributing

1. Create a branch from `dev`
2. Keep PRs small and focused
3. Follow Flutter lint/style
4. Do not commit secrets

## License

Proprietary. All rights reserved.

## Contact

Maintainer: Christine Izerek
Website: [windaily.ca](https://windaily.ca)
