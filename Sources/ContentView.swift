import SwiftUI
import AppFactoryKit

// Subscription Tracker — log recurring subscriptions, see monthly/yearly spend,
// and get a reminder the day before each renews. Free tier tracks a few; Pro is
// unlimited.
struct ContentView: View {
    @EnvironmentObject private var factory: AppFactory
    @StateObject private var store = SubscriptionStore()
    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        spendCard(title: "Monthly", value: store.monthlyTotal)
                        spendCard(title: "Yearly", value: store.yearlyTotal)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
                Section("Subscriptions") {
                    ForEach(store.sorted) { s in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(s.name).font(.headline)
                                Text("Renews \(s.nextRenewal, style: .date)").font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(s.price, format: .currency(code: "USD"))
                                Text(s.cycle.name).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete { idx in idx.map { store.sorted[$0] }.forEach(store.remove) }

                    if store.subs.isEmpty {
                        Text("No subscriptions yet — tap + to add one.").foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Subscriptions")
            .toolbar {
                Button { addTapped() } label: { Image(systemName: "plus") }
            }
            .sheet(isPresented: $showAdd) { AddSubscriptionView(store: store) }
        }
        .task { store.requestNotifications() }
    }

    private func spendCard(title: String, value: Double) -> some View {
        VStack(spacing: 4) {
            Text(value, format: .currency(code: "USD")).font(.title2.bold())
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 16)
        .background(RoundedRectangle(cornerRadius: 14).fill(.green.opacity(0.12)))
    }

    private func addTapped() {
        if store.reachedFreeLimit(isSubscribed: factory.subscriptions.isSubscribed) {
            factory.presentPaywall(placement: "sub_limit")
        } else {
            showAdd = true
        }
    }
}

struct AddSubscriptionView: View {
    @ObservedObject var store: SubscriptionStore
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var price = ""
    @State private var cycle: Cycle = .monthly
    @State private var renewal = Date().addingTimeInterval(60 * 60 * 24 * 30)

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name (e.g. Netflix)", text: $name)
                TextField("Price", text: $price).keyboardType(.decimalPad)
                Picker("Cycle", selection: $cycle) { ForEach(Cycle.allCases) { Text($0.name).tag($0) } }
                DatePicker("Next renewal", selection: $renewal, displayedComponents: .date)
            }
            .navigationTitle("Add Subscription")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let p = Double(price) ?? 0
                        store.add(Subscription(name: name.isEmpty ? "Subscription" : name, price: p, cycle: cycle, nextRenewal: renewal))
                        dismiss()
                    }
                    .disabled(name.isEmpty || Double(price) == nil)
                }
            }
        }
    }
}
