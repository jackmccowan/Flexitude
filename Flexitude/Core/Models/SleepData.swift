 //
//  SleepData.swift
//  Flexitude
//
//  Created by Jack McCowan on 5/5/2025.
//

import Foundation

struct SleepEntry: Codable, Identifiable {
    let id: String
    let date: Date
    var totalSleepTime: TimeInterval
    var deepSleepTime: TimeInterval
    var coreSleepTime: TimeInterval
    var remSleepTime: TimeInterval
    
    init(id: String = UUID().uuidString,
         date: Date = Date(),
         totalSleepTime: TimeInterval,
         deepSleepTime: TimeInterval,
         coreSleepTime: TimeInterval,
         remSleepTime: TimeInterval) {
        self.id = id
        self.date = date
        self.totalSleepTime = totalSleepTime
        self.deepSleepTime = deepSleepTime
        self.coreSleepTime = coreSleepTime
        self.remSleepTime = remSleepTime
    }
}

enum SleepStage: String, CaseIterable {
    case deep
    case core
    case rem
    
    var displayName: String {
        switch self {
        case .deep: return "Deep Sleep"
        case .core: return "Core Sleep"
        case .rem: return "REM Sleep"
        }
    }
    
    var description: String {
        switch self {
        case .deep: return "Deep sleep is crucial for physical recovery and memory consolidation."
        case .core: return "Core sleep is the light sleep stage where your body starts to relax."
        case .rem: return "REM sleep is important for cognitive functions and dreaming."
        }
    }
}

struct SleepStageStat: Identifiable {
    let id: String
    var stage: SleepStage
    var duration: TimeInterval
    var percentage: Double
    
    init(id: String = UUID().uuidString, stage: SleepStage, duration: TimeInterval, percentage: Double) {
        self.id = id
        self.stage = stage
        self.duration = duration
        self.percentage = percentage
    }
}