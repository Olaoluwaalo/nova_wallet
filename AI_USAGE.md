# AI usage (NovaWallet take-home)

## Tools

- **Cursor (Claude)** — feature scaffolding, offline queue design, hardening pass, tests, README.
- **Flutter analyzer / tests** — catching replay, balance, and validator regressions.

## Prompts (examples)

1. *"Implement persisted offline queue with idempotency keys that survive restart."*  
   **Outcome:** Hive queue + `processing` persisted before API + processed-key set in mock API.

2. *"Harden sync: never skip stuck processing, derive available from queue sum, transient vs permanent errors."*  
   **Outcome:** `recoverStaleProcessing`, `BalanceService`, single-flight `syncPending`, failed row + retry UI.

3. *"Add integration tests for crash mid-processing and concurrent sync."*  
   **Outcome:** [`integration_test/offline_queue_sync_test.dart`](integration_test/offline_queue_sync_test.dart) cases.

## Where AI was wrong (and fix)

**Risk:** Early plan text said to **skip** queue items in `processing` on replay. That would strand sends after a crash mid-flight.

**Catch:** Code review against the take-home brief + writing a “crash mid-processing” integration test.

**Fix:** Only skip `completed`. On startup and before sync, reset `processing` → `pending` and replay with the same idempotency key; server dedupes duplicates.

**Risk:** Separate “hold” map for available balance could drift from the offline queue and allow two offline sends to over-commit.

**Fix:** `available = ledger − sum(pending|processing queue amounts)`; validate on enqueue; ledger check on API debit during replay.

**Risk:** `google_fonts` runtime download breaks offline-first demos.

**Fix:** Bundled Poppins under `assets/fonts/` and `fontFamily: 'Poppins'` in theme.

## Hardening pass (this iteration)

Used AI to draft validators, lifecycle resume (`AppLifecycleSync`), encrypted Hive wiring, and debug panel — verified with `flutter test --concurrency=1`.
