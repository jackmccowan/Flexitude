//
//  LoginView.swift
//  Flexitude
//
//  Created by Jack McCowan on 5/5/2025.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Flexitude")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 50)
                
                Image(systemName: "figure.run")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                    .padding(.bottom, 30)
                
                VStack(spacing: 15) {
                    TextField("Username", text: $viewModel.loginUsername)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    
                    SecureField("Password", text: $viewModel.loginPassword)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    
                    if !viewModel.loginError.isEmpty {
                        Text(viewModel.loginError)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    Button(action: {
                        viewModel.login()
                    }) {
                        Text("Login")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                            .padding(.horizontal)
                    }
                    .padding(.top)
                    
                    NavigationLink(destination: RegisterView(viewModel: viewModel)) {
                        Text("Don't have an account? Sign Up")
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 10)
                }
                .padding(.bottom, 30)
                
                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    LoginView(viewModel: AuthViewModel())
}