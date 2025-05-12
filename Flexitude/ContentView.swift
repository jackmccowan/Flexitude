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
                MainTabView(viewModel: authViewModel)
            } else {
                LoginView(viewModel: authViewModel)
            }
        }
    }
}

struct MainTabView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(viewModel: <#AuthViewModel#>)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)
            
            WorkoutsView(authViewModel: <#AuthViewModel#>)
                .tabItem {
                    Label("Workouts", systemImage: "figure.run")
                }
                .tag(1)
            
            SleepView()
                .tabItem {
                    Label("Sleep", systemImage: "moon.zzz")
                }
                .tag(2)
            
            ProfileView(viewModel: viewModel)
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(3)
        }
    }
}

#Preview {
    ContentView()
}
