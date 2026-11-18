//
//  midterm_projectApp.swift
//  midterm project
//
//  Created by Christian Louis on 9/7/26.
//

import SwiftUI

@main
struct midterm_projectApp: App {
    @StateObject private var authController = AuthController()
    @StateObject private var recipeController = RecipeController()
    
    init() {
        DatabaseService.shared.configureIfNeeded()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authController)
                .environmentObject(recipeController)
        }
    }
}
