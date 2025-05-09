//
//  SleepService.swift
//  Flexitude
//
//  Created by Jack McCowan on 5/5/2025.
//

import Foundation
import HealthKit

struct SleepData {
    let date: Date
    let startTime: Date
    let endTime: Date
    let duration: TimeInterval
    let type: SleepType
    
    var durationInHours: Double {
        return duration / 3600
    }
}

enum SleepType: String {
    case inBed = "SLEEP_IN_BED"
    case awake = "SLEEP_AWAKE"
    case core = "SLEEP_CORE"
    case deep = "SLEEP_DEEP"
    case rem = "SLEEP_REM"
    case unspecified = "SLEEP_UNSPECIFIED"
    
    init(from healthKitValue: Int) {
        switch healthKitValue {
        case HKCategoryValueSleepAnalysis.inBed.rawValue:
            self = .inBed
        case HKCategoryValueSleepAnalysis.awake.rawValue:
            self = .awake
        case HKCategoryValueSleepAnalysis.asleepCore.rawValue:
            self = .core
        case HKCategoryValueSleepAnalysis.asleepDeep.rawValue:
            self = .deep
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
        case .core: return "Core Sleep"
        case .deep: return "Deep Sleep"
        case .rem: return "REM Sleep"
        case .unspecified: return "Unspecified"
        }
    }
    
    var color: String {
        switch self {
        case .inBed: return "gray"
        case .awake: return "yellow"
        case .core: return "blue"
        case .deep: return "indigo"
        case .rem: return "purple"
        case .unspecified: return "secondary"
        }
    }
}

class SleepService {
    private let healthStore: HKHealthStore
    
    init(healthStore: HKHealthStore) {
        self.healthStore = healthStore
    }
    
    func fetchSleepData(for date: Date, completion: @escaping ([SleepData]?, Error?) -> Void) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion(nil, NSError(domain: "SleepService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Sleep analysis type not available"]))
            return
        }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]) { (_, samples, error) in
            guard let samples = samples as? [HKCategorySample], error == nil else {
                completion(nil, error)
                return
            }
            
            let sleepData = samples.map { sample -> SleepData in
                return SleepData(
                    date: startOfDay,
                    startTime: sample.startDate,
                    endTime: sample.endDate,
                    duration: sample.endDate.timeIntervalSince(sample.startDate),
                    type: SleepType(from: sample.value)
                )
            }
            
            completion(sleepData, nil)
        }
        
        healthStore.execute(query)
    }
    
    func fetchSleepDataForLastWeek(completion: @escaping ([Date: [SleepData]]?, Error?) -> Void) {
        let calendar = Calendar.current
        let today = Date()
        let startDate = calendar.date(byAdding: .day, value: -7, to: calendar.startOfDay(for: today))!
        
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion(nil, NSError(domain: "SleepService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Sleep analysis type not available"]))
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: today, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]) { (_, samples, error) in
            guard let samples = samples as? [HKCategorySample], error == nil else {
                completion(nil, error)
                return
            }
            
            var sleepByDay = [Date: [SleepData]]()
            
            for sample in samples {
                let dayStart = calendar.startOfDay(for: sample.startDate)
                
                let sleepData = SleepData(
                    date: dayStart,
                    startTime: sample.startDate,
                    endTime: sample.endDate,
                    duration: sample.endDate.timeIntervalSince(sample.startDate),
                    type: SleepType(from: sample.value)
                )
                
                if sleepByDay[dayStart] == nil {
                    sleepByDay[dayStart] = [sleepData]
                } else {
                    sleepByDay[dayStart]?.append(sleepData)
                }
            }
            
            completion(sleepByDay, nil)
        }
        
        healthStore.execute(query)
    }
    
    func getTotalSleepDuration(from sleepData: [SleepData]) -> TimeInterval {
        let sleepTypes: [SleepType] = [.core, .deep, .rem]
        let sleepItems = sleepData.filter { sleepTypes.contains($0.type) }
        return sleepItems.reduce(0) { $0 + $1.duration }
    }
    
    func getTotalDurationForType(_ type: SleepType, from sleepData: [SleepData]) -> TimeInterval {
        let sleepItems = sleepData.filter { $0.type == type }
        return sleepItems.reduce(0) { $0 + $1.duration }
    }
} 