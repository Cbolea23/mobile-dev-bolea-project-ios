//
//  RecipeViewModel.swift
//  midterm project
//
//  Created by Christian Louis on 9/12/26.
//

import Foundation
import Combine

class RecipeViewModel: ObservableObject {
    @Published var selectedCategory: String = "All"
    @Published var searchText: String = ""
    @Published var checkedIngredients: Set<String> = []
    
    @Published var featuredMeal: RecipeItem = RecipeItem(
        id: "52854",
        title: "Pork Sinigang",
        nativeName: "Sinigang na Baboy",
        origin: "Ilocano",
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
    
    @Published var popularMeals: [RecipeItem] = [
        RecipeItem(
            id: "52853",
            title: "Chicken Adobo",
            nativeName: "Adobong Manok",
            origin: "Tagalog",
            time: "45 min",
            servings: "4 servings",
            calories: "420 kcal",
            rating: "4.9",
            category: "Chicken",
            difficulty: "Easy",
            imageUrl: "https://www.themealdb.com/images/media/meals/yypwwq1511304979.jpg",
            ingredients: [
                "1 kg chicken cuts",
                "1/2 cup soy sauce",
                "1/2 cup cane vinegar",
                "6 cloves garlic, crushed",
                "2 bay leaves",
                "1 tsp whole black peppercorns"
            ],
            instructions: [
                "Marinate chicken in soy sauce and crushed garlic.",
                "Sear chicken cuts in a pan until lightly browned.",
                "Pour remaining marinade, vinegar, and bay leaves.",
                "Simmer on low heat until sauce thickens."
            ]
        ),
        RecipeItem(
            id: "52855",
            title: "Kare-Kare",
            nativeName: "Kare-Kareng Baka",
            origin: "Pampanga",
            time: "2 hrs",
            servings: "6 servings",
            calories: "580 kcal",
            rating: "4.7",
            category: "Beef",
            difficulty: "Hard",
            imageUrl: "https://www.themealdb.com/images/media/meals/1529446352.jpg",
            ingredients: [
                "1 kg beef shank or oxtail",
                "1/2 cup peanut butter",
                "1/4 cup toasted ground rice",
                "1 bundle string beans",
                "1 bundle pechay",
                "1 eggplant, sliced",
                "Bagoong alamang (shrimp paste)"
            ],
            instructions: [
                "Boil beef shank until tender, reserving the broth.",
                "Whisk in peanut butter and ground rice to thicken gravy.",
                "Blanch vegetables separately.",
                "Combine and serve hot with sauteed shrimp paste."
            ]
        )
    ]
    
    @Published var savedMeals: [RecipeItem] = []
    
    init() {
        // Pre-populate saved meals matching the Figma screenshot (Adobo + Kare-Kare)
        self.savedMeals = popularMeals
    }
    
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
