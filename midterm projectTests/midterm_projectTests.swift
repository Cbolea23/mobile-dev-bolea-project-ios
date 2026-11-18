//
//  midterm_projectTests.swift
//  midterm projectTests
//
//  Created by Christian Louis on 9/7/26.
//

import Foundation
import Testing
@testable import midterm_project

struct midterm_projectTests {

    @Test func passwordHashingIsDeterministicAndSaltedByEmail() async throws {
        let hash1 = UserAccount.hashPassword("secret123", email: "user@example.com")
        let hash2 = UserAccount.hashPassword("secret123", email: "USER@EXAMPLE.COM ")
        let hash3 = UserAccount.hashPassword("secret123", email: "other@example.com")
        
        #expect(hash1 == hash2)
        #expect(hash1 != hash3)
        #expect(hash1.count == 64)
    }
    
    @Test func legacyUserAccountDecodesAndMigratesPasswordToHash() async throws {
        let legacyJSON = """
        {
            "id": "christianbolea@gmail.com",
            "username": "Christian",
            "email": "christianbolea@gmail.com",
            "password": "password123",
            "profile": {
                "username": "Christian",
                "email": "christianbolea@gmail.com",
                "recipesCount": 12,
                "savedCount": 0,
                "cookedCount": 0,
                "dietaryPreference": "No restrictions",
                "skillLevel": "No preference",
                "notificationsEnabled": true
            },
            "savedMeals": [],
            "cookedMealIds": []
        }
        """
        let data = try #require(legacyJSON.data(using: .utf8))
        let decoded = try JSONDecoder().decode(UserAccount.self, from: data)
        
        #expect(decoded.passwordHash == UserAccount.hashPassword("password123", email: "christianbolea@gmail.com"))
        #expect(decoded.checkedIngredientsByMeal.isEmpty)
    }
    
    @MainActor
    @Test func emailValidationRejectsMalformedAddresses() async throws {
        let auth = AuthController()
        #expect(auth.isValidEmail("chef@anongulam.ph"))
        #expect(!auth.isValidEmail("not-an-email"))
        #expect(!auth.isValidEmail("user@domain"))
        #expect(!auth.isValidEmail("user @domain.com"))
    }
    
    @MainActor
    @Test func dietaryCategoriesAndPerMealChecklistBehaveCorrectly() async throws {
        let recipeController = RecipeController()
        recipeController.dietaryPreference = "Halal"
        #expect(!recipeController.availableCategories.contains("Pork"))
        #expect(recipeController.availableCategories == ["All", "Beef", "Chicken", "Seafood"])
        
        recipeController.toggleIngredient("Salt", mealId: "meal-1")
        #expect(recipeController.isIngredientChecked("Salt", mealId: "meal-1"))
        #expect(!recipeController.isIngredientChecked("Salt", mealId: "meal-2"))
    }
}
