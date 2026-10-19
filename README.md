# NovaWallet Mobile — Send & Save

FirstBank NovaPay take-home: Flutter app for wallet home, P2P send, NovaSave goals, and offline-first sync with idempotent replay.

**Verified environment:** Flutter **3.47.1** · Dart **3.13.1** (run `flutter --version` on your machine).

## Run

```bash
flutter pub get
flutter gen-l10n   # if l10n files are missing
flutter run
```

## Tests

```bash
flutter test --concurrency=1
flutter test integration_test/offline_queue_sync_test.dart
```

Golden update when UI changes:

```bash
flutter test test/goldens/wallet_home_golden_test.dart --update-goldens
```

## Architecture

- **State management:** GetX (`GetxService` for sync, feature bindings for controllers).
- **Layers:** `presentation` → `domain` (validators, interfaces) → `data` (mock API + encrypted Hive).
- **Routing:** [`lib/core/routes/app_pages.dart`](lib/core/routes/app_pages.dart) composes module route lists.
- **Money:** Integer **kobo** everywhere; [`lib/core/money/kobo.dart`](lib/core/money/kobo.dart) parses `"1,500.50"` without double ledger math.
- **Available balance:** `ledger − sum(active queue amounts)` via [`BalanceService`](lib/core/money/balance_service.dart) — not a separate hold map.
- **Offline queue:** Persisted in encrypted Hive; [`SyncController`](lib/core/offline/sync_controller.dart) recovers `processing` → `pending`, single-flight sync, idempotent mock API keys.
- **Connectivity:** `connectivity_plus` is a hint only; unreachable API errors enqueue or retry.
- **Security:** Hive boxes use `HiveAesCipher` (key in `flutter_secure_storage`); mock auth token never in SharedPreferences. Android `minSdk 23`.

## Trade-offs

- **No cross-box transactions:** Wallet, queue, and API state boxes are updated sequentially — a crash could leave rare inconsistency (mitigated by queue recovery + idempotency).
- **Single device:** Queue is local; no multi-device sync.
- **On-device mock server:** No real NIBSS/CBN integration; behavior is simulated for the take-home.

## With more time

- Real HTTP client with Dio, retry policies, and certificate pinning.
- Workmanager / background sync on Android.
- Multi-device queue reconciliation and server-authoritative balance.
- Full localization and analytics.

## Assumptions

- Fictional NovaPay branding.
- Debug panel (long-press title on wallet home) for interview demos — `kDebugMode` only.

## AI usage

See [AI_USAGE.md](AI_USAGE.md).
