//
//  RecipeViewModel.swift
//  midterm project
//
//  Created by Christian Louis on 9/12/26.
//

import Foundation
import Combine

@MainActor
class RecipeViewModel: ObservableObject {
    @Published var selectedCategory: String = "All"
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var checkedIngredients: Set<String> = []
    @Published var cookedMealIds: Set<String> = []
    
    private(set) var currentAccountEmail: String = DatabaseService.defaultEmail
    private var isSyncingAccount = false
    
    // Default for offline fallback
    @Published var featuredMeal: RecipeItem = RecipeItem(
        id: "52854",
        title: "Pork Sinigang",
        nativeName: "Sinigang na Baboy",
        origin: "Filipino",
        time: "1 hr",
        servings: "6 servings",
        calories: "310 kcal",
        rating: "4.8",
        category: "Pork",
        difficulty: "Medium",
        imageUrl: "https://www.themealdb.com/images/media/meals/020z181619788503.jpg",
        ingredients: [
            "700g pork ribs",
            "1 pack tamarind mix (40g)",
            "2 medium tomatoes, quartered",
            "1 onion, quartered",
            "2 cups kangkong (water spinach)",
            "200g string beans",
            "2 medium radishes, sliced",
            "6 cups water",
            "Fish sauce to taste"
        ],
        instructions: [
            "Boil water in a pot, add sliced onions and tomatoes.",
            "Add pork ribs and simmer until tender (approx. 40 minutes).",
            "Pour in the tamarind soup base mix and stir.",
            "Add sliced radishes and string beans; cook for 5 minutes.",
            "Add kangkong and season with fish sauce. Serve steaming hot."
        ]
    )
    
    @Published var popularMeals: [RecipeItem] = []
    
    @Published var savedMeals: [RecipeItem] = [] {
        didSet {
            if !isSyncingAccount {
                persistUserState()
            }
        }
    }
    
    init() {
        syncForUser(email: DatabaseService.defaultEmail)
        
        // Fetch live data
        Task {
            await fetchFeaturedLive()
            await fetchMeals(for: "All")
        }
    }
    
    // MARK: - User Account Synchronization
    
    func syncForUser(email: String) {
        let normalized = DatabaseService.normalizeEmail(email)
        currentAccountEmail = normalized
        let account = DatabaseService.shared.loadUserAccount(email: normalized)
        
        isSyncingAccount = true
        self.savedMeals = account.savedMeals
        self.cookedMealIds = Set(account.cookedMealIds)
        isSyncingAccount = false
    }
    
    private func persistUserState() {
        var account = DatabaseService.shared.loadUserAccount(email: currentAccountEmail)
        account.savedMeals = savedMeals
        account.cookedMealIds = Array(cookedMealIds).sorted()
        account.profile.savedCount = savedMeals.count
        account.profile.cookedCount = max(account.profile.cookedCount, cookedMealIds.count)
        Task {
            await DatabaseService.shared.saveUserAccount(account)
        }
    }
    
    // MARK: - Live API Calls
    
