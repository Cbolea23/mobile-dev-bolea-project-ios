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
    @Published var checkedIngredients: Set<String> = []
    
    //default for offline fallback
    @Published var featuredMeal: RecipeItem = RecipeItem(
        id: "52854",
        title: "Pork Sinigang",
        nativeName: "Sinigang na Baboy",
        origin: "Filipino",
        time: "1 hr",
        servings: "6 servings",
        calories: "310",
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
    
    private let savedMealsKey = "saved_ulam_meals"

    // save on local
    @Published var savedMeals: [RecipeItem] = [] {
        didSet {
            if let encoded = try? JSONEncoder().encode(savedMeals) {
                UserDefaults.standard.set(encoded, forKey: savedMealsKey)
            }
        }
    }

    init() {
        // Restore saved favorites from disk if theres one
        if let data = UserDefaults.standard.data(forKey: savedMealsKey),
           let decoded = try? JSONDecoder().decode([RecipeItem].self, from: data) {
            self.savedMeals = decoded
        } else {
                    self.savedMeals = []
                }

                // Fetch live data
                Task {
                    await fetchFeaturedLive()
                    await fetchMeals(for: "All")
                }
            }
    
    // MARK: - Live API Calls
    
    /// Fetches a random dish from api
    func fetchFeaturedLive() async {
        guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/random.php") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decoded = parseMealLookup(data: data).first {
                self.featuredMeal = decoded
            }
        } catch { }
    }
    
    /// get meals by category
    func fetchMeals(for category: String) async {
        self.selectedCategory = category
        self.isLoading = true
        defer { self.isLoading = false }
        
        let endpoint: String
        if category == "All" {
            endpoint = "https://www.themealdb.com/api/json/v1/1/search.php?s=chicken"
        } else {
            endpoint = "https://www.themealdb.com/api/json/v1/1/filter.php?c=\(category)"
        }
        
        guard let url = URL(string: endpoint) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let result = try JSONDecoder().decode(MealResponse.self, from: data)
            if let fetched = result.meals {
                self.popularMeals = fetched.prefix(8).map { meal in
                    RecipeItem(
                        id: meal.idMeal,
                        title: meal.strMeal,
                        nativeName: "\(category) Special",
                        origin: "International",
                        time: "\(Int.random(in: 25...55)) min",
                        servings: "4 servings",
                        calories: "\(Int.random(in: 320...580)) kcal",
                        rating: String(format: "%.1f", Double.random(in: 4.5...5.0)),
                        category: category == "All" ? "Chef's Pick" : category,
                        difficulty: ["Easy", "Medium", "Hard"].randomElement() ?? "Medium",
                        imageUrl: meal.strMealThumb,
                        ingredients: [],
                        instructions: []
                    )
                }
            }
        } catch {
            print("API Error: \(error.localizedDescription)")
        }
    }
    
    /// search meals
    func searchMeals(query: String) async {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            await fetchMeals(for: selectedCategory)
            return
        }
        self.isLoading = true
        defer { self.isLoading = false }
        
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://www.themealdb.com/api/json/v1/1/search.php?s=\(encoded)") else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let parsed = parseMealLookup(data: data)
            if !parsed.isEmpty {
                self.popularMeals = parsed
            }
        } catch {
            print("Search API Error: \(error.localizedDescription)")
        }
    }
    
    /// getting full detail
    func fetchRecipeDetails(id: String) async -> RecipeItem? {
        guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/lookup.php?i=\(id)") else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return parseMealLookup(data: data).first
        } catch {
            return nil
        }
    }
    
    // MARK: - JSON Parser Helper for TheMealDB
    
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
                .components(separatedBy: "\r\n")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty && $0.count > 10 }
            
            // for converting the ingredients
            var ingredients: [String] = []
            for i in 1...20 {
                if let ing = dict["strIngredient\(i)"] as? String, !ing.trimmingCharacters(in: .whitespaces).isEmpty {
                    let measure = (dict["strMeasure\(i)"] as? String)?.trimmingCharacters(in: .whitespaces) ?? ""
                    let fullText = measure.isEmpty ? ing : "\(measure) \(ing)"
                    ingredients.append(fullText)
                }
            }
            
            return RecipeItem(
                id: id,
                title: name,
                nativeName: "\(area) Classic",
                origin: area,
                time: "\(Int.random(in: 25...60)) min",
                servings: "4-6 servings",
                calories: "\(Int.random(in: 350...650)) kcal",
                rating: String(format: "%.1f", Double.random(in: 4.6...4.9)),
                category: category,
                difficulty: steps.count > 4 ? "Medium" : "Easy",
                imageUrl: thumb,
                ingredients: ingredients,
                instructions: steps.isEmpty ? [instructionsRaw] : steps
            )
        }
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
    
    func toggleIngredient(_ ingredient: String) {
        if checkedIngredients.contains(ingredient) {
            checkedIngredients.remove(ingredient)
        } else {
            checkedIngredients.insert(ingredient)
        }
    }
}
