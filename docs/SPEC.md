# Grid Logic Product Spec

## 1. Product Identity
**Category:** Logic Game
**Target Stack:** Flutter + Flame Engine (2D)
**Monetization:** Hybrid — AdMob (Interstitials + Rewarded Video) + IAP (Remove Ads, Cosmetics). Free to play.

## 2. Core Concept
Einstein's riddle logic deduction. 5 houses, 5 colors, who owns the fish?
**The LLM Advantage:** Flutter is compiled directly to native code via Impeller, guaranteeing 60-120fps and beautiful 2D rendering. The Flame engine is 100% code-driven (no visual editor), meaning LLMs can generate the entire game architecture, physics (Forge2D), and particle systems purely via text/Dart code.

## 3. Core Mechanics
Constraint satisfaction algorithm generating valid clues for a given truth matrix.

## 4. Monetization Strategy
- **Interstitials:** Shown every 3-5 levels or deaths (frequency capped to avoid instant churn).
- **Rewarded Video:** Watch ad to get a hint, skip a level, or revive.
- **Remove Ads IAP ($2.99):** Non-consumable. Removes interstitials and banners. Rewarded video stays (opt-in). Expected 3-5% conversion of D7 retained users.
- **Theme Pack IAP ($0.99):** Non-consumable cosmetic pack (dark mode, neon, pastel). Expected 2-4% conversion.
