//
//  SleepView.swift
//  Flexitude
//
//  Created by Jack McCowan on 5/5/2025.
//

import SwiftUI

struct SleepView: View {
    @StateObject private var viewModel = SleepViewModel()
    @State private var isShowingInputSheet = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if let sleepEntry = viewModel.sleepEntry {
                    SleepSummaryView(sleepEntry: sleepEntry, sleepStageStats: viewModel.sleepStageStats)
                } else {
                    EmptySleepView()
                }
            }
            .navigationTitle("Sleep")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isShowingInputSheet = true
                    }) {
                        Image(systemName: "plus.circle")
                    }
                }
            }
            .sheet(isPresented: $isShowingInputSheet) {
                SleepInputView(viewModel: viewModel, isPresented: $isShowingInputSheet)
            }
        }
    }
}

struct EmptySleepView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "moon.zzz.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("No Sleep Data")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Track your sleep by adding your first sleep entry")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SleepSummaryView: View {
    let sleepEntry: SleepEntry
    let sleepStageStats: [SleepStageStat]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Total Sleep Card
                TotalSleepCard(totalSleepTime: sleepEntry.totalSleepTime)
                
                // Sleep Stages Chart
                SleepStagesChartView(sleepStageStats: sleepStageStats)
                
                // Sleep Stages Detail
                SleepStagesDetailView(sleepEntry: sleepEntry)
            }
            .padding()
        }
    }
}

struct TotalSleepCard: View {
    let totalSleepTime: TimeInterval
    
    var formattedTotalSleep: String {
        let hours = Int(totalSleepTime / 3600)
        let minutes = Int((totalSleepTime.truncatingRemainder(dividingBy: 3600)) / 60)
        return "\(hours)h \(minutes)m"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Total Sleep Time")
                .font(.headline)
            
            HStack {
                Image(systemName: "moon.stars.fill")
                    .foregroundColor(.purple)
                    .font(.largeTitle)
                
                Text(formattedTotalSleep)
                    .font(.system(size: 36, weight: .bold))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct SleepStagesChartView: View {
    let sleepStageStats: [SleepStageStat]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Sleep Stages")
                .font(.headline)
            
            HStack(spacing: 0) {
                ForEach(sleepStageStats) { stat in
                    RoundedRectangle(cornerRadius: 0)
                        .fill(colorForStage(stat.stage))
                        .frame(width: CGFloat(stat.percentage), height: 20)
                }
            }
            .cornerRadius(8)
            
            // Legend
            VStack(spacing: 8) {
                ForEach(SleepStage.allCases, id: \.self) { stage in
                    HStack {
                        Circle()
                            .fill(colorForStage(stage))
                            .frame(width: 12, height: 12)
                        Text(stage.displayName)
                            .font(.subheadline)
                        Spacer()
                        if let stat = sleepStageStats.first(where: { $0.stage == stage }) {
                            Text("\(Int(stat.percentage))%")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    func colorForStage(_ stage: SleepStage) -> Color {
        switch stage {
        case .deep:
            return .blue
        case .core:
            return .purple
        case .rem:
            return .green
        }
    }
}

struct SleepStagesDetailView: View {
    let sleepEntry: SleepEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Sleep Details")
                .font(.headline)
            
            VStack(spacing: 15) {
                SleepStageRow(
                    stage: .deep,
                    duration: sleepEntry.deepSleepTime,
                    color: .blue
                )
                
                Divider()
                
                SleepStageRow(
                    stage: .core,
                    duration: sleepEntry.coreSleepTime,
                    color: .purple
                )
                
                Divider()
                
                SleepStageRow(
                    stage: .rem,
                    duration: sleepEntry.remSleepTime,
                    color: .green
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct SleepStageRow: View {
    let stage: SleepStage
    let duration: TimeInterval
    let color: Color
    
    var formattedDuration: String {
        let hours = Int(duration / 3600)
        let minutes = Int((duration.truncatingRemainder(dividingBy: 3600)) / 60)
        return "\(hours)h \(minutes)m"
    }
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(stage.displayName)
                .font(.subheadline)
            
            Spacer()
            
            Text(formattedDuration)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
}

struct SleepInputView: View {
    @ObservedObject var viewModel: SleepViewModel
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Deep Sleep")) {
                    HStack {
                        Picker("Hours", selection: $viewModel.hoursDeepSleep) {
                            ForEach(0..<13, id: \.self) { hour in
                                Text("\(hour)h").tag(hour)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 150)
                        
                        Picker("Minutes", selection: $viewModel.minutesDeepSleep) {
                            ForEach(0..<60, id: \.self) { minute in
                                Text("\(minute)m").tag(minute)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 150)
                    }
                }
                
                Section(header: Text("Core Sleep")) {
                    HStack {
                        Picker("Hours", selection: $viewModel.hoursCoreSleep) {
                            ForEach(0..<13, id: \.self) { hour in
                                Text("\(hour)h").tag(hour)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 150)
                        
                        Picker("Minutes", selection: $viewModel.minutesCoreSleep) {
                            ForEach(0..<60, id: \.self) { minute in
                                Text("\(minute)m").tag(minute)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 150)
                    }
                }
                
                Section(header: Text("REM Sleep")) {
                    HStack {
                        Picker("Hours", selection: $viewModel.hoursRemSleep) {
                            ForEach(0..<13, id: \.self) { hour in
                                Text("\(hour)h").tag(hour)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 150)
                        
                        Picker("Minutes", selection: $viewModel.minutesRemSleep) {
                            ForEach(0..<60, id: \.self) { minute in
                                Text("\(minute)m").tag(minute)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 150)
                    }
                }
            }
            .navigationTitle("Enter Sleep Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.saveSleepData()
                        isPresented = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    SleepView()
} 