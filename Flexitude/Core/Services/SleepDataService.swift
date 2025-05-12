//
//  SleepDataService.swift
//  Flexitude
//
//  Created by Jack McCowan on 5/5/2025.
//

import Foundation

class SleepDataService {
    private let storageKey = "manualSleepEntries"
    
    func saveEntry(_ entry: SleepEntry) {
        var entries = getAllEntries()
        
        // Remove any existing entry for the same date
        entries.removeAll { Calendar.current.isDate($0.date, inSameDayAs: entry.date) }
        
        entries.append(entry)
        
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    func getAllEntries() -> [SleepEntry] {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let entries = try? JSONDecoder().decode([SleepEntry].self, from: data) {
            return entries
        }
        return []
    }
    
    func getEntry(for date: Date) -> SleepEntry? {
        return getAllEntries().first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    func deleteEntry(for date: Date) {
        var entries = getAllEntries()
        entries.removeAll { Calendar.current.isDate($0.date, inSameDayAs: date) }
        
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
} 