//
//  ContentView.swift
//  Shared
//
//  Created by Seyed Parsa Neshaei on 5/17/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: false)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @State var isConfirmSummarizingAllItemsAlertPresented = false
    @State var reasonEnteredOnWatchOS = ""
    @State var amountEnteredOnWatchOS = ""
    
    var balance: Double {
        var returnValue = 0.0
        for item in items {
            returnValue += item.amount
        }
        return returnValue
    }
    
    private func getColor(for amount: Double) -> Color {
        if amount > 0 { return .green }
        if amount < 0 { return .red }
        return .gray
    }
    
    private func getAmountInString(for amount: Double) -> String {
        if amount >= 0 {
            return "+\(String(format: "%.2f", amount))"
        }
        return String(format: "%.2f", amount)
    }
    
    var hStackSpacing: CGFloat {
        #if os(watchOS)
        return 5
        #else
        return 15
        #endif
    }

    var body: some View {
        NavigationView {
            List {
                VStack(alignment: .leading, spacing: 10) {
                    Text("TOTAL BALANCE")
                        .font(.title3)
                    Text(String(format: "%.2f", balance))
                        .bold()
                        .font(.largeTitle)
                }
                .padding([.bottom, .top])
                #if os(macOS)
                NavigationLink {
                    ItemDetailsView(isEditing: false, item: nil)
                } label: {
                    Label("Add new entry", systemImage: "plus.square.dashed")
                        .font(.title3)
                        .padding([.bottom, .top], 10)
                }
                #endif
                #if os(watchOS)
                TextField("Reason", text: $reasonEnteredOnWatchOS)
                TextField("Amount", text: $amountEnteredOnWatchOS)
                Button {
                    if let amount = Double(amountEnteredOnWatchOS), !amountEnteredOnWatchOS.isEmpty {
                        let newItem = Item(context: viewContext)
                        newItem.amount = amount
                        newItem.timestamp = Date()
                        newItem.notes = ""
                        newItem.reason = reasonEnteredOnWatchOS.isEmpty ? "Watch" : reasonEnteredOnWatchOS
                        do {
                            try viewContext.save()
                        } catch {
                            // error
                        }
                        amountEnteredOnWatchOS = ""
                    }
                } label: {
                    Label("Add quickly", systemImage: "plus.square.dashed")
                }
                #endif
                ForEach(items) { item in
                    NavigationLink {
                        ItemDetailsView(isEditing: true, item: item)
                    } label: {
                        HStack(spacing: hStackSpacing) {
                            ExDivider(color: getColor(for: item.amount), width: 3)
                            VStack(alignment: .leading, spacing: 10) {
                                Text(item.reason ?? "Untitled")
                                    .font(.title3)
                                    .bold()
                                #if os(watchOS)
                                    .lineLimit(3)
                                #else
                                    .lineLimit(2)
                                #endif
                                Text(item.timestamp ?? Date(), formatter: itemFormatter)
                            }
                            Spacer()
                            Text(getAmountInString(for: item.amount))
                                #if os(watchOS)
                                .font(.body)
                                #else
                                .font(.title2)
                                #endif
                                .bold()
                        }
                    }
                    .contextMenu {
                        Button {
                            withAnimation {
                                viewContext.delete(item)
                                do {
                                    try viewContext.save()
                                } catch {
                                    // error
                                }
                            }
                        } label: {
                            Label("Delete Flow", systemImage: "trash")
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .alert("Are you sure you want to summarize all the current CashFlows?", isPresented: $isConfirmSummarizingAllItemsAlertPresented, actions: {
                Button(role: ButtonRole.destructive, action: summarizeAllItems) {
                    Text("Yes")
                }
                Button(role: ButtonRole.cancel, action: {}) {
                    Text("No")
                }
            })
            .toolbar {
#if !os(watchOS) && !os(macOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    HStack(spacing: 20) {
#if !os(watchOS)
                        Button(action: confirmSummarizingAllItems) {
                            Label("Summarize CashFlow", systemImage: "rectangle.compress.vertical")
                        }
#endif
#if !os(macOS) && !os(watchOS)
                        NavigationLink(destination: { ItemDetailsView(isEditing: true, item: nil) }) {
                            Label("Add Item", systemImage: "plus")
                        }
#endif
                    }
                    
                }
            }
            .navigationTitle(Text("CashFlow"))
            Text("Select a flow to show its details")
        }
        #if os(watchOS)
        .navigationViewStyle(.stack)
        #endif
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            do {
                try viewContext.save()
            } catch {
                // error
            }
        }
    }
    
    private func confirmSummarizingAllItems() {
        isConfirmSummarizingAllItemsAlertPresented = true
    }
    
    private func summarizeAllItems() {
        withAnimation {
            let oldBalance = balance
            for item in items {
                viewContext.delete(item)
            }
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            newItem.reason = "Summarizing CashFlow"
            newItem.notes = "Summarizing CashFlow"
            newItem.amount = oldBalance
            do {
                try viewContext.save()
            } catch {
                // error
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                // error
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

struct ExDivider: View {
    var color: Color = .gray
    var width: CGFloat = 2
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: width)
            .edgesIgnoringSafeArea(.horizontal)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
