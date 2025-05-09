//
//  SleepView.swift
//  Flexitude
//
//  Created by Jack McCowan on 5/5/2025.
//

import SwiftUI

struct SleepView: View {
    @EnvironmentObject private var healthStore: HealthStoreManager
    @StateObject private var viewModel: SleepViewModel
    
    init() {
        // This will be initialized with the proper health store via the environment object
        // We're using a dummy value here that will be replaced
        _viewModel = StateObject(wrappedValue: SleepViewModel(healthStore: HealthStoreManager()))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                DatePicker("Select Date", selection: $viewModel.selectedDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .padding()
                    .onChange(of: viewModel.selectedDate) { _ in
                        viewModel.onDateChanged()
                    }
                
                if !viewModel.isHealthKitAuthorized {
                    VStack(spacing: 20) {
                        Text("Please authorize access to your Health data")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Button("Authorize HealthKit") {
                            viewModel.requestHealthKitAuthorization()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    
                } else if viewModel.isLoading {
                    ProgressView("Loading sleep data...")
                    
                } else if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                    
                } else if viewModel.sleepStats.isEmpty {
                    Text("No sleep data available for this date")
                        .font(.headline)
                        .padding()
                    
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Total Sleep")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    
                                    Text(viewModel.getTotalSleepDurationText())
                                        .font(.system(size: 34, weight: .bold))
                                }
                                
                                Spacer()
                                
                                // Simplified sleep quality indicator
                                ZStack {
                                    Circle()
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                                        .frame(width: 60, height: 60)
                                    
                                    Circle()
                                        .trim(from: 0, to: min(0.75, 0.75))
                                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                        .frame(width: 60, height: 60)
                                        .rotationEffect(.degrees(-90))
                                    
                                    Text("75%")
                                        .font(.caption)
                                        .bold()
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            
                            Text("Sleep Stages")
                                .font(.headline)
                                .padding(.top)
                            
                            ForEach(viewModel.sleepStats) { stat in
                                SleepStageRow(stat: stat, formatter: viewModel.formatDuration)
                            }
                        }
                        .padding()
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Sleep")
            .onAppear {
                // Replace the dummy ViewModel with one that uses the real HealthStore
                if viewModel.healthStore !== healthStore {
                    _viewModel = StateObject(wrappedValue: SleepViewModel(healthStore: healthStore))
                }
                
                if viewModel.isHealthKitAuthorized {
                    viewModel.loadSleepData()
                }
            }
        }
    }
}

struct SleepStageRow: View {
    let stat: SleepViewModel.SleepStat
    let formatter: (TimeInterval) -> String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(stat.type.displayName)
                    .font(.headline)
                
                Spacer()
                
                Text(formatter(stat.duration))
                    .font(.headline)
            }
            
            HStack {
                Text("\(Int(stat.percentage))%")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
            
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(height: 8)
                    .foregroundColor(Color(.systemGray5))
                    .cornerRadius(4)
                
                Rectangle()
                    .frame(width: max(4, CGFloat(stat.percentage / 100) * UIScreen.main.bounds.width - 40), height: 8)
                    .foregroundColor(getColor(for: stat.type))
                    .cornerRadius(4)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func getColor(for type: SleepType) -> Color {
        switch type {
        case .core: return .blue
        case .deep: return .indigo
        case .rem: return .purple
        default: return .gray
        }
    }
}

#Preview {
    SleepView()
        .environmentObject(HealthStoreManager())
} 
