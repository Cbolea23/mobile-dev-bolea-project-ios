//
//  DatabaseService.swift
//  midterm project
//
//  Created by Christian Louis on 11/16/26.
//

import Foundation
import Combine
import CryptoKit

#if canImport(FirebaseCore) && canImport(FirebaseAuth) && canImport(FirebaseFirestore)
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
#endif

enum DatabaseError: LocalizedError {
    case invalidCredentials
    case accountAlreadyExists
    case accountNotFound
    case custom(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Mali ang email o password. Pakisubukan muli."
        case .accountAlreadyExists:
            return "May nakarehistro nang account gamit ang email na ito."
        case .accountNotFound:
            return "Walang nakitang account para sa email na ito."
        case .custom(let message):
            return message
        }
    }
}

/// Hybrid persistence service that works locally via UserDefaults and
/// automatically syncs with Firebase Auth & Firestore once configured.
@MainActor
final class DatabaseService: ObservableObject {
    static let shared = DatabaseService()
    
    @Published private(set) var isFirebaseActive: Bool = false
    
    private let accountsKey = "ulam_registered_accounts_v1"
    private let legacySavedMealsKey = "saved_ulam_meals"
    private let legacyMigratedKey = "ulam_migrated_legacy_meals_v1"
    
    static let defaultEmail = "christianbolea@gmail.com"
    static let guestEmail = "guest@anongulam.ph"
    static let demoPlaceholderPassword = "••••••••"
    
    var backendLabel: String {
        isFirebaseActive ? "Firebase Auth + Firestore" : "Local DB (Firebase Ready)"
    }
    
    private init() {
        ensureDefaultAccountSeeded()
    }
    
    nonisolated static func hashPassword(_ password: String, email: String) -> String {
        UserAccount.hashPassword(password, email: email)
    }
    
    /// Configures Firebase if GoogleService-Info.plist and Firebase SDKs are present.
    func configureIfNeeded() {
        let hasPlist = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
        #if canImport(FirebaseCore) && canImport(FirebaseAuth) && canImport(FirebaseFirestore)
        if hasPlist {
            if FirebaseApp.app() == nil {
                FirebaseApp.configure()
            }
            isFirebaseActive = true
            return
        }
        #endif
        isFirebaseActive = false
        _ = hasPlist
    }
    
    // MARK: - Authentication
    
    func signIn(email: String, password: String) async throws -> UserAccount {
        let normalizedEmail = Self.normalizeEmail(email)
        let passwordHash = Self.hashPassword(password, email: normalizedEmail)
        let seededDemoHash = Self.hashPassword(Self.demoPlaceholderPassword, email: Self.defaultEmail)
        let isDemoCredential = normalizedEmail == Self.defaultEmail
            && (password == Self.demoPlaceholderPassword || password == "password123")
        
        #if canImport(FirebaseCore) && canImport(FirebaseAuth) && canImport(FirebaseFirestore)
        if isFirebaseActive {
            if normalizedEmail == Self.defaultEmail && password == Self.demoPlaceholderPassword {
                ensureDefaultAccountSeeded()
                if let demoAccount = loadExistingAccount(email: Self.defaultEmail),
                   demoAccount.passwordHash == seededDemoHash {
                    return demoAccount
                }
            }
            
            do {
                let authResult = try await Auth.auth().signIn(withEmail: normalizedEmail, password: password)
                let uid = authResult.user.uid
                let fallbackName = authResult.user.displayName ?? Self.fallbackUsername(from: normalizedEmail)
                
                if var remoteAccount = await fetchFirestoreAccount(uid: uid) {
                    remoteAccount.email = normalizedEmail
                    remoteAccount.passwordHash = passwordHash
                    saveAccountLocally(remoteAccount)
                    return remoteAccount
                } else {
                    var local = loadExistingAccount(email: normalizedEmail) ?? makeNewAccount(
                        id: uid,
                        username: fallbackName,
                        email: normalizedEmail,
                        passwordHash: passwordHash
                    )
                    local.id = uid
                    local.passwordHash = passwordHash
                    saveAccountLocally(local)
                    await saveFirestoreAccount(local)
                    return local
                }
            } catch {
                if isDemoCredential {
                    ensureDefaultAccountSeeded()
                    if let demoAccount = loadExistingAccount(email: Self.defaultEmail),
                       demoAccount.passwordHash == seededDemoHash {
                        return demoAccount
                    }
                }
                throw DatabaseError.custom(error.localizedDescription)
            }
        }
        #endif
        
        guard let account = loadExistingAccount(email: normalizedEmail) else {
            throw DatabaseError.accountNotFound
        }
        
        let matchesStored = account.passwordHash == passwordHash
        let matchesDefaultAlias = isDemoCredential && account.passwordHash == seededDemoHash
        
        guard matchesStored || matchesDefaultAlias else {
            throw DatabaseError.invalidCredentials
        }
        
        return account
    }
    
