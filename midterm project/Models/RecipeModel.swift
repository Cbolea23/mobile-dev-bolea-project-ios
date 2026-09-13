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

struct UserProfile: Codable {
    var username: String
    var email: String
    var favoriteCuisine: String
}
