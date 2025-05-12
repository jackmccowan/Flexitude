//
//  SleepDataStorageService.swift
//  Flexitude
//
//  Created by Jack McCowan on 5/5/2025.
//

import Foundation

class SleepDataStorageService {
    private let storageKey = "manualSleepEntries"
    
    func saveEntry(_ entry: ManualSleepEntry) {
        var entries = getAllEntries()
        
        // Remove any existing entry for the same date
        entries.removeAll { Calendar.current.isDate($0.date, inSameDayAs: entry.date) }
        
        entries.append(entry)
        
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    func getAllEntries() -> [ManualSleepEntry] {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let entries = try? JSONDecoder().decode([ManualSleepEntry].self, from: data) {
            return entries
        }
        return []
    }
    
    func getEntry(for date: Date) -> ManualSleepEntry? {
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