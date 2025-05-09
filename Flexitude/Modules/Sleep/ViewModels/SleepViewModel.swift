//
//  SleepViewModel.swift
//  Flexitude
//
//  Created by Jack McCowan on 5/5/2025.
//

import Foundation
import SwiftUI
import Combine
import HealthKit

class SleepViewModel: ObservableObject {
    private let sleepService: SleepService
    private let healthStore: HealthStoreManager
    
    @Published var sleepData: [SleepData] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var selectedDate = Date()
    @Published var sleepStats: [SleepStat] = []
    
    var cancellables = Set<AnyCancellable>()
    
    struct SleepStat: Identifiable {
        var id = UUID()
        var type: SleepType
        var duration: TimeInterval
        var percentage: Double
    }
    
    init(healthStore: HealthStoreManager) {
        self.healthStore = healthStore
        self.sleepService = SleepService(healthStore: healthStore.healthStore)
    }
    
    var isHealthKitAuthorized: Bool {
        return healthStore.isAuthorized
    }
    
    func usingSameHealthStore(as otherStore: HealthStoreManager) -> Bool {
        return self.healthStore === otherStore
    }
    
    func requestHealthKitAuthorization() {
        healthStore.requestAuthorization { [weak self] success, error in
            if success {
                self?.loadSleepData()
            } else if let error = error {
                self?.error = error.localizedDescription
            }
        }
    }
    
    func loadSleepData() {
        isLoading = true
        error = nil
        
        sleepService.fetchSleepData(for: selectedDate) { [weak self] data, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.error = error.localizedDescription
                    return
                }
                
                guard let data = data else {
                    self?.error = "No sleep data available"
                    return
                }
                
                self?.sleepData = data
                self?.calculateSleepStats()
            }
        }
    }
    
    func calculateSleepStats() {
        let totalSleepDuration = sleepService.getTotalSleepDuration(from: sleepData)
        
        if totalSleepDuration > 0 {
            var stats: [SleepStat] = []
            
            for type in [SleepType.core, .deep, .rem] {
                let duration = sleepService.getTotalDurationForType(type, from: sleepData)
                let percentage = (duration / totalSleepDuration) * 100
                stats.append(SleepStat(type: type, duration: duration, percentage: percentage))
            }
            
            sleepStats = stats
        } else {
            sleepStats = []
        }
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        return "\(hours)h \(minutes)m"
    }
    
    func getTotalSleepDurationText() -> String {
        let totalDuration = sleepService.getTotalSleepDuration(from: sleepData)
        return formatDuration(totalDuration)
    }
    
    func onDateChanged() {
        loadSleepData()
    }
} 
