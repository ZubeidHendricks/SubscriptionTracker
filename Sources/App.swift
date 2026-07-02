import SwiftUI
import AppFactoryKit

// Subscription Tracker — payments via native StoreKit 2 (no third-party SDK).
private enum Product {
    static let yearly = "subtracker_pro_yearly"
    static let weekly = "subtracker_pro_weekly"
}

@MainActor
enum SubscriptionTrackerFactory {
    static func make() -> AppFactory {
        let config = AppFactoryConfiguration(
            appName: "Subscription Tracker",
            purchaseProvider: StoreKit2PurchaseProvider(productIDs: [Product.yearly, Product.weekly]),
            onboarding: OnboardingConfiguration(
                slides: [
                    .init(systemImage: "creditcard",
                          title: "Know What You Pay",
                          message: "Track every recurring subscription and see your true monthly spend."),
                    .init(systemImage: "bell.badge",
                          title: "Never Get Surprised",
                          message: "Get a reminder the day before anything renews — cancel in time, every time.")
                ],
                presentsPaywallOnFinish: true,
                accent: .green
            ),
            paywall: PaywallConfiguration(
                headline: "Unlock Subscription Tracker Pro",
                subheadline: "Take full control of your recurring spend.",
                benefits: [
                    .init(systemImage: "infinity", title: "Unlimited subscriptions"),
                    .init(systemImage: "bell.badge", title: "Renewal reminders"),
                    .init(systemImage: "chart.pie", title: "Monthly & yearly insights"),
                    .init(systemImage: "nosign", title: "No ads")
                ],
                productIDs: [Product.yearly, Product.weekly],
                highlightedProductID: Product.yearly,
                ctaTitle: "Continue",
                dismissButtonDelay: 4,
                isDismissable: true,
                termsURL: URL(string: "https://zubeidhendricks.github.io/SubscriptionTracker/terms.html"),
                privacyURL: URL(string: "https://zubeidhendricks.github.io/SubscriptionTracker/privacy.html"),
                style: PaywallStyle(accent: .green, heroSystemImage: "creditcard.circle")
            )
        )
        return AppFactory(config)
    }
}

@main
struct SubscriptionTrackerApp: App {
    @StateObject private var factory = SubscriptionTrackerFactory.make()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .appFactoryRoot(factory)
                .tint(.green)
        }
    }
}
