//
//  SleepData.swift
//  Flexitude
//
//  Created by Jack McCowan on 5/5/2025.
//

import Foundation
import SwiftUI

struct SleepEntry: Codable, Identifiable {
    var id = UUID()
    var date: Date
    var totalSleepTime: TimeInterval
    var deepSleepTime: TimeInterval
    var coreSleepTime: TimeInterval
    var remSleepTime: TimeInterval
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

enum SleepStage: String, CaseIterable {
    case deep = "SLEEP_DEEP"
    case core = "SLEEP_CORE"
    case rem = "SLEEP_REM"
    
    var displayName: String {
        switch self {
        case .deep: return "Deep Sleep"
        case .core: return "Core Sleep"
        case .rem: return "REM Sleep"
        }
    }
    
    var color: Color {
        switch self {
        case .deep: return .indigo
        case .core: return .blue
        case .rem: return .purple
        }
    }
}

struct SleepStageStat: Identifiable {
    var id = UUID()
    var stage: SleepStage
    var duration: TimeInterval
    var percentage: Double
} 