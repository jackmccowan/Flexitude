//
//  SleepViewModel.swift
//  Flexitude
//
//  Created by Jack McCowan on 5/5/2025.
//

import Foundation
import Combine

class SleepViewModel: ObservableObject {
    private let sleepDataService = SleepDataService()
    private let sleepScoreService = SleepScoreService()
    private let healthKitService = HealthKitService()
    
    // Sleep data
    @Published var sleepEntry: SleepEntry?
    @Published var date = Date()
    @Published var isHealthKitAuthorized = false
    @Published var isImportingFromHealth = false
    
    // Manual input fields
    @Published var hoursDeepSleep = 0
    @Published var minutesDeepSleep = 0
    @Published var hoursCoreSleep = 0
    @Published var minutesCoreSleep = 0
    @Published var hoursRemSleep = 0
    @Published var minutesRemSleep = 0
    
    // Calculated stats
    @Published var sleepStageStats: [SleepStageStat] = []
    @Published var sleepScore: SleepScore = SleepScore(score: 0, label: "No Data", color: .gray)
    
    init() {
        loadSleepData()
    }
    
    func requestHealthKitAuthorization() async {
        do {
            try await healthKitService.requestAuthorization()
            await MainActor.run {
                self.isHealthKitAuthorized = healthKitService.isAuthorized
            }
        } catch {
            print("HealthKit authorization failed: \(error)")
        }
    }
    
    func importFromHealthKit() async {
        await MainActor.run {
            self.isImportingFromHealth = true
        }
        
        do {
            if let healthEntry = try await healthKitService.fetchSleepData(for: date) {
                await MainActor.run {
                    self.sleepEntry = healthEntry
                    self.updateManualInputFields(from: healthEntry)
                    self.calculateSleepStats(from: healthEntry)
                    self.calculateSleepScore()
                    self.sleepDataService.saveEntry(healthEntry)
                }
            }
        } catch {
            print("Failed to import sleep data: \(error)")
        }
        
        await MainActor.run {
            self.isImportingFromHealth = false
        }
    }
    
    func loadSleepData() {
        if let entry = sleepDataService.getEntry(for: date) {
            self.sleepEntry = entry
            self.updateManualInputFields(from: entry)
            self.calculateSleepStats(from: entry)
            self.calculateSleepScore()
        } else {
            self.sleepEntry = nil
            self.resetInputFields()
            self.sleepStageStats = []
            self.sleepScore = SleepScore(score: 0, label: "No Data", color: .gray)
        }
    }
    
    private func calculateSleepScore() {
        self.sleepScore = sleepScoreService.calculateScore(for: sleepEntry)
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
    
    private func resetInputFields() {
        hoursDeepSleep = 0
        minutesDeepSleep = 0
        hoursCoreSleep = 0
        minutesCoreSleep = 0
        hoursRemSleep = 0
        minutesRemSleep = 0
    }
    
    private func hoursAndMinutes(from seconds: TimeInterval) -> (hours: Int, minutes: Int) {
        let totalMinutes = Int(seconds / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return (hours, minutes)
    }
    
    func saveSleepData() {
        // Calculate time intervals from user input
        let deepSleepTime = TimeInterval(hoursDeepSleep * 3600 + minutesDeepSleep * 60)
        let coreSleepTime = TimeInterval(hoursCoreSleep * 3600 + minutesCoreSleep * 60)
        let remSleepTime = TimeInterval(hoursRemSleep * 3600 + minutesRemSleep * 60)
        let totalTime = deepSleepTime + coreSleepTime + remSleepTime
        
        let entry = SleepEntry(
            id: UUID().uuidString,
            date: date,
            totalSleepTime: totalTime,
            deepSleepTime: deepSleepTime,
            coreSleepTime: coreSleepTime,
            remSleepTime: remSleepTime
        )
        
        sleepDataService.saveEntry(entry)
        loadSleepData()
    }
    
    private func calculateSleepStats(from entry: SleepEntry) {
        let totalSleepDuration = entry.totalSleepTime
        
        if totalSleepDuration > 0 {
            var stats: [SleepStageStat] = []
            
            // Deep sleep
            if entry.deepSleepTime > 0 {
                stats.append(SleepStageStat(
                    id: UUID().uuidString,
                    stage: .deep,
                    duration: entry.deepSleepTime,
                    percentage: (entry.deepSleepTime / totalSleepDuration) * 100
                ))
            }
            
            // Core sleep
            if entry.coreSleepTime > 0 {
                stats.append(SleepStageStat(
                    id: UUID().uuidString,
                    stage: .core,
                    duration: entry.coreSleepTime,
                    percentage: (entry.coreSleepTime / totalSleepDuration) * 100
                ))
            }
            
            // REM sleep
            if entry.remSleepTime > 0 {
                stats.append(SleepStageStat(
                    id: UUID().uuidString,
                    stage: .rem,
                    duration: entry.remSleepTime,
                    percentage: (entry.remSleepTime / totalSleepDuration) * 100
                ))
            }
            
            self.sleepStageStats = stats
        } else {
            self.sleepStageStats = []
        }
    }
    
    func totalSleepTime() -> TimeInterval {
        return sleepEntry?.totalSleepTime ?? 0
    }
}
