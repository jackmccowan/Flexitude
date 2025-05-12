 //
//  HealthKitService.swift
//  Flexitude
//
//  Created by Jack McCowan on 5/5/2025.
//

import Foundation
import HealthKit
import SwiftUICore

class HealthKitService {
    static let shared = HealthKitService()
    
    private let healthStore = HKHealthStore()
    
    private init() {}
    
    var isHealthKitAvailable: Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    func requestSleepAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard isHealthKitAvailable else {
            completion(false, NSError(domain: "HealthKitService", code: 1, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device"]))
            return
        }
        
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion(false, NSError(domain: "HealthKitService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Sleep analysis is not available"]))
            return
        }
        
        let typesToRead: Set<HKObjectType> = [sleepType]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
    
    func isSleepDataAuthorized() -> Bool {
        guard isHealthKitAvailable,
              let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            return false
        }
        
        return healthStore.authorizationStatus(for: sleepType) == .sharingAuthorized
    }
    
    func fetchSleepData(for date: Date, completion: @escaping (Result<[SleepEntry], Error>) -> Void) {
        guard isHealthKitAvailable else {
            completion(.failure(NSError(domain: "HealthKitService", code: 1, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device"])))
            return
        }
        
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion(.failure(NSError(domain: "HealthKitService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Sleep analysis is not available"])))
            return
        }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        
        let query = HKSampleQuery(
            sampleType: sleepType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
        ) { (_, samples, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let samples = samples as? [HKCategorySample] else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "HealthKitService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Could not convert samples to the expected type"])))
                }
                return
            }
            
            let sleepEntries = samples.map { sample in
                SleepEntry(
                    startDate: sample.startDate,
                    endDate: sample.endDate,
                    sleepStage: SleepStage(healthKitValue: sample.value)
                )
            }
            
            DispatchQueue.main.async {
                completion(.success(sleepEntries))
            }
        }
        
        healthStore.execute(query)
    }
}

// Sleep data models
struct SleepEntry {
    let startDate: Date
    let endDate: Date
    let sleepStage: SleepStage
    
    var duration: TimeInterval {
        return endDate.timeIntervalSince(startDate)
    }
}

enum SleepStage: String, CaseIterable {
    case inBed = "SLEEP_IN_BED"
    case awake = "SLEEP_AWAKE"
    case deep = "SLEEP_DEEP"
    case core = "SLEEP_CORE"
    case rem = "SLEEP_REM"
    case unspecified = "SLEEP_UNSPECIFIED"
    
    init(healthKitValue: Int) {
        switch healthKitValue {
        case HKCategoryValueSleepAnalysis.inBed.rawValue:
            self = .inBed
        case HKCategoryValueSleepAnalysis.awake.rawValue:
            self = .awake
        case HKCategoryValueSleepAnalysis.asleepDeep.rawValue:
            self = .deep
        case HKCategoryValueSleepAnalysis.asleepCore.rawValue:
            self = .core
        case HKCategoryValueSleepAnalysis.asleepREM.rawValue:
            self = .rem
        default:
            self = .unspecified
        }
    }
    
    var displayName: String {
        switch self {
        case .inBed: return "In Bed"
        case .awake: return "Awake"
        case .deep: return "Deep Sleep"
        case .core: return "Core Sleep"
        case .rem: return "REM Sleep"
        case .unspecified: return "Unspecified"
        }
    }
    
    var color: Color {
        switch self {
        case .inBed: return .gray
        case .awake: return .yellow
        case .deep: return .indigo
        case .core: return .blue
        case .rem: return .purple
        case .unspecified: return .secondary
        }
    }
}
