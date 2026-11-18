//
//  AuthController.swift
//  midterm project
//
//  Created by louis on 9/13/26.
//

import Foundation
import Combine

typealias AuthViewModel = AuthController

@MainActor
class AuthController: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUserEmail: String = DatabaseService.defaultEmail
    @Published var currentUserName: String = "Christian"
    @Published var userProfile: UserProfile = UserProfile.defaultProfile(
        username: "Christian",
        email: DatabaseService.defaultEmail
    )
    @Published var authError: String? = nil
    @Published var authSuccessMessage: String? = nil
    @Published var isSubmitting: Bool = false
    
    init() {
        let initialAccount = DatabaseService.shared.loadUserAccount(email: DatabaseService.defaultEmail)
        self.currentUserEmail = initialAccount.email
        self.currentUserName = initialAccount.username
        self.userProfile = initialAccount.profile
    }
    
    func clearMessages() {
        authError = nil
        authSuccessMessage = nil
    }
    
    func login(email: String, password: String) async {
        clearMessages()
        let cleanEmail = DatabaseService.normalizeEmail(email)
        
        guard isValidEmail(cleanEmail) else {
            authError = "Maglagay ng wastong email address."
            return
        }
        guard !password.isEmpty else {
            authError = "Pakilagay ang iyong password."
            return
        }
        
        isSubmitting = true
        defer { isSubmitting = false }
        
        do {
            let account = try await DatabaseService.shared.signIn(email: cleanEmail, password: password)
            applyAccount(account)
            isAuthenticated = true
        } catch {
            authError = error.localizedDescription
        }
    }
    
    func register(username: String, email: String, password: String, confirmPassword: String) async {
        clearMessages()
        let cleanName = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanEmail = DatabaseService.normalizeEmail(email)
        
        guard !cleanName.isEmpty else {
            authError = "Pakilagay ang iyong pangalan o username."
            return
        }
        guard isValidEmail(cleanEmail) else {
            authError = "Maglagay ng wastong email address."
            return
        }
        guard password.count >= 6 else {
            authError = "Ang password ay dapat may hindi bababa sa 6 na character."
            return
        }
        guard password == confirmPassword else {
            authError = "Hindi tugma ang password at confirm password."
            return
        }
        
        isSubmitting = true
        defer { isSubmitting = false }
        
        do {
            let account = try await DatabaseService.shared.register(
                username: cleanName,
                email: cleanEmail,
                password: password
            )
            applyAccount(account)
            isAuthenticated = true
        } catch {
            authError = error.localizedDescription
        }
    }
    
    func resetPassword(email: String, newPassword: String) async -> Bool {
        clearMessages()
        let cleanEmail = DatabaseService.normalizeEmail(email)
        
        guard isValidEmail(cleanEmail) else {
            authError = "Maglagay ng wastong email address."
            return false
        }
        
        if !DatabaseService.shared.isFirebaseActive && newPassword.count < 6 {
            authError = "Ang bagong password ay dapat may hindi bababa sa 6 na character."
            return false
        }
        
        isSubmitting = true
        defer { isSubmitting = false }
        
        do {
            try await DatabaseService.shared.sendPasswordReset(
                email: cleanEmail,
                newPassword: newPassword.isEmpty ? nil : newPassword
            )
            authSuccessMessage = DatabaseService.shared.isFirebaseActive
                ? "Naipadala na ang password reset email sa \(cleanEmail)."
                : "Matagumpay na na-update ang password para sa \(cleanEmail)."
            return true
        } catch {
            authError = error.localizedDescription
            return false
        }
    }
    
    func continueAsGuest() {
        clearMessages()
        let guestAccount = DatabaseService.shared.loadUserAccount(email: DatabaseService.guestEmail)
        applyAccount(guestAccount)
        isAuthenticated = true
    }
    
    func updateProfile(
        username: String,
        dietaryPreference: String,
        skillLevel: String,
        notificationsEnabled: Bool
    ) {
        let cleanName = username.trimmingCharacters(in: .whitespacesAndNewlines)
        if !cleanName.isEmpty {
            currentUserName = cleanName
        }
        
        userProfile.username = currentUserName
        userProfile.email = currentUserEmail
        userProfile.dietaryPreference = dietaryPreference
        userProfile.skillLevel = skillLevel
        userProfile.notificationsEnabled = notificationsEnabled
        
        var account = DatabaseService.shared.loadUserAccount(email: currentUserEmail)
        account.username = currentUserName
        account.profile = userProfile
        Task {
            await DatabaseService.shared.saveUserAccount(account)
        }
    }
    
    func recordCookedCount(_ count: Int) {
        userProfile.cookedCount = max(userProfile.cookedCount, count)
        var account = DatabaseService.shared.loadUserAccount(email: currentUserEmail)
        account.profile = userProfile
        Task {
            await DatabaseService.shared.saveUserAccount(account)
        }
    }
    
    func logout() {
        DatabaseService.shared.signOut()
        clearMessages()
        isAuthenticated = false
    }
    
    private func applyAccount(_ account: UserAccount) {
        currentUserEmail = account.email
        currentUserName = account.username
        userProfile = account.profile
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              trimmed.rangeOfCharacter(from: .whitespacesAndNewlines) == nil else {
            return false
        }
        let parts = trimmed.split(separator: "@", omittingEmptySubsequences: false)
        guard parts.count == 2,
              !parts[0].isEmpty else {
            return false
        }
        let domainParts = parts[1].split(separator: ".", omittingEmptySubsequences: false)
        guard domainParts.count >= 2,
              domainParts.allSatisfy({ !$0.isEmpty }) else {
            return false
        }
        return true
    }
}
