# Grid Logic Architecture

## System Context
- **Framework:** Flutter + Flame Engine
- **State Management:** Flutter Riverpod / Provider
- **Persistence:** shared_preferences or sqflite for high scores.
- **Ads:** `google_mobile_ads` + `app_tracking_transparency` (iOS ATT) + UMP consent via google_mobile_ads built-in.

## Zero-Backend Philosophy
There are no servers. All levels are generated procedurally on the device or loaded from bundled JSON files. High scores are local. This guarantees $0 operational costs.
