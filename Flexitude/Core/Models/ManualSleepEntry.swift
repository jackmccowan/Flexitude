//
//  ManualSleepEntry.swift
//  Flexitude
//
//  Created by Jack McCowan on 5/5/2025.
//

import Foundation

struct ManualSleepEntry: Codable, Identifiable {
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