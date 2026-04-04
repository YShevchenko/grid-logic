
# Codex Review — Grid Logic

## Product & Documentation Alignment
- Einstein's riddle logic deduction. 5 houses, 5 colors, who owns the fish? **Interstitials:** Shown every 3-5 levels or deaths (frequency capped to avoid instant churn).
- **Primary:** TikTok Ads and Meta (Facebook/Instagram).

## Code & QA Observations
- The Flutter stack still relies on the shared SettingsService/AdService/IAPService templates. `AdService` initializes ATT/UMP but the gameplay code never calls `showInterstitialAd()` or `showRewardedAd()` and rewarded ads are never preloaded, so the monetization channel described in the spec never executes.
- `IAPService` is still the template stub: `_addHints()` is unimplemented, no UI calls the class, and `SettingsScreen` exposes no remove-ads/theme purchase, so the one-time purchases are unreachable.
- The tests still assert generic menu text ("Jump over obstacles!", etc.), so none of the TC-* scenarios in `docs/TEST-PLAN.md` are covered. Replace them with game-specific expectations.

## Marketing & Revenue Risks
- The UA plan leans on TikTok/Meta creatives but lacks CPI/LTV targets, budgets, and instrumentation. Without ad/purchase hooks, marketing cannot verify whether the proposed hook resonates in the Tier 1/Tier 3 geos described in the doc.

## Next Steps
1. Wire explicit ad calls into the level completion/failure flows, preload rewarded ads, and offer a rewarded retry/hint so the monetization stack can earn from interstitials and rewards.
2. Surface the remove-ads/cosmetic IAPs in the UI (and implement `_addHints()` if a hint mechanic exists) so purchases can be triggered and observed.
3. Rewrite the automated tests to match the actual menu text, gameplay strings, and monetization flows instead of copying template expectations.
4. Record FirebaseAnalytics events for level_complete, ad_impression, and iap_purchase so UA budgets can be tied to the Tier 1/Tier 3 funnels the marketing doc describes.
5. Align the code with the spec’s core concept (if the spec calls for arcs/dunes, ship them; otherwise update the docs to describe the shipped obstacle runner).
