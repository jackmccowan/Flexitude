//
//  ContentView.swift
//  Flexitude
//
//  Created by Jack McCowan on 4/5/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isLoggedIn {
                MainView(viewModel: authViewModel)
            } else {
                LoginView(viewModel: authViewModel)
            }
        }
    }
}

struct MainView: View {
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome, \(viewModel.currentUser?.fullName ?? "User")!")
                    .font(.title)
                    .padding()
                
                Text("You have successfully logged in.")
                    .padding()
                
                Button(action: {
                    viewModel.logout()
                }) {
                    Text("Logout")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(8)
                }
                .padding(.top, 30)
                
                Spacer()
            }
            .navigationTitle("Flexitude")
        }
    }
}

#Preview {
    ContentView()
}
