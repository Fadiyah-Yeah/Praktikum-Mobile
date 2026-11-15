# Rick & Morty Explorer — SQLite

Run `flutter pub get` then `flutter run`. No `.env`, Supabase, URL, or API key required.

SQLite stores local user accounts, password hashes, usernames, and favorite character IDs.
Character and episode information comes from the public Rick and Morty API, so internet
access is required for those screens. Accounts/favorites are local to the device and do
not synchronize. Clearing app data or uninstalling may delete them.

Passwords use per-user random salt + SHA-256 for this classroom/demo app; this is not
a replacement for production-grade authentication.

Structure: `lib/core`, `lib/models`, `lib/providers`, `lib/screens`, `lib/services`, `lib/widgets`.
