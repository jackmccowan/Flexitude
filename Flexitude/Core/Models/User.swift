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
    
    // Copy-like method (don't think swift has one natively
    func with(
        firstName: String? = nil,
        lastName: String? = nil,
        email: String? = nil,
        dateOfBirth: Date? = nil,
        height: Double? = nil,
        weight: Double? = nil,
        username: String? = nil,
        password: String? = nil
    ) -> User {
        return User(
            firstName: firstName ?? self.firstName,
            lastName: lastName ?? self.lastName,
            email: email ?? self.email,
            dateOfBirth: dateOfBirth ?? self.dateOfBirth,
            height: height ?? self.height,
            weight: weight ?? self.weight,
            username: username ?? self.username,
            password: password ?? self.password
        )
    }
}
