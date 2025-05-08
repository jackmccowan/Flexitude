//
//  WorkoutsView.swift
//  Flexitude
//
//  Created by Jack McCowan on 5/5/2025.
//

import SwiftUI

struct WorkoutsView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Workouts")
                    .font(.largeTitle)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Workouts123")
        }
    }
}

#Preview {
    WorkoutsView()
} 