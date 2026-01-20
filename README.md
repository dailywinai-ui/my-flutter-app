# Win Daily (Flutter)
Win Daily is a Flutter app backed by Supabase. It helps busy professionals capture **one win per day** to reduce forgetfulness, build momentum, and create a living archive of their progress.
**Primary branch:** `redesign-sage-green`

## What the app does
Win Daily makes it easy to:
- Sign in / sign up
- Log a daily “win”
- Review wins over time (history/reflection)
- Update basic profile/settings

### Why it exists / problem it solves
When life gets busy, progress becomes invisible. Win Daily helps you pause, recognize your progress, and stay an active participant in your own life by keeping a lightweight record of your wins.

### Key features (at a glance)
- ✅ Supabase Auth (sign in / sign up)
- ✅ Daily win logging
- ✅ History view
- ✅ Settings/Profile
- ✅ TestFlight distribution for iOS testing

## Prerequisites / Requirements
### Required software
- Flutter SDK (stable recommended)
- Dart (bundled with Flutter)
- Git

### Platform requirements
- **iOS local builds:** macOS + Xcode
- **Android builds:** Android Studio + SDK
- **Web:** any OS with a modern browser

Verify:
```bash
flutter --version
flutter doctor
ecurity / Key Handling (Read this first)

This repo intentionally does not commit secrets.

❌ Do not commit env.json, keys, tokens, or credentials.

❌ Do not paste keys into PRs, issues, or logs.

✅ env.json is local-only and gitignored.

✅ If keys are ever exposed, notify the maintainer so keys can be rotated.
Redaction rule: Anything that looks like a token (often starts with eyJ...) must be redacted before sharing.

Installation / Setup (Local Development)
1) Clone and checkout the correct branch
git clone https://github.com/dailywinai-ui/my-flutter-app.git
cd my-flutter-app
git checkout redesign-sage-green

2) Install dependencies
flutter clean
flutter pub get

Environment Configuration (Supabase)

Authentication and data access require Supabase runtime values:

SUPABASE_URL

SUPABASE_ANON_KEY (anon public key)

Create local env file
cp env.example.json env.json


Edit env.json with values provided privately by the maintainer:

{
  "SUPABASE_URL": "https://<project-ref>.supabase.co",
  "SUPABASE_ANON_KEY": "<anon-public-key>"
}


Notes:

Keep quotes "" — JSON strings require quotes.

Use the anon public key (never service role in client apps).

Usage
Run (Web)

Recommended for local review/debug:

./run_web.sh


run_web.sh reads env.json and runs Flutter with the correct --dart-define values.

Run (iOS) (macOS only)
flutter run


If you want explicit env passing (optional):

flutter run \
  --dart-define=SUPABASE_URL="$(python3 -c "import json;print(json.load(open('env.json'))['SUPABASE_URL'])")" \
  --dart-define=SUPABASE_ANON_KEY="$(python3 -c "import json;print(json.load(open('env.json'))['SUPABASE_ANON_KEY'])")"

Run (Android)
flutter devices
flutter run -d android \
  --dart-define=SUPABASE_URL="$(python3 -c "import json;print(json.load(open('env.json'))['SUPABASE_URL'])")" \
  --dart-define=SUPABASE_ANON_KEY="$(python3 -c "import json;print(json.load(open('env.json'))['SUPABASE_ANON_KEY'])")"

Developer Reviewer Setup
Recommended: TestFlight

TestFlight is the most reliable functional verification path:

real device behavior

consistent builds

avoids local signing/provisioning friction

If you are a reviewer:

Accept App Store Connect invite

Install from TestFlight

Validate core flows (see checklist below)

Local debugging (for developers)

Local debugging is supported; Supabase must be configured via env.json (see above).

✅ What to Test (Reviewer Checklist)

Please run through these flows and report issues with clear repro steps and relevant logs (redact keys/tokens).

Install + Launch

App launches cleanly (no blank screen / error overlay)

Splash/auth routing behaves correctly

Authentication

Sign in using demo credentials (shared privately), or sign up (if enabled)

Validation: invalid email / short password shows proper errors

Log out → log back in

Core feature: Daily Wins

Create a Win

Win appears on Today screen immediately

Win appears in History

Force close app → reopen → data persists

Settings / Profile

Update profile fields (if present)

Privacy policy link opens correctly (if present)

Sign out works

Password recovery (optional but recommended)

Trigger “Forgot password”

Confirm reset flow behaves as expected

When reporting issues, include:

device + OS version (or web + browser)

build number (TestFlight)

steps to reproduce

relevant logs (redact tokens/keys)

Project Structure (high-level)

lib/ — Flutter source

main.dart — app entry + Supabase initialization

services/ — Auth/Supabase services

presentation/ — screens/views

widgets/ — shared widgets

utils/ — helpers/utilities

assets/ — images/SVGs

ios/, android/ — native platform folders

codemagic.yaml — CI/CD configuration

env.example.json — env template (safe)

env.json — local env (gitignored)

run_web.sh — local web launcher (safe)

Technologies Used

Flutter / Dart

Supabase (Auth + database)

flutter_svg

shared_preferences

Codemagic (CI/CD)

TestFlight (iOS testing)

Troubleshooting / FAQ
“Supabase not initialized”

Errors like:

“You must initialize the supabase instance before calling Supabase.instance”

“SUPABASE_URL and SUPABASE_ANON_KEY must be defined…”
Fix:

ensure env.json exists with real values

run via ./run_web.sh

“ClientFailed to fetch … auth/v1/...”

Causes:

wrong Supabase URL/key

project paused/inactive

network/DNS issue
Fix:

verify project is active

verify URL/key match the same project

Web build fails with “No space left on device”

Fix:

df -h
flutter clean
rm -rf build .dart_tool
rm -rf /tmp/flutter_tools.*

Testing
flutter analyze
flutter test

Deployment / Releases

iOS builds produced via Codemagic

Distributed via TestFlight

App Store submission handled in App Store Connect

Contributing (optional)

Create a branch from redesign-sage-green

Keep PRs small and focused

Follow Flutter lint/style

Do not commit secrets (env.json, tokens, etc.)

License

TBD. If pre-launch, keep this repo private and treat as proprietary until you choose a license.

Contact / Support

Maintainer: Christine
Repo issues: GitHub Issues (preferred)
