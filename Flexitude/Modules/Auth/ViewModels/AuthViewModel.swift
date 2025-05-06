//
//  AuthViewModel.swift
//  Flexitude
//
//  Created by Jack McCowan on 5/5/2025.
//

import Foundation
import SwiftUI

class AuthViewModel: ObservableObject {
    private let userService = UserService()
    
    // Login properties
    @Published var loginUsername = ""
    @Published var loginPassword = ""
    @Published var loginError = ""
    @Published var isLoggedIn = false
    
    // Registration properties
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var dateOfBirth = Date()
    @Published var height: Double = 170
    @Published var weight: Double = 70
    @Published var username = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var registrationError = ""
    @Published var registrationSuccess = false
    
    // Current user
    @Published var currentUser: User?
    
    init() {
        currentUser = userService.getCurrentUser()
        isLoggedIn = currentUser != nil
    }
    
    func login() {
        guard !loginUsername.isEmpty, !loginPassword.isEmpty else {
            loginError = "Please enter both username and password"
            return
        }
        
        if let user = userService.login(username: loginUsername, password: loginPassword) {
            self.currentUser = user
            self.isLoggedIn = true
            self.loginError = ""
        } else {
            loginError = "Invalid username or password"
        }
    }
    
    func register() {
        if firstName.isEmpty || lastName.isEmpty || email.isEmpty || username.isEmpty || password.isEmpty {
            registrationError = "All fields are required"
            return
        }
        
        if !isValidEmail(email) {
            registrationError = "Please enter a valid email"
            return
        }
        
        if password != confirmPassword {
            registrationError = "Passwords do not match"
            return
        }
        
        let newUser = User(
            firstName: firstName,
            lastName: lastName,
            email: email,
            dateOfBirth: dateOfBirth,
            height: height,
            weight: weight,
            username: username,
            password: password
        )
        
        if userService.saveUser(newUser) {
            registrationSuccess = true
            registrationError = ""
            
            clearRegistrationFields()
        } else {
            registrationError = "Username already exists"
        }
    }
    
    func logout() {
        userService.logout()
        isLoggedIn = false
        currentUser = nil
    }
    
    func clearRegistrationFields() {
        firstName = ""
        lastName = ""
        email = ""
        dateOfBirth = Date()
        height = 170
        weight = 70
        username = ""
        password = ""
        confirmPassword = ""
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}