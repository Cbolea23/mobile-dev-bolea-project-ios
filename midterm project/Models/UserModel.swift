//
//  UserModel.swift
//  midterm project
//
//  Created by Christian Louis on 11/18/26.
//

import Foundation
import CryptoKit

struct UserProfile: Codable, Equatable {
    var username: String
    var email: String
    var recipesCount: Int
    var savedCount: Int
    var cookedCount: Int
    var dietaryPreference: String
    var skillLevel: String
    var notificationsEnabled: Bool
    
    static func defaultProfile(username: String, email: String) -> UserProfile {
        UserProfile(
            username: username,
            email: email,
            recipesCount: 12,
            savedCount: 0,
            cookedCount: 0,
            dietaryPreference: "No restrictions",
            skillLevel: "No preference",
            notificationsEnabled: true
        )
    }
}

/// Represents a persisted user account for local storage and Firebase sync.
struct UserAccount: Codable, Identifiable, Equatable {
    var id: String
    var username: String
    var email: String
    var passwordHash: String
    var profile: UserProfile
    var savedMeals: [RecipeItem]
    var cookedMealIds: [String]
    var checkedIngredientsByMeal: [String: [String]]
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
        case passwordHash
        case profile
        case savedMeals
        case cookedMealIds
        case checkedIngredientsByMeal
    }
    
    private enum LegacyCodingKeys: String, CodingKey {
        case password
    }
    
    init(
        id: String,
        username: String,
        email: String,
        passwordHash: String,
        profile: UserProfile,
        savedMeals: [RecipeItem],
        cookedMealIds: [String],
        checkedIngredientsByMeal: [String: [String]] = [:]
    ) {
        self.id = id
        self.username = username
        self.email = email
        self.passwordHash = passwordHash
        self.profile = profile
        self.savedMeals = savedMeals
        self.cookedMealIds = cookedMealIds
        self.checkedIngredientsByMeal = checkedIngredientsByMeal
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        username = try container.decode(String.self, forKey: .username)
        let rawEmail = try container.decode(String.self, forKey: .email)
        email = rawEmail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        profile = try container.decode(UserProfile.self, forKey: .profile)
        savedMeals = try container.decodeIfPresent([RecipeItem].self, forKey: .savedMeals) ?? []
        cookedMealIds = try container.decodeIfPresent([String].self, forKey: .cookedMealIds) ?? []
        checkedIngredientsByMeal = try container.decodeIfPresent([String: [String]].self, forKey: .checkedIngredientsByMeal) ?? [:]
        
        if let decodedHash = try container.decodeIfPresent(String.self, forKey: .passwordHash) {
            passwordHash = decodedHash
        } else {
            let legacyContainer = try decoder.container(keyedBy: LegacyCodingKeys.self)
            let legacyPassword = try legacyContainer.decodeIfPresent(String.self, forKey: .password) ?? ""
            passwordHash = legacyPassword.isEmpty ? "" : Self.hashPassword(legacyPassword, email: email)
        }
    }
    
    /// Produces a salted SHA-256 hex digest using the normalized account email as salt.
    static func hashPassword(_ password: String, email: String) -> String {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let salted = "\(normalizedEmail):\(password)"
        let digest = SHA256.hash(data: Data(salted.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
