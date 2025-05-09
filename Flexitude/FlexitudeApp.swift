//
//  FlexitudeApp.swift
//  Flexitude
//
//  Created by Jack McCowan on 4/5/2025.
//

import SwiftUI
import HealthKit

@main
struct FlexitudeApp: App {
    @StateObject private var healthStore = HealthStoreManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(healthStore)
        }
    }
}

// Central manager for HealthKit access
class HealthStoreManager: ObservableObject {
    let healthStore = HKHealthStore()
    @Published var isAuthorized = false
    
    init() {
        checkHealthKitAuthorization()
    }
    
    func checkHealthKitAuthorization() {
        if HKHealthStore.isHealthDataAvailable() {
            let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
            let status = healthStore.authorizationStatus(for: sleepType)
            isAuthorized = status == .sharingAuthorized
        }
    }
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, nil)
            return
        }
        
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let typesToRead: Set<HKObjectType> = [sleepType]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isAuthorized = success
                completion(success, error)
            }
        }
    }
}
