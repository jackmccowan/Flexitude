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
    
    // Sleep types we want to read
    private let sleepTypes: Set<HKObjectType> = [
        HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
    ]
    
    func requestAuthorization() async throws {
        // Request authorization
        try await healthStore.requestAuthorization(toShare: [], read: sleepTypes)
        
        // Check if we got authorization
        let status = healthStore.authorizationStatus(for: HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!)
        DispatchQueue.main.async {
            self.isAuthorized = status == .sharingAuthorized
        }
    }
    
    func fetchSleepData(for date: Date) async throws -> SleepEntry? {
        guard isAuthorized else { return nil }
        
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        
        // Create the predicate for the date range
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        // Fetch sleep analysis
        let sleepAnalysisType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let sleepAnalysis = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKCategorySample], Error>) in
            let query = HKSampleQuery(
                sampleType: sleepAnalysisType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: samples as? [HKCategorySample] ?? [])
            }
            healthStore.execute(query)
        }
        
        // Calculate sleep stages
        var deepSleepTime: TimeInterval = 0
        var remSleepTime: TimeInterval = 0
        var totalSleepTime: TimeInterval = 0
        
        for sample in sleepAnalysis {
            let duration = sample.endDate.timeIntervalSince(sample.startDate)
            totalSleepTime += duration
            
            switch sample.value {
            case HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue:
                // This is light sleep
                break
            case HKCategoryValueSleepAnalysis.asleepDeep.rawValue:
                deepSleepTime += duration
            case HKCategoryValueSleepAnalysis.asleepREM.rawValue:
                remSleepTime += duration
            default:
                break
            }
        }
        
        // If we have sleep data, create an entry
        if totalSleepTime > 0 {
            return SleepEntry(
                id: UUID().uuidString,
                date: date,
                totalSleepTime: totalSleepTime,
                deepSleepTime: deepSleepTime,
                coreSleepTime: totalSleepTime - deepSleepTime - remSleepTime,
                remSleepTime: remSleepTime
            )
        }
        
        return nil
    }
} 
