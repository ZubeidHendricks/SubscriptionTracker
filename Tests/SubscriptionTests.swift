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
}
