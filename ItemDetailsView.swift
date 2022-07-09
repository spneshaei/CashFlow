//
//  ItemDetailsView.swift
//  CashFlow
//
//  Created by Seyed Parsa Neshaei on 5/17/22.
//

import SwiftUI

struct ItemDetailsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    let isEditing: Bool
    let item: Item?
    
    @State var reason: String
    @State var notes: String
    @State var timestamp: Date
    @State var amount: String
    @State var isIncorrectAmountAlertPresented = false
    @State var isErrorInAdditionAlertPresented = false
    
    init(isEditing: Bool, item: Item?) {
        self.isEditing = isEditing
        self.item = item
        if let item = item {
            _notes = State(initialValue: item.notes ?? "")
            _reason = State(initialValue: item.reason ?? "Untitled")
            _timestamp = State(initialValue: item.timestamp ?? Date())
            _amount = State(initialValue: String(format: "%.2f", item.amount))
        } else {
            _notes = State(initialValue: "")
            _reason = State(initialValue: "")
            _timestamp = State(initialValue: Date())
            _amount = State(initialValue: "")
        }
    }
    
    var body: some View {
        Form {
            TextField("Reason", text: $reason)
            #if !os(macOS) && !os(watchOS)
            TextField("Amount", text: $amount)
                .keyboardType(.numbersAndPunctuation)
            #else
            TextField("Amount", text: $amount)
            #endif
            #if !os(watchOS)
            DatePicker("Time", selection: $timestamp)
            Section("Additional Notes") {
                TextEditor(text: $notes)
            }
            #else
            Section("Additional Notes") {
                Text(notes)
            }
            #endif
        }
        #if os(macOS)
        .padding()
        #endif
        .toolbar {
            ToolbarItem {
                Button(action: submitItem) {
                    Text("Done")
                        .bold()
                }
            }
        }
        .alert("Incorrect amount entered", isPresented: $isIncorrectAmountAlertPresented) {
            Button(role: .cancel, action: {}) { Text("OK") }
        }
        .alert("Error while adding. Please try again.", isPresented: $isErrorInAdditionAlertPresented) {
            Button(role: .cancel, action: {}) { Text("OK") }
        }
        .navigationTitle("Flow Details")
    }
    
    private func submitItem() {
        guard let doubleAmount = Double(amount) else {
            isIncorrectAmountAlertPresented = true
            return
        }
        if let item = item, isEditing {
            item.amount = doubleAmount
            item.timestamp = timestamp
            item.notes = notes
            item.reason = reason.isEmpty ? "Untitled" : reason
        } else {
            let newItem = Item(context: viewContext)
            newItem.amount = doubleAmount
            newItem.timestamp = timestamp
            newItem.notes = notes
            newItem.reason = reason.isEmpty ? "Untitled" : reason
        }
        do {
            try viewContext.save()
            #if !os(macOS)
            presentationMode.wrappedValue.dismiss()
            #endif
        } catch {
            isErrorInAdditionAlertPresented = true
        }
    }
}
