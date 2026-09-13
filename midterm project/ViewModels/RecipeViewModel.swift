//
//  RecipeViewModel.swift
//  midterm project
//
//  Created by Christian Louis on 9/12/26.
//

import SwiftUI
import Combine

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var user = UserProfile(username: "Chef Alex", email: "alex@recipe.com", favoriteCuisine: "Italian")
    
    func login(username: String) {
        guard !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        user.username = username
        isLoggedIn = true
    }
    
    func logout() {
        isLoggedIn = false
    }
}

class RecipeViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var meals: [Meal] = []
    @Published var isLoading = false
    
    func fetchCategories() {
        guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/categories.php") else { return }
        isLoading = true
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self, let data = data else {
                DispatchQueue.main.async { self?.isLoading = false }
                return
            }
            let decoded = try? JSONDecoder().decode(CategoryResponse.self, from: data)
            DispatchQueue.main.async {
                self.isLoading = false
                if let decoded = decoded {
                    self.categories = decoded.categories
                }
            }
        }.resume()
    }
    
    func fetchMeals(category: String) {
        guard let encodedCategory = category.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://www.themealdb.com/api/json/v1/1/filter.php?c=\(encodedCategory)") else { return }
        isLoading = true
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self, let data = data else {
                DispatchQueue.main.async { self?.isLoading = false }
                return
            }
            let decoded = try? JSONDecoder().decode(MealResponse.self, from: data)
            DispatchQueue.main.async {
                self.isLoading = false
                if let decoded = decoded, let meals = decoded.meals {
                    self.meals = meals
                }
            }
        }.resume()
    }
}
