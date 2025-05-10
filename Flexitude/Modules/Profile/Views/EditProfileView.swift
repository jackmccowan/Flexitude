//
//  EditProfileView.swift
//  Flexitude
//
//  Created by Matthew Shelton on 10/5/2025.
//

import Foundation
import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: AuthViewModel

    @State private var height: String
    @State private var weight: String

    init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
        let user = viewModel.currentUser!
        height = String(user.height)
        weight = String(user.weight)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Edit Profile Info")) {
                    TextField("Height (cm)", text: $height)
                        .keyboardType(.numberPad)

                    TextField("Weight (kg)", text: $weight)
                        .keyboardType(.numberPad)
                }

                Button("Save") {
                    if let heightVal = Double(height),
                       let weightVal = Double(weight) {
                        let updatedUser = viewModel.currentUser!.with(height: heightVal, weight: weightVal)
                        viewModel.updateUser(user: updatedUser)
                        viewModel.currentUser = updatedUser
                        dismiss()
                    }
                }
                .disabled(Double(height) == nil || Double(weight) == nil)
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
