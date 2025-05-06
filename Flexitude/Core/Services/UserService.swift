//
//  UserService.swift
//  Flexitude
//
//  Created by Jack McCowan on 5/5/2025.
//

import Foundation

class UserService {
    private let userDefaultsKey = "savedUsers"
    private let currentUserKey = "currentUser"
    
    func saveUser(_ user: User) -> Bool {
        var users = getAllUsers()
        
        if users.contains(where: { $0.username == user.username }) {
            return false
        }
        
        users.append(user)
        saveAllUsers(users)
        return true
    }
    
    // Verify login credentials
    func login(username: String, password: String) -> User? {
        let users = getAllUsers()
        let user = users.first(where: { $0.username == username && $0.password == password })
        
        if let user = user {
            saveCurrentUser(user)
        }
        
        return user
    }
    
    func getCurrentUser() -> User? {
        guard let userData = UserDefaults.standard.data(forKey: currentUserKey) else {
            return nil
        }
        
        return try? JSONDecoder().decode(User.self, from: userData)
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: currentUserKey)
    }
    
    // MARK: - Private Helper Methods - Could be good to move these later
    
    private func getAllUsers() -> [User] {
        guard let userData = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            return []
        }
        
        return (try? JSONDecoder().decode([User].self, from: userData)) ?? []
    }
    
    private func saveAllUsers(_ users: [User]) {
        if let encodedData = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(encodedData, forKey: userDefaultsKey)
        }
    }
    
    private func saveCurrentUser(_ user: User) {
        if let encodedData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encodedData, forKey: currentUserKey)
        }
    }
} 