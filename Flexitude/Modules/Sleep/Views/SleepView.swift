//
//  SleepView.swift
//  Flexitude
//
//  Created by Jack McCowan on 5/5/2025.
//

import SwiftUI

struct SleepView: View {
    @StateObject private var viewModel = SleepViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    "Select Date",
                    selection: $viewModel.selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .padding()
                .onChange(of: viewModel.selectedDate) { _ in
                    viewModel.onDateChanged()
                }
                
                HStack {
                    Spacer()
                    Button(action: {
                        viewModel.showManualEntryForm()
                    }) {
                        Label("Add Sleep Data", systemImage: "plus")
                            .font(.subheadline)
                    }
                    .padding(.trailing)
                }
                
                if viewModel.isLoading {
                    loadingView
                } else if let error = viewModel.error {
                    errorView(message: error)
                } else if viewModel.sleepStageStats.isEmpty {
                    noDataView
                } else {
                    sleepDataView
                }
                
                Spacer()
            }
            .navigationTitle("Sleep")
            .onAppear {
                viewModel.loadSleepData()
            }
            .sheet(isPresented: $viewModel.isAddingManualEntry) {
                manualEntryForm
            }
        }
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.5)
                .padding()
            
            Text("Loading sleep data...")
                .font(.headline)
        }
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 15) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("No Sleep Data")
                .font(.headline)
            
            Text(message)
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button("Add Sleep Data") {
                viewModel.showManualEntryForm()
            }
            .padding(.top, 10)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding()
    }
    
    private var noDataView: some View {
        VStack(spacing: 15) {
            Image(systemName: "moon.zzz.fill")
                .font(.system(size: 50))
                .foregroundColor(.blue.opacity(0.7))
            
            Text("No Sleep Data Recorded")
                .font(.headline)
            
            Text("You haven't entered any sleep data for this date yet.")
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button("Add Sleep Data") {
                viewModel.showManualEntryForm()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 10)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding()
    }
    
    private var sleepDataView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Total sleep summary
                HStack {
                    VStack(alignment: .leading) {
                        Text("Total Sleep")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(viewModel.formatDuration(viewModel.totalSleepTime()))
                            .font(.system(size: 34, weight: .bold))
                    }
                    
                    Spacer()
                    
                    // Data source indicator
                    Text("Manual Entry")
                        .font(.caption)
                        .padding(5)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.2))
                        )
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Text("Sleep Stages")
                    .font(.headline)
                    .padding(.top)
                
                // Sleep stages breakdown
                ForEach(viewModel.sleepStageStats) { stat in
                    SleepStageRow(
                        stage: stat.stage,
                        duration: stat.duration,
                        percentage: stat.percentage,
                        formatter: viewModel.formatDuration
                    )
                }
                
                Button("Edit Sleep Data") {
                    viewModel.showManualEntryForm()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.top, 20)
            }
            .padding()
        }
    }
    
    private var manualEntryForm: some View {
        NavigationStack {
            Form {
                Section(header: Text("Deep Sleep")) {
                    HStack {
                        Picker("Hours", selection: $viewModel.hoursDeepSleep) {
                            ForEach(0..<13) { hour in
                                Text("\(hour) hr").tag(hour)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100)
                        .clipped()
                        
                        Picker("Minutes", selection: $viewModel.minutesDeepSleep) {
                            ForEach(0..<60) { minute in
                                Text("\(minute) min").tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100)
                        .clipped()
                    }
                    .frame(maxWidth: .infinity)
                }
                
                Section(header: Text("Core Sleep")) {
                    HStack {
                        Picker("Hours", selection: $viewModel.hoursCoreSleep) {
                            ForEach(0..<13) { hour in
                                Text("\(hour) hr").tag(hour)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100)
                        .clipped()
                        
                        Picker("Minutes", selection: $viewModel.minutesCoreSleep) {
                            ForEach(0..<60) { minute in
                                Text("\(minute) min").tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100)
                        .clipped()
                    }
                    .frame(maxWidth: .infinity)
                }
                
                Section(header: Text("REM Sleep")) {
                    HStack {
                        Picker("Hours", selection: $viewModel.hoursRemSleep) {
                            ForEach(0..<13) { hour in
                                Text("\(hour) hr").tag(hour)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100)
                        .clipped()
                        
                        Picker("Minutes", selection: $viewModel.minutesRemSleep) {
                            ForEach(0..<60) { minute in
                                Text("\(minute) min").tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100)
                        .clipped()
                    }
                    .frame(maxWidth: .infinity)
                }
                
                Section {
                    let totalHours = viewModel.hoursDeepSleep + viewModel.hoursCoreSleep + viewModel.hoursRemSleep
                    let totalMinutes = viewModel.minutesDeepSleep + viewModel.minutesCoreSleep + viewModel.minutesRemSleep
                    let adjustedHours = totalHours + (totalMinutes / 60)
                    let adjustedMinutes = totalMinutes % 60
                    
                    HStack {
                        Text("Total Sleep Time")
                        Spacer()
                        Text("\(adjustedHours)h \(adjustedMinutes)m")
                            .bold()
                    }
                }
            }
            .navigationTitle("Enter Sleep Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.isAddingManualEntry = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.saveManualEntry()
                    }
                }
            }
        }
        .presentationDetents([.height(500)])
    }
}

struct SleepStageRow: View {
    let stage: SleepStage
    let duration: TimeInterval
    let percentage: Double
    let formatter: (TimeInterval) -> String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(stage.displayName)
                    .font(.headline)
                
                Spacer()
                
                Text(formatter(duration))
                    .font(.headline)
            }
            
            HStack {
                Text("\(Int(percentage))%")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
            
            // Progress bar
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(height: 8)
                    .foregroundColor(Color(.systemGray5))
                    .cornerRadius(4)
                
                Rectangle()
                    .frame(width: max(4, CGFloat(percentage / 100) * UIScreen.main.bounds.width - 40), height: 8)
                    .foregroundColor(stage.color)
                    .cornerRadius(4)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct SleepView_Previews: PreviewProvider {
    static var previews: some View {
        SleepView()
    }
} 