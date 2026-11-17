//
//  RecipeModel.swift
//  midterm project
//
//  Created by Christian Louis on 9/12/26.
//

import Foundation

struct CategoryResponse: Codable {
    let categories: [Category]
}

struct Category: Codable, Identifiable {
    let idCategory: String
    let strCategory: String
    let strCategoryThumb: String
    let strCategoryDescription: String
    
    var id: String { idCategory }
}

struct MealResponse: Codable {
    let meals: [Meal]?
}

struct Meal: Codable, Identifiable {
    let idMeal: String
    let strMeal: String
    let strMealThumb: String
    
    var id: String { idMeal }
}
 
struct RecipeItem: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let nativeName: String
    let origin: String
    let time: String
    let servings: String
    let calories: String
    let rating: String
    let category: String
    let difficulty: String
    let imageUrl: String
    let ingredients: [String]
    let instructions: [String]
}

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
    var password: String
    var profile: UserProfile
    var savedMeals: [RecipeItem]
    var cookedMealIds: [String]
}
