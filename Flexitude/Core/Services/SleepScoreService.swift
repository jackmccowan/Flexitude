//
//  SleepScoreService.swift
//  Flexitude
//
//  Created by Jack McCowan on 5/7/2025.
//

import Foundation

struct SleepScore {
    let score: Int
    let label: String
    let color: String
    
    static func getLabel(for score: Int) -> String {
        switch score {
        case 90...100: return "Excellent"
        case 70..<90: return "Good"
        case 50..<70: return "Fair"
        case 30..<50: return "Poor"
        case 1..<30: return "Very Poor"
        default: return "No Data"
        }
    }
    
    static func getColor(for score: Int) -> String {
        switch score {
        case 90...100: return "green"
        case 70..<90: return "mint"
        case 50..<70: return "yellow"
        case 30..<50: return "orange"
        case 1..<30: return "red"
        default: return "gray"
        }
    }
}

class SleepScoreService {
    func calculateScore(for sleepEntry: SleepEntry?) -> SleepScore {
        guard let entry = sleepEntry else {
            return SleepScore(score: 0, label: SleepScore.getLabel(for: 0), color: SleepScore.getColor(for: 0))
        }
        
        // Convert to hours for easier comparison
        let deepSleepHours = entry.deepSleepTime / 3600
        let remSleepHours = entry.remSleepTime / 3600
        let totalSleepHours = entry.totalSleepTime / 3600
        
        var score = 0
        
        // Excellent: >1.5hrs deep, >2hrs REM, >7.5hrs total
        if deepSleepHours > 1.5 && remSleepHours > 2.0 && totalSleepHours > 7.5 {
            score = 100
        }
        // Good: >30mins deep, >1hr REM, >6.5hrs total
        else if deepSleepHours > 0.5 && remSleepHours > 1.0 && totalSleepHours > 6.5 {
            score = 80
        }
        // Fair: >15mins deep, >30mins REM, >5.5hrs total
        else if deepSleepHours > 0.25 && remSleepHours > 0.5 && totalSleepHours > 5.5 {
            score = 60
        }
        // Poor: >5mins deep, >15mins REM, >4.5hrs total
        else if deepSleepHours > 0.083 && remSleepHours > 0.25 && totalSleepHours > 4.5 {
            score = 40
        }
        // Very Poor: Any sleep data below the above thresholds
        else if totalSleepHours > 0 {
            score = 20
        }
        
        return SleepScore(
            score: score,
            label: SleepScore.getLabel(for: score),
            color: SleepScore.getColor(for: score)
        )
    }
} 