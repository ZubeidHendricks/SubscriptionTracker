import Foundation
import Combine
import UserNotifications

enum Cycle: String, Codable, CaseIterable, Identifiable {
    case weekly, monthly, yearly
    var id: String { rawValue }
    var name: String { rawValue.capitalized }
    /// Normalize a price to a monthly figure for the spend total.
    var monthlyFactor: Double {
        switch self {
        case .weekly: return 52.0 / 12.0
        case .monthly: return 1
        case .yearly: return 1.0 / 12.0
        }
    }
}

struct Subscription: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var price: Double
    var cycle: Cycle
    var nextRenewal: Date
    var monthlyEquivalent: Double { price * cycle.monthlyFactor }
}

/// Persisted subscriptions + monthly spend + local renewal reminders.
/// Free tier caps the number of tracked subs; Pro is unlimited.
final class SubscriptionStore: ObservableObject {
    @Published private(set) var subs: [Subscription] = []
    /// Lifetime monthly cost of cancelled subs — competence feedback per
    /// ../PLAYBOOK.md: real money saved by cancelling, never app opens.
    @Published private(set) var savedMonthly: Double = 0
    static let freeLimit = 3
    private let key = "subs.v1"
    private let savedKey = "subs.saved.v1"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    var monthlyTotal: Double { subs.reduce(0) { $0 + $1.monthlyEquivalent } }
    var yearlyTotal: Double { monthlyTotal * 12 }
    var sorted: [Subscription] { subs.sorted { $0.nextRenewal < $1.nextRenewal } }
    func reachedFreeLimit(isSubscribed: Bool) -> Bool { !isSubscribed && subs.count >= Self.freeLimit }

    func add(_ s: Subscription) {
        subs.append(s); save()
        scheduleReminder(for: s)
    }
    func remove(_ s: Subscription) {
        savedMonthly = Self.savings(afterCancelling: s, from: subs, current: savedMonthly)
        subs.removeAll { $0.id == s.id }; save()
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [s.id.uuidString])
    }

    /// Pure savings step: accumulate the cancelled sub's monthly cost, but only
    /// if it is still tracked — deleting the same sub twice can't double-count.
    static func savings(afterCancelling s: Subscription, from subs: [Subscription], current: Double) -> Double {
        guard subs.contains(where: { $0.id == s.id }) else { return current }
        return current + s.monthlyEquivalent
    }

    func requestNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }

    private func scheduleReminder(for s: Subscription) {
        // Remind the day before renewal.
        guard let fireDate = Calendar.current.date(byAdding: .day, value: -1, to: s.nextRenewal),
              fireDate > Date() else { return }
        let content = UNMutableNotificationContent()
        content.title = "\(s.name) renews tomorrow"
        content.body = String(format: "You'll be charged %.2f.", s.price)
        content.sound = .default
        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let request = UNNotificationRequest(identifier: s.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func load() {
        if let d = defaults.data(forKey: key),
           let v = try? JSONDecoder().decode([Subscription].self, from: d) { subs = v }
        if let d = defaults.data(forKey: savedKey),
           let v = try? JSONDecoder().decode(Double.self, from: d) { savedMonthly = v }
    }
    private func save() {
        if let d = try? JSONEncoder().encode(subs) { defaults.set(d, forKey: key) }
        if let d = try? JSONEncoder().encode(savedMonthly) { defaults.set(d, forKey: savedKey) }
    }
}
