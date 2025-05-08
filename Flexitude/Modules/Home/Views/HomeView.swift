//
//  HomeView.swift
//  Flexitude
//
//  Created by Jack McCowan on 5/5/2025.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                if let firstName = viewModel.currentUser?.firstName {
                    Text("Welcome back, \(firstName)!")
                        .font(.title)
                        .fontWeight(.bold)
                } else {
                    Text("Welcome!")
                        .font(.title)
                        .fontWeight(.bold)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Home")
        }
    }
}

#Preview {
    HomeView(viewModel: AuthViewModel())
} 
