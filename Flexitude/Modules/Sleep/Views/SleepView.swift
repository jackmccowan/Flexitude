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
    @State private var isShowingCalendar = false
    @State private var isShowingHealthKitPermission = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // Date selector with calendar
                DateSelectionView(selectedDate: $viewModel.date, isShowingCalendar: $isShowingCalendar)
                    .onChange(of: viewModel.date) {
                        viewModel.loadSleepData()
                    }
                
                if let sleepEntry = viewModel.sleepEntry {
                    SleepSummaryView(
                        sleepEntry: sleepEntry, 
                        sleepStageStats: viewModel.sleepStageStats,
                        sleepScore: viewModel.sleepScore
                    )
                } else {
                    EmptySleepView()
                }
            }
            .navigationTitle("Sleep")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            isShowingInputSheet = true
                        }) {
                            Label("Manual Entry", systemImage: "pencil")
                        }
                        
                        Button(action: {
                            if viewModel.isHealthKitAuthorized {
                                Task {
                                    await viewModel.importFromHealthKit()
                                }
                            } else {
                                isShowingHealthKitPermission = true
                            }
                        }) {
                            Label("Import from Health", systemImage: "heart.fill")
                        }
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                }
            }
            .sheet(isPresented: $isShowingInputSheet) {
                SleepInputView(viewModel: viewModel, isPresented: $isShowingInputSheet)
            }
            .sheet(isPresented: $isShowingHealthKitPermission) {
                HealthKitPermissionView(isPresented: $isShowingHealthKitPermission) {
                    Task {
                        await viewModel.requestHealthKitAuthorization()
                        if viewModel.isHealthKitAuthorized {
                            await viewModel.importFromHealthKit()
                        }
                    }
                }
            }
            .overlay {
                if viewModel.isImportingFromHealth {
                    ProgressView("Importing from Health...")
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 10)
                }
            }
        }
    }
}

struct DateSelectionView: View {
    @Binding var selectedDate: Date
    @Binding var isShowingCalendar: Bool
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    withAnimation {
                        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .padding()
                }
                
                Spacer()
                
                Button(action: {
                    isShowingCalendar.toggle()
                }) {
                    HStack {
                        Text(selectedDate, style: .date)
                            .fontWeight(.medium)
                        Image(systemName: "calendar")
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .padding()
                }
            }
            .padding(.horizontal)
            
            if isShowingCalendar {
                CalendarView(selectedDate: $selectedDate, isShowingCalendar: $isShowingCalendar)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}

struct CalendarView: View {
    @Binding var selectedDate: Date
    @Binding var isShowingCalendar: Bool
    
    var body: some View {
        DatePicker(
            "",
            selection: $selectedDate,
            displayedComponents: [.date]
        )
        .datePickerStyle(GraphicalDatePickerStyle())
        .labelsHidden()
        .onChange(of: selectedDate) {
            // Close calendar when date is selected
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    isShowingCalendar = false
                }
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
    let sleepScore: SleepScore
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Sleep Score Card
                SleepScoreCard(sleepScore: sleepScore)
                
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

struct SleepScoreCard: View {
    let sleepScore: SleepScore
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Sleep Score")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray4), lineWidth: 10)
                        .frame(width: 100, height: 100)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(sleepScore.score) / 100)
                        .stroke(sleepScore.color, lineWidth: 10)
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 0) {
                        Text("\(sleepScore.score)")
                            .font(.system(size: 32, weight: .bold))
                        
                        Text("%")
                            .font(.system(size: 16, weight: .medium))
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(sleepScore.label)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(sleepScore.color)
                    
                    sleepQualityDescription
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var sleepQualityDescription: some View {
        Group {
            switch sleepScore.score {
            case 90...100:
                Text("Outstanding sleep quality with ideal sleep cycles.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            case 70..<90:
                Text("Good sleep quality with healthy sleep cycles.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            case 50..<70:
                Text("Average sleep quality. Try to improve deep and REM sleep.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            case 30..<50:
                Text("Below average sleep quality. Focus on improving your sleep habits.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            case 1..<30:
                Text("Poor sleep quality. Consider adjusting your sleep schedule.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            default:
                Text("No sleep data available.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
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
                Section {
                    DatePicker("Date", selection: $viewModel.date, displayedComponents: [.date])
                }
                
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

struct HealthKitPermissionView: View {
    @Binding var isPresented: Bool
    var onAuthorize: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "heart.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.red)
                Text("Connect to Apple Health")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Import your sleep data automatically from Apple Health. You'll be asked for permission to read your sleep data.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                Button(action: {
                    isPresented = false
                    onAuthorize()
                }) {
                    Text("Connect")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                Button("Cancel") {
                    isPresented = false
                }
                .foregroundColor(.red)
            }
            .padding()
            .navigationTitle("Apple Health")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SleepView()
} 