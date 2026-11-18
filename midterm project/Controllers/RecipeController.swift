//
//  RecipeController.swift
//  midterm project
//
//  Created by Christian Louis on 9/12/26.
//

import Foundation
import Combine

typealias RecipeViewModel = RecipeController

@MainActor
class RecipeController: ObservableObject {
    @Published var selectedCategory: String = "All"
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var checkedIngredientsByMeal: [String: Set<String>] = [:]
    @Published var cookedMealIds: Set<String> = []
    @Published var dietaryPreference: String = "No restrictions"
    @Published var skillLevel: String = "No preference"
    
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
    
    var availableCategories: [String] {
        switch dietaryPreference {
        case "Halal":
            return ["All", "Beef", "Chicken", "Seafood"]
        case "Vegetarian":
            return ["All", "Vegetarian"]
        case "Pescatarian":
            return ["All", "Seafood"]
        default:
            return ["All", "Beef", "Chicken", "Pork", "Seafood"]
        }
    }
    
    init() {
        syncForUser(email: DatabaseService.defaultEmail, refreshMeals: false)
        
        // Fetch live data
        Task {
            await fetchFeaturedLive()
            await fetchMeals(for: selectedCategory)
        }
    }
    
    // MARK: - User Account Synchronization & Preferences
    
    func syncForUser(email: String, refreshMeals: Bool = true) {
        let normalized = DatabaseService.normalizeEmail(email)
        currentAccountEmail = normalized
        let account = DatabaseService.shared.loadUserAccount(email: normalized)
        
        let previousDietary = dietaryPreference
        let previousSkill = skillLevel
        
        isSyncingAccount = true
        self.savedMeals = account.savedMeals
        self.cookedMealIds = Set(account.cookedMealIds)
        self.checkedIngredientsByMeal = account.checkedIngredientsByMeal.mapValues { Set($0) }
        self.dietaryPreference = account.profile.dietaryPreference
        self.skillLevel = account.profile.skillLevel
        isSyncingAccount = false
        
        if !availableCategories.contains(selectedCategory) {
            selectedCategory = "All"
        }
        
        if refreshMeals && (previousDietary != dietaryPreference || previousSkill != skillLevel) {
            Task {
                await fetchMeals(for: selectedCategory)
            }
        }
    }
    
    func applyPreferences(dietary: String, skill: String) {
        let dietaryChanged = dietaryPreference != dietary
        let skillChanged = skillLevel != skill
        dietaryPreference = dietary
        skillLevel = skill
        
        if !availableCategories.contains(selectedCategory) {
            selectedCategory = "All"
        }
        
        if dietaryChanged || skillChanged {
            Task {
                await fetchMeals(for: selectedCategory)
            }
        }
    }
    
    private func persistUserState() {
        var account = DatabaseService.shared.loadUserAccount(email: currentAccountEmail)
        account.savedMeals = savedMeals
        account.cookedMealIds = Array(cookedMealIds).sorted()
        account.checkedIngredientsByMeal = checkedIngredientsByMeal.mapValues { Array($0).sorted() }
        account.profile.savedCount = savedMeals.count
        account.profile.cookedCount = max(account.profile.cookedCount, cookedMealIds.count)
        Task {
            await DatabaseService.shared.saveUserAccount(account)
        }
    }
    
    // MARK: - Live API Calls
    
    /// Fetches a random dish from API
    func fetchFeaturedLive() async {
        guard let url = makeMealDBURL(path: "random.php") else { return }
        do {
            let data = try await fetchValidatedData(from: url)
            if let decoded = parseMealLookup(data: data).first {
                if isMealAllowed(decoded) {
                    self.featuredMeal = decoded
                } else {
                    await fetchDietaryFallbackFeatured()
                }
            }
        } catch {
            // Keep offline fallback if network is unavailable
        }
    }
    
    private func fetchDietaryFallbackFeatured() async {
        let fallbackCategory: String
        switch dietaryPreference {
        case "Vegetarian":
            fallbackCategory = "Vegetarian"
        case "Pescatarian":
            fallbackCategory = "Seafood"
        case "Halal":
            fallbackCategory = "Chicken"
        default:
            return
        }
        guard let filterURL = makeMealDBURL(
            path: "filter.php",
            queryItems: [URLQueryItem(name: "c", value: fallbackCategory)]
        ) else { return }
        do {
            let data = try await fetchValidatedData(from: filterURL)
            let result = try JSONDecoder().decode(MealResponse.self, from: data)
            if let firstMeal = result.meals?.first,
               let full = await fetchRecipeDetails(id: firstMeal.idMeal),
               isMealAllowed(full) {
                self.featuredMeal = full
            }
        } catch {
            // Keep existing featured meal if fallback lookup fails
        }
    }
    
    /// Get meals by category
    func fetchMeals(for category: String) async {
        let targetCategory = availableCategories.contains(category) ? category : "All"
        self.selectedCategory = targetCategory
        self.isLoading = true
        self.errorMessage = nil
        defer { self.isLoading = false }
        
        let endpointURL: URL?
        let isLookupEndpoint: Bool
        
        if targetCategory == "All" {
            switch dietaryPreference {
            case "Vegetarian":
                endpointURL = makeMealDBURL(path: "filter.php", queryItems: [URLQueryItem(name: "c", value: "Vegetarian")])
                isLookupEndpoint = false
            case "Pescatarian":
                endpointURL = makeMealDBURL(path: "filter.php", queryItems: [URLQueryItem(name: "c", value: "Seafood")])
                isLookupEndpoint = false
            default:
                endpointURL = makeMealDBURL(path: "search.php", queryItems: [URLQueryItem(name: "s", value: "chicken")])
                isLookupEndpoint = true
            }
        } else {
            endpointURL = makeMealDBURL(path: "filter.php", queryItems: [URLQueryItem(name: "c", value: targetCategory)])
            isLookupEndpoint = false
        }
        
        guard let url = endpointURL else { return }
        
        do {
            let data = try await fetchValidatedData(from: url)
            let mealsList: [RecipeItem]
            if isLookupEndpoint {
                mealsList = Array(parseMealLookup(data: data).prefix(10))
            } else {
                let result = try JSONDecoder().decode(MealResponse.self, from: data)
                if let fetched = result.meals {
                    mealsList = fetched.prefix(10).map { meal in
                        let meta = deterministicMetadata(for: meal.idMeal, stepCount: nil)
                        return RecipeItem(
                            id: meal.idMeal,
                            title: meal.strMeal,
                            nativeName: targetCategory == "All" ? "Chef's Pick" : "\(targetCategory) Special",
                            origin: "International",
                            time: meta.time,
                            servings: "4 servings",
                            calories: meta.calories,
                            rating: meta.rating,
                            category: targetCategory == "All" ? "Chef's Pick" : targetCategory,
                            difficulty: meta.difficulty,
                            imageUrl: meal.strMealThumb,
                            ingredients: [],
                            instructions: []
                        )
                    }
                } else {
                    mealsList = []
                }
            }
            
            self.popularMeals = applyDietaryAndSkillPreferences(to: mealsList)
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
        
        guard let url = makeMealDBURL(
            path: "search.php",
            queryItems: [URLQueryItem(name: "s", value: trimmed)]
        ) else { return }
        
        do {
            let data = try await fetchValidatedData(from: url)
            let parsed = parseMealLookup(data: data)
            self.popularMeals = applyDietaryAndSkillPreferences(to: parsed)
        } catch {
            self.errorMessage = "Nagkaproblema sa paghahanap. Subukan muli."
            print("Search API Error: \(error.localizedDescription)")
        }
    }
    
    /// Getting full detail
    func fetchRecipeDetails(id: String) async -> RecipeItem? {
        let trimmedId = id.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedId.isEmpty,
              let url = makeMealDBURL(
                path: "lookup.php",
                queryItems: [URLQueryItem(name: "i", value: trimmedId)]
              ) else {
            return nil
        }
        do {
            let data = try await fetchValidatedData(from: url)
            return parseMealLookup(data: data).first
        } catch {
            return nil
        }
    }
    
    func updateCachedMealDetails(_ fullMeal: RecipeItem) {
        if let popularIndex = popularMeals.firstIndex(where: { $0.id == fullMeal.id }) {
            popularMeals[popularIndex] = fullMeal
        }
        if let savedIndex = savedMeals.firstIndex(where: { $0.id == fullMeal.id }) {
            savedMeals[savedIndex] = fullMeal
        }
        if featuredMeal.id == fullMeal.id {
            featuredMeal = fullMeal
        }
    }
    
    // MARK: - Networking & Filtering Helpers
    
    private func makeMealDBURL(path: String, queryItems: [URLQueryItem] = []) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.themealdb.com"
        components.path = "/api/json/v1/1/\(path)"
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        return components.url
    }
    
    private func fetchValidatedData(from url: URL) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(from: url)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw URLError(.badServerResponse)
        }
        return data
    }
    
    private func applyDietaryAndSkillPreferences(to meals: [RecipeItem]) -> [RecipeItem] {
        let filtered = meals.filter { isMealAllowed($0) }
        guard let preferredDifficulty = preferredDifficultyForSkillLevel() else {
            return filtered
        }
        return filtered.sorted { lhs, rhs in
            let lhsMatches = lhs.difficulty.caseInsensitiveCompare(preferredDifficulty) == .orderedSame
            let rhsMatches = rhs.difficulty.caseInsensitiveCompare(preferredDifficulty) == .orderedSame
            if lhsMatches != rhsMatches {
                return lhsMatches
            }
            return false
        }
    }
    
    private func isMealAllowed(_ meal: RecipeItem) -> Bool {
        let combinedText = "\(meal.title) \(meal.category) \(meal.ingredients.joined(separator: " "))".lowercased()
        switch dietaryPreference {
        case "Halal":
            let forbidden = ["pork", "bacon", "ham", "lard", "prosciutto", "pancetta", "chorizo"]
            return !forbidden.contains(where: { combinedText.contains($0) })
        case "Vegetarian":
            let forbidden = ["pork", "beef", "chicken", "lamb", "turkey", "duck", "bacon", "ham", "fish", "salmon", "tuna", "shrimp", "prawn", "crab", "seafood"]
            return !forbidden.contains(where: { combinedText.contains($0) })
        case "Pescatarian":
            let forbidden = ["pork", "beef", "chicken", "lamb", "turkey", "duck", "bacon", "ham"]
            return !forbidden.contains(where: { combinedText.contains($0) })
        default:
            return true
        }
    }
    
    private func preferredDifficultyForSkillLevel() -> String? {
        switch skillLevel {
        case "Beginner":
            return "Easy"
        case "Home Cook", "Intermediate":
            return "Medium"
        case "Chef":
            return "Hard"
        default:
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
            if meal.ingredients.isEmpty || meal.instructions.isEmpty {
                Task {
                    if let fullMeal = await fetchRecipeDetails(id: meal.id) {
                        updateCachedMealDetails(fullMeal)
                    }
                }
            }
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
    
    func isIngredientChecked(_ ingredient: String, mealId: String) -> Bool {
        checkedIngredientsByMeal[mealId]?.contains(ingredient) ?? false
    }
    
    func toggleIngredient(_ ingredient: String, mealId: String) {
        var current = checkedIngredientsByMeal[mealId] ?? []
        if current.contains(ingredient) {
            current.remove(ingredient)
        } else {
            current.insert(ingredient)
        }
        checkedIngredientsByMeal[mealId] = current
        persistUserState()
    }
}