    /// Fetches a random dish from API
    func fetchFeaturedLive() async {
        guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/random.php") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decoded = parseMealLookup(data: data).first {
                self.featuredMeal = decoded
            }
        } catch {
            // Keep offline Pork Sinigang fallback if network is unavailable
        }
    }
    
    /// Get meals by category
    func fetchMeals(for category: String) async {
        self.selectedCategory = category
        self.isLoading = true
        self.errorMessage = nil
        defer { self.isLoading = false }
        
        let endpoint: String
        if category == "All" {
            endpoint = "https://www.themealdb.com/api/json/v1/1/search.php?s=chicken"
        } else {
            let encodedCategory = category.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? category
            endpoint = "https://www.themealdb.com/api/json/v1/1/filter.php?c=\(encodedCategory)"
        }
        
        guard let url = URL(string: endpoint) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let result = try JSONDecoder().decode(MealResponse.self, from: data)
            if let fetched = result.meals {
                self.popularMeals = fetched.prefix(10).map { meal in
                    let meta = deterministicMetadata(for: meal.idMeal, stepCount: nil)
                    return RecipeItem(
                        id: meal.idMeal,
                        title: meal.strMeal,
                        nativeName: category == "All" ? "Chef's Pick" : "\(category) Special",
                        origin: "International",
                        time: meta.time,
                        servings: "4 servings",
                        calories: meta.calories,
                        rating: meta.rating,
                        category: category == "All" ? "Chef's Pick" : category,
                        difficulty: meta.difficulty,
                        imageUrl: meal.strMealThumb,
                        ingredients: [],
                        instructions: []
                    )
                }
            } else {
                self.popularMeals = []
            }
        } catch {
            self.errorMessage = "Hindi ma-load ang mga recipe. Pakisuri ang iyong internet connection."
            print("API Error: \(error.localizedDescription)")
        }
    }
    
    /// Search meals
    func searchMeals(query: String) async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        self.searchText = trimmed
        guard !trimmed.isEmpty else {
            await fetchMeals(for: selectedCategory)
            return
        }
        self.isLoading = true
        self.errorMessage = nil
        defer { self.isLoading = false }
        
        guard let encoded = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://www.themealdb.com/api/json/v1/1/search.php?s=\(encoded)") else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let parsed = parseMealLookup(data: data)
            self.popularMeals = parsed
        } catch {
            self.errorMessage = "Nagkaproblema sa paghahanap. Subukan muli."
            print("Search API Error: \(error.localizedDescription)")
        }
    }
    
    /// Getting full detail
    func fetchRecipeDetails(id: String) async -> RecipeItem? {
        guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/lookup.php?i=\(id)") else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return parseMealLookup(data: data).first
        } catch {
            return nil
        }
    }
    
    // MARK: - JSON Parser & Deterministic Metadata Helpers
    
    private func parseMealLookup(data: Data) -> [RecipeItem] {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let mealsArray = json["meals"] as? [[String: Any]] else {
            return []
        }
        
        return mealsArray.compactMap { dict in
            guard let id = dict["idMeal"] as? String,
                  let name = dict["strMeal"] as? String,
                  let thumb = dict["strMealThumb"] as? String else { return nil }
            
            let category = (dict["strCategory"] as? String) ?? "Ulam"
            let area = (dict["strArea"] as? String) ?? "Asian"
            let instructionsRaw = (dict["strInstructions"] as? String) ?? "Cook and enjoy."
            
            // Clean instructions into steps
            let steps = instructionsRaw
                .components(separatedBy: CharacterSet.newlines)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty && $0.count > 10 }
            
            // Convert ingredients
            var ingredients: [String] = []
            for i in 1...20 {
                if let ing = dict["strIngredient\(i)"] as? String, !ing.trimmingCharacters(in: .whitespaces).isEmpty {
                    let measure = (dict["strMeasure\(i)"] as? String)?.trimmingCharacters(in: .whitespaces) ?? ""
                    let fullText = measure.isEmpty ? ing : "\(measure) \(ing)"
                    ingredients.append(fullText)
                }
            }
            
            let meta = deterministicMetadata(for: id, stepCount: steps.count)
            
            return RecipeItem(
                id: id,
                title: name,
                nativeName: "\(area) Classic",
                origin: area,
                time: meta.time,
                servings: "4-6 servings",
                calories: meta.calories,
                rating: meta.rating,
                category: category,
                difficulty: meta.difficulty,
                imageUrl: thumb,
                ingredients: ingredients,
                instructions: steps.isEmpty ? [instructionsRaw] : steps
            )
        }
    }
    
    private func deterministicMetadata(for id: String, stepCount: Int?) -> (time: String, calories: String, rating: String, difficulty: String) {
        let seed = stableSeed(for: id)
        let minutes = 20 + (seed % 36)
        let kcal = 310 + ((seed / 7) % 320)
        let ratingValue = 4.5 + Double((seed / 13) % 6) * 0.1
        
        let difficulty: String
        if let stepCount {
            if stepCount > 6 {
                difficulty = "Hard"
            } else if stepCount > 3 {
                difficulty = "Medium"
            } else {
                difficulty = "Easy"
            }
        } else {
            let options = ["Easy", "Medium", "Hard"]
            difficulty = options[(seed / 3) % options.count]
        }
        
        return (
            time: "\(minutes) min",
            calories: "\(kcal) kcal",
            rating: String(format: "%.1f", ratingValue),
            difficulty: difficulty
        )
    }
    
    private func stableSeed(for value: String) -> Int {
        var hash = 5381
        for scalar in value.unicodeScalars {
            hash = ((hash &<< 5) &+ hash) &+ Int(scalar.value)
        }
        return abs(hash)
    }
    
    // MARK: - User Action Handlers
    
    func isSaved(meal: RecipeItem) -> Bool {
        savedMeals.contains(where: { $0.id == meal.id })
    }
    
    func toggleSave(meal: RecipeItem) {
        if isSaved(meal: meal) {
            savedMeals.removeAll(where: { $0.id == meal.id })
        } else {
            savedMeals.append(meal)
        }
    }
    
    func removeSaved(id: String) {
        savedMeals.removeAll(where: { $0.id == id })
    }
    
    func isCooked(meal: RecipeItem) -> Bool {
        cookedMealIds.contains(meal.id)
    }
    
    @discardableResult
    func markAsCooked(meal: RecipeItem) -> Int {
        cookedMealIds.insert(meal.id)
        persistUserState()
        return cookedMealIds.count
    }
    
    func toggleIngredient(_ ingredient: String) {
        if checkedIngredients.contains(ingredient) {
            checkedIngredients.remove(ingredient)
        } else {
            checkedIngredients.insert(ingredient)
        }
    }
}
