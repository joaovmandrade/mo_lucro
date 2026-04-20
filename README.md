# Mo Lucro

Flutter app using Supabase authentication only.

## Stack

- Flutter
- `supabase_flutter`

## Supabase

- URL: `https://mmtaolgmadsqhlsmmixa.supabase.co`
- Anon key: expected through `SUPABASE_ANON_KEY`

## Run

```bash
cd mo_lucro_app
flutter pub get
flutter run --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

## Current flow

- App starts and initializes Supabase
- If a session already exists, user goes directly to `HomePage`
- If there is no session, user sees `LoginPage`
- Login uses `signInWithPassword`
- Logout uses `signOut`
- Session persistence is handled by `supabase_flutter`