    func register(username: String, email: String, password: String) async throws -> UserAccount {
        let normalizedEmail = Self.normalizeEmail(email)
        let cleanUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let passwordHash = Self.hashPassword(password, email: normalizedEmail)
        
        #if canImport(FirebaseCore) && canImport(FirebaseAuth) && canImport(FirebaseFirestore)
        if isFirebaseActive {
            do {
                let authResult = try await Auth.auth().createUser(withEmail: normalizedEmail, password: password)
                let changeRequest = authResult.user.createProfileChangeRequest()
                changeRequest.displayName = cleanUsername
                try? await changeRequest.commitChanges()
                
                let newAccount = makeNewAccount(
                    id: authResult.user.uid,
                    username: cleanUsername,
                    email: normalizedEmail,
                    passwordHash: passwordHash
                )
                saveAccountLocally(newAccount)
                await saveFirestoreAccount(newAccount)
                return newAccount
            } catch {
                throw DatabaseError.custom(error.localizedDescription)
            }
        }
        #endif
        
        if loadExistingAccount(email: normalizedEmail) != nil {
            throw DatabaseError.accountAlreadyExists
        }
        
        let newAccount = makeNewAccount(
            id: normalizedEmail,
            username: cleanUsername,
            email: normalizedEmail,
            passwordHash: passwordHash
        )
        saveAccountLocally(newAccount)
        return newAccount
    }
    
    func sendPasswordReset(email: String, newPassword: String?) async throws {
        let normalizedEmail = Self.normalizeEmail(email)
        
        #if canImport(FirebaseCore) && canImport(FirebaseAuth) && canImport(FirebaseFirestore)
        if isFirebaseActive {
            do {
                try await Auth.auth().sendPasswordReset(withEmail: normalizedEmail)
                return
            } catch {
                throw DatabaseError.custom(error.localizedDescription)
            }
        }
        #endif
        
        guard var account = loadExistingAccount(email: normalizedEmail) else {
            throw DatabaseError.accountNotFound
        }
        if let newPassword, !newPassword.isEmpty {
            account.passwordHash = Self.hashPassword(newPassword, email: normalizedEmail)
            saveAccountLocally(account)
        }
    }
    
    func signOut() {
        #if canImport(FirebaseCore) && canImport(FirebaseAuth) && canImport(FirebaseFirestore)
        if isFirebaseActive {
            try? Auth.auth().signOut()
        }
        #endif
    }
    
    // MARK: - Account & Meal Data Persistence
    
    func loadUserAccount(email: String) -> UserAccount {
        let normalizedEmail = Self.normalizeEmail(email)
        if let existing = loadExistingAccount(email: normalizedEmail) {
            return existing
        }
        if normalizedEmail == Self.guestEmail {
            let guest = makeNewAccount(
                id: Self.guestEmail,
                username: "Bisita",
                email: Self.guestEmail,
                passwordHash: ""
            )
            saveAccountLocally(guest)
            return guest
        }
        ensureDefaultAccountSeeded()
        return loadExistingAccount(email: Self.defaultEmail) ?? makeNewAccount(
            id: normalizedEmail,
            username: Self.fallbackUsername(from: normalizedEmail),
            email: normalizedEmail,
            passwordHash: ""
        )
    }
    
    func saveUserAccount(_ account: UserAccount) async {
        var updated = account
        updated.email = Self.normalizeEmail(account.email)
        updated.profile.username = account.username
        updated.profile.email = updated.email
        updated.profile.savedCount = account.savedMeals.count
        updated.profile.cookedCount = max(account.profile.cookedCount, account.cookedMealIds.count)
        
        saveAccountLocally(updated)
        
        if updated.email == Self.defaultEmail {
            if let encoded = try? JSONEncoder().encode(updated.savedMeals) {
                UserDefaults.standard.set(encoded, forKey: legacySavedMealsKey)
            }
        }
        
        #if canImport(FirebaseCore) && canImport(FirebaseAuth) && canImport(FirebaseFirestore)
        if isFirebaseActive,
           updated.email != Self.guestEmail,
           Auth.auth().currentUser != nil {
            await saveFirestoreAccount(updated)
        }
        #endif
    }
    
    // MARK: - Local Storage Helpers
    
    private func loadAllAccounts() -> [String: UserAccount] {
        guard let data = UserDefaults.standard.data(forKey: accountsKey),
              let decoded = try? JSONDecoder().decode([String: UserAccount].self, from: data) else {
            return [:]
        }
        return decoded
    }
    
    private func saveAllAccounts(_ accounts: [String: UserAccount]) {
        if let encoded = try? JSONEncoder().encode(accounts) {
            UserDefaults.standard.set(encoded, forKey: accountsKey)
        }
    }
    
    private func loadExistingAccount(email: String) -> UserAccount? {
        let normalized = Self.normalizeEmail(email)
        return loadAllAccounts()[normalized]
    }
    
    private func saveAccountLocally(_ account: UserAccount) {
        var accounts = loadAllAccounts()
        accounts[Self.normalizeEmail(account.email)] = account
        saveAllAccounts(accounts)
    }
    
    private func ensureDefaultAccountSeeded() {
        var accounts = loadAllAccounts()
        guard accounts[Self.defaultEmail] == nil else { return }
        
        var legacyMeals: [RecipeItem] = []
        if !UserDefaults.standard.bool(forKey: legacyMigratedKey),
           let data = UserDefaults.standard.data(forKey: legacySavedMealsKey),
           let decoded = try? JSONDecoder().decode([RecipeItem].self, from: data) {
            legacyMeals = decoded
        }
        UserDefaults.standard.set(true, forKey: legacyMigratedKey)
        
        var defaultAccount = makeNewAccount(
            id: Self.defaultEmail,
            username: "Christian",
            email: Self.defaultEmail,
            passwordHash: Self.hashPassword(Self.demoPlaceholderPassword, email: Self.defaultEmail)
        )
        defaultAccount.savedMeals = legacyMeals
        defaultAccount.profile.savedCount = legacyMeals.count
        accounts[Self.defaultEmail] = defaultAccount
        saveAllAccounts(accounts)
    }
    
    private func makeNewAccount(id: String, username: String, email: String, passwordHash: String) -> UserAccount {
        let normalized = Self.normalizeEmail(email)
        return UserAccount(
            id: id,
            username: username,
            email: normalized,
            passwordHash: passwordHash,
            profile: UserProfile.defaultProfile(username: username, email: normalized),
            savedMeals: [],
            cookedMealIds: [],
            checkedIngredientsByMeal: [:]
        )
    }
    
    nonisolated static func normalizeEmail(_ email: String) -> String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
    
    private static func fallbackUsername(from email: String) -> String {
        let prefix = email.split(separator: "@").first.map(String.init) ?? "Chef"
        return prefix.capitalized
    }
    
    // MARK: - Firestore Helpers
    
    #if canImport(FirebaseCore) && canImport(FirebaseAuth) && canImport(FirebaseFirestore)
    private func saveFirestoreAccount(_ account: UserAccount) async {
        // Avoid storing password hashes in Firestore
        var sanitized = account
        sanitized.passwordHash = ""
        guard let data = try? JSONEncoder().encode(sanitized),
              let dict = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else {
            return
        }
        do {
            try await Firestore.firestore()
                .collection("users")
                .document(account.id)
                .setData(dict, merge: true)
        } catch {
            print("Firestore save error: \(error.localizedDescription)")
        }
    }
    
    private func fetchFirestoreAccount(uid: String) async -> UserAccount? {
        do {
            let snapshot = try await Firestore.firestore()
                .collection("users")
                .document(uid)
                .getDocument()
            guard let data = snapshot.data() else { return nil }
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            return try JSONDecoder().decode(UserAccount.self, from: jsonData)
        } catch {
            print("Firestore fetch error: \(error.localizedDescription)")
            return nil
        }
    }
    #endif
}
