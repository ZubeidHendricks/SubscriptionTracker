# SubscriptionTracker

Generated from niche `subscription-tracker` (Finance, tier A, score 76).

**Utility:** Track recurring subs, get renewal reminders
**Primary ASO keyword:** `subscription tracker`
**Also target:** `manage subscriptions`, `bill reminder`, `recurring payments`, `cancel subscription`
**Paywall hook:** Unlimited subs, reminders, spend insights

> No API cost. Anxiety-driven purchase. Great widget hook.

## Build it

```bash
brew install xcodegen        # once
cd SubscriptionTracker
xcodegen generate
open SubscriptionTracker.xcodeproj
```

The app runs immediately on a MockPurchaseProvider (real paywall UI, fake
purchases). To go live:

1. Replace `revenueCatKey` in `Sources/App.swift` with your RevenueCat key.
2. In App Store Connect create products `subscription-tracker_yearly` and `subscription-tracker_weekly`,
   map them into a RevenueCat offering, entitlement id `premium`.
3. Build the real feature in `Sources/ContentView.swift`.
4. **Guideline 4.3:** make the function, UI, screenshots and keywords genuinely
   distinct from any sibling app. Re-niche, never reskin.

Bundle id: `com.zubeid.subscriptiontracker`

## Engagement (see ../PLAYBOOK.md)

Mechanic: **competence feedback** only (max-2 rule). Deleting a subscription
accumulates its monthly cost into a persisted lifetime "Saved $X/mo by
cancelling" figure (guarded against double-counting) shown above the spend
totals. Real money saved, never app opens. No points, badges, or leaderboards.

## Ship to TestFlight

This app ships with a Fastlane lane + GitHub Actions workflow. One-time account
setup (API key, signing) is documented in the kit's `Tools/appgen/DEPLOYMENT.md`.
Once your GitHub secrets are set, trigger the **TestFlight** workflow (or push a
`v*` tag), or run locally:

```bash
bundle install
bundle exec fastlane beta
```
