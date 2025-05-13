//
//  HealthKitService.swift
//  Flexitude
//
//  Created by Jack McCowan on 5/7/2025.
//

import Foundation
import HealthKit

class HealthKitService: ObservableObject {
    private let healthStore = HKHealthStore()
    @Published var isAuthorized = false
    
    // Check if HealthKit is available
    var isHealthDataAvailable: Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    // Request authorization for sleep data specifically
    func requestAuthorization() async throws {
        guard isHealthDataAvailable else {
            throw NSError(domain: "com.flexitude.healthkit", 
                          code: 0, 
                          userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device"])
        }
        
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            throw NSError(domain: "com.flexitude.healthkit", 
                          code: 1, 
                          userInfo: [NSLocalizedDescriptionKey: "Sleep analysis type is not available"])
        }
        
        let typesToRead: Set<HKObjectType> = [sleepType]
        
        do {
            try await healthStore.requestAuthorization(toShare: Set<HKSampleType>(), read: typesToRead)
            
            let status = healthStore.authorizationStatus(for: sleepType)
            await MainActor.run {
                self.isAuthorized = status == .sharingAuthorized
            }
        } catch {
            print("Failed to request HealthKit authorization: \(error)")
            throw error
        }
    }
    
    func fetchSleepData(for date: Date) async throws -> SleepEntry? {
        guard isHealthDataAvailable, isAuthorized else { return nil }
        
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            return nil
        }
        
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let sleepSamples = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKCategorySample], Error>) in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let samples = samples as? [HKCategorySample] else {
                    continuation.resume(returning: [])
                    return
                }
                
                continuation.resume(returning: samples)
            }
            
            healthStore.execute(query)
        }
        
        var totalSleepTime: TimeInterval = 0
        var deepSleepTime: TimeInterval = 0
        var remSleepTime: TimeInterval = 0
        
        for sample in sleepSamples {
            if sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue {
                let duration = sample.endDate.timeIntervalSince(sample.startDate)
                totalSleepTime += duration
            } 
            else if sample.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue {
                let duration = sample.endDate.timeIntervalSince(sample.startDate)
                deepSleepTime += duration
                totalSleepTime += duration
            }
            else if sample.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue {
                let duration = sample.endDate.timeIntervalSince(sample.startDate)
                remSleepTime += duration
                totalSleepTime += duration
            }
        }
        
        // Only create an entry if we have sleep dataw
        if totalSleepTime > 0 {
            let coreSleepTime = totalSleepTime - deepSleepTime - remSleepTime
            
            return SleepEntry(
                id: UUID().uuidString,
                date: date,
                totalSleepTime: totalSleepTime,
                deepSleepTime: deepSleepTime,
                coreSleepTime: coreSleepTime > 0 ? coreSleepTime : 0,
                remSleepTime: remSleepTime
            )
        }
        
        return nil
    }
} 
