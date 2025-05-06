//
//  RegisterView.swift
//  Flexitude
//
//  Created by Jack McCowan on 5/5/2025.
//

import SwiftUI

struct RegisterView: View {
    @ObservedObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showSuccessAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                VStack(alignment: .leading, spacing: 15) {
                    Group {
                        Text("Personal Details")
                            .font(.headline)
                            .padding(.top)
                        
                        TextField("First Name", text: $viewModel.firstName)
                            .textContentType(.givenName)
                        
                        TextField("Last Name", text: $viewModel.lastName)
                            .textContentType(.familyName)
                        
                        TextField("Email", text: $viewModel.email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                        
                        DatePicker("Date of Birth", selection: $viewModel.dateOfBirth, 
                                   displayedComponents: .date)
                    }
                    .padding(.horizontal)
                    
                    Group {
                        Text("Physical Details")
                            .font(.headline)
                            .padding(.top)
                        
                        HStack {
                            Text("Height (cm)")
                            Spacer()
                            TextField("Height", value: $viewModel.height, format: .number)
                                .keyboardType(.decimalPad)
                                .frame(width: 80)
                                .multilineTextAlignment(.trailing)
                        }
                        
                        HStack {
                            Text("Weight (kg)")
                            Spacer()
                            TextField("Weight", value: $viewModel.weight, format: .number)
                                .keyboardType(.decimalPad)
                                .frame(width: 80)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    .padding(.horizontal)
                    
                    Group {
                        Text("Account Details")
                            .font(.headline)
                            .padding(.top)
                        
                        TextField("Username", text: $viewModel.username)
                            .textContentType(.username)
                        
                        SecureField("Password", text: $viewModel.password)
                            .textContentType(.newPassword)
                        
                        SecureField("Confirm Password", text: $viewModel.confirmPassword)
                            .textContentType(.newPassword)
                    }
                    .padding(.horizontal)
                }
                
                if !viewModel.registrationError.isEmpty {
                    Text(viewModel.registrationError)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button(action: {
                    viewModel.register()
                    if viewModel.registrationSuccess {
                        showSuccessAlert = true
                    }
                }) {
                    Text("Register")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                .padding(.top, 20)
            }
            .padding(.bottom, 30)
            .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .navigationTitle("Registration")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Registration Successful", isPresented: $showSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("You can now log in with your username and password")
        }
    }
}

#Preview {
    NavigationStack {
        RegisterView(viewModel: AuthViewModel())
    }
}