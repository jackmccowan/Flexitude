//
//  User.swift
//  Flexitude
//
//  Created by Jack McCowan on 5/5/2025.
//

import Foundation

struct User: Codable, Identifiable {
    var id = UUID()
    var firstName: String
    var lastName: String
    var email: String
    var dateOfBirth: Date
    var height: Double //cm
    var weight: Double //cm
    var username: String
    var password: String // need to make this hashed or something secure todo
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    var age: Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
        return ageComponents.year ?? 0
    }
} 