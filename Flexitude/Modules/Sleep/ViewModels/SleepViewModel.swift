//
//  SleepViewModel.swift
//  Flexitude
//
//  Created by Jack McCowan on 5/5/2025.
//

import Foundation
import SwiftUI
import Combine

class SleepViewModel: ObservableObject {
    private let sleepDataService = SleepDataService()
    
    // Sleep data
    @Published var sleepEntry: SleepEntry?
    @Published var isLoading = false
    @Published var error: String?
    @Published var selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date() // Yesterday by default
    
    // Manual data entry
    @Published var isAddingManualEntry = false
    @Published var hoursDeepSleep = 0
    @Published var minutesDeepSleep = 0
    @Published var hoursCoreSleep = 0
    @Published var minutesCoreSleep = 0
    @Published var hoursRemSleep = 0
    @Published var minutesRemSleep = 0
    
    // UI data
    @Published var sleepStageStats: [SleepStageStat] = []
    
    init() {
        loadSleepData()
    }
    
    func loadSleepData() {
        isLoading = true
        error = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            self.isLoading = false
            self.sleepEntry = self.sleepDataService.getEntry(for: self.selectedDate)
            
            if let entry = self.sleepEntry {
                self.updateManualInputFields(from: entry)
                self.calculateSleepStats(from: entry)
            } else {
                self.resetManualInputFields()
                self.sleepStageStats = []
                self.error = "No sleep data found for this date"
            }
        }
    }
    
    private func updateManualInputFields(from entry: SleepEntry) {
        let deepHoursAndMinutes = hoursAndMinutes(from: entry.deepSleepTime)
        hoursDeepSleep = deepHoursAndMinutes.hours
        minutesDeepSleep = deepHoursAndMinutes.minutes
        
        let coreHoursAndMinutes = hoursAndMinutes(from: entry.coreSleepTime)
        hoursCoreSleep = coreHoursAndMinutes.hours
        minutesCoreSleep = coreHoursAndMinutes.minutes
        
        let remHoursAndMinutes = hoursAndMinutes(from: entry.remSleepTime)
        hoursRemSleep = remHoursAndMinutes.hours
        minutesRemSleep = remHoursAndMinutes.minutes
    }
    
    private func resetManualInputFields() {
        hoursDeepSleep = 0
        minutesDeepSleep = 0
        hoursCoreSleep = 0
        minutesCoreSleep = 0
        hoursRemSleep = 0
        minutesRemSleep = 0
    }
    
    func showManualEntryForm() {
        // Pre-populate form if we have existing data for this day
        if let existingEntry = sleepDataService.getEntry(for: selectedDate) {
            updateManualInputFields(from: existingEntry)
        } else {
            resetManualInputFields()
        }
        isAddingManualEntry = true
    }
    
    func saveManualEntry() {
        let deepSleepTime = TimeInterval(hoursDeepSleep * 3600 + minutesDeepSleep * 60)
        let coreSleepTime = TimeInterval(hoursCoreSleep * 3600 + minutesCoreSleep * 60)
        let remSleepTime = TimeInterval(hoursRemSleep * 3600 + minutesRemSleep * 60)
        let totalTime = deepSleepTime + coreSleepTime + remSleepTime
        
        let entry = SleepEntry(
            date: selectedDate,
            totalSleepTime: totalTime,
            deepSleepTime: deepSleepTime,
            coreSleepTime: coreSleepTime,
            remSleepTime: remSleepTime
        )
        
        sleepDataService.saveEntry(entry)
        isAddingManualEntry = false
        
        // Reload data to show the newly saved entry
        loadSleepData()
    }
    
    private func calculateSleepStats(from entry: SleepEntry) {
        let totalSleepDuration = entry.totalSleepTime
        
        if totalSleepDuration > 0 {
            var stats: [SleepStageStat] = []
            
            // Deep sleep
            if entry.deepSleepTime > 0 {
                stats.append(SleepStageStat(
                    stage: .deep,
                    duration: entry.deepSleepTime,
                    percentage: (entry.deepSleepTime / totalSleepDuration) * 100
                ))
            }
            
            // Core sleep
            if entry.coreSleepTime > 0 {
                stats.append(SleepStageStat(
                    stage: .core,
                    duration: entry.coreSleepTime,
                    percentage: (entry.coreSleepTime / totalSleepDuration) * 100
                ))
            }
            
            // REM sleep
            if entry.remSleepTime > 0 {
                stats.append(SleepStageStat(
                    stage: .rem,
                    duration: entry.remSleepTime,
                    percentage: (entry.remSleepTime / totalSleepDuration) * 100
                ))
            }
            
            sleepStageStats = stats
        } else {
            sleepStageStats = []
        }
    }
    
    func totalSleepTime() -> TimeInterval {
        return sleepEntry?.totalSleepTime ?? 0
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func hoursAndMinutes(from duration: TimeInterval) -> (hours: Int, minutes: Int) {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        return (hours, minutes)
    }
    
    func onDateChanged() {
        loadSleepData()
    }
}
