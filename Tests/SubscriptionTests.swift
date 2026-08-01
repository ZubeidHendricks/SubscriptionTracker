import XCTest
// SubscriptionStore.swift compiled into this test target.

final class SubscriptionTests: XCTestCase {
    func testCycleMonthlyFactors() {
        XCTAssertEqual(Cycle.monthly.monthlyFactor, 1, accuracy: 0.0001)
        XCTAssertEqual(Cycle.yearly.monthlyFactor, 1.0 / 12.0, accuracy: 0.0001)
        XCTAssertEqual(Cycle.weekly.monthlyFactor, 52.0 / 12.0, accuracy: 0.0001)
    }

    func testMonthlyEquivalent() {
        let yearly = Subscription(name: "X", price: 120, cycle: .yearly, nextRenewal: Date())
        XCTAssertEqual(yearly.monthlyEquivalent, 10, accuracy: 0.001)
        let monthly = Subscription(name: "Y", price: 9.99, cycle: .monthly, nextRenewal: Date())
        XCTAssertEqual(monthly.monthlyEquivalent, 9.99, accuracy: 0.001)
    }

    // "Saved by cancelling" competence feedback (see ../PLAYBOOK.md).
    func testSavingsAccumulatesMonthlyEquivalent() {
        let s = Subscription(name: "X", price: 120, cycle: .yearly, nextRenewal: Date())
        let v = SubscriptionStore.savings(afterCancelling: s, from: [s], current: 5)
        XCTAssertEqual(v, 15, accuracy: 0.001)
    }

    func testSavingsGuardsAgainstDoubleCounting() {
        let s = Subscription(name: "X", price: 10, cycle: .monthly, nextRenewal: Date())
        // Sub already gone from the tracked list — a second delete adds nothing.
        let v = SubscriptionStore.savings(afterCancelling: s, from: [], current: 10)
        XCTAssertEqual(v, 10, accuracy: 0.001)
    }

    func testSavedMonthlyLoadsFromDefaults() throws {
        let suite = "test.subs.saved.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set(try JSONEncoder().encode(12.5), forKey: "subs.saved.v1")
        XCTAssertEqual(SubscriptionStore(defaults: defaults).savedMonthly, 12.5, accuracy: 0.001)
    }
}
