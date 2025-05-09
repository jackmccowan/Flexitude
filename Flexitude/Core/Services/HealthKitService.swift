//
//  HealthKitService.swift
//  Flexitude
//
//  Created by Jack McCowan on 5/5/2025.
//

import Foundation
import HealthKit

class HealthKitService {
    static let shared = HealthKitService()
    
    private let healthStore = HKHealthStore()
    private var isHealthKitAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }
    
    private init() {}
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard isHealthKitAvailable else {
            completion(false, nil)
            return
        }
        
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion(false, nil)
            return
        }
        
        healthStore.requestAuthorization(toShare: [], read: [sleepType]) { success, error in
            completion(success, error)
        }
    }
    
    func isHealthKitAuthorized() -> Bool {
        guard isHealthKitAvailable,
              let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            return false
        }
        
        return healthStore.authorizationStatus(for: sleepType) == .sharingAuthorized
    }
    
    func getHealthStore() -> HKHealthStore {
        return healthStore
    }
} 