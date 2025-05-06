//
//  SleepView.swift
//  Flexitude
//
//  Created by Jack McCowan on 5/5/2025.
//

import SwiftUI

struct SleepView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Sleep")
                    .font(.largeTitle)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Sleep")
        }
    }
}

#Preview {
    SleepView()
} 