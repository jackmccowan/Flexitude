//
//  ProfileView.swift
//  Flexitude
//
//  Created by Jack McCowan on 5/5/2025.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: AuthViewModel
    
    // Toggle for controlling editing
    @State private var isEditing = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if let user = viewModel.currentUser {
                    VStack(spacing: 20) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.blue)
                            .padding(.top, 20)
                        
                        Text(user.fullName)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            ProfileInfoRow(title: "Username", value: user.username)
                            ProfileInfoRow(title: "Email", value: user.email)
                            ProfileInfoRow(title: "Age", value: "\(user.age)")
                            ProfileInfoRow(title: "Height", value: "\(user.height) cm")
                            ProfileInfoRow(title: "Weight", value: "\(user.weight) kg")
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        
                        if !isEditing {
                            Button("Edit Profile") {
                                isEditing = true
                            }
                        }
                        
                        Button(action: {
                            viewModel.logout()
                        }) {
                            Text("Logout")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(8)
                                .padding(.horizontal)
                        }
                        .padding(.top, 30)
                    }
                } else {
                    Text("User profile not available")
                        .font(.title)
                }
                
                Spacer()
            }
            .navigationTitle("Profile")
        }
        .sheet(isPresented: $isEditing) {
            EditProfileView(viewModel: viewModel)
        }
    }
}

struct ProfileInfoRow: View {
    var title: String
    var value: String = ""
    var isEditable: Bool = false
    var editableValue: Binding<String>? = nil
    var placeHolder: String = ""

    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.medium)
                .foregroundColor(.gray)
            Spacer()
            if isEditable, let editableValue = editableValue {
                TextField(placeHolder, text: editableValue)
                    .multilineTextAlignment(.trailing)
                    .fontWeight(.semibold)
                    .keyboardType(.decimalPad)
            } else {
                Text(value)
                    .fontWeight(.semibold)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ProfileView(viewModel: AuthViewModel.withPreviewUser())
}
