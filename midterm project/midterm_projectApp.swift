//
//  midterm_projectApp.swift
//  midterm project
//
//  Created by Christian Louis on 9/7/26.
//

import SwiftUI

@main
struct midterm_projectApp: App {
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var recipeVM = RecipeViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authVM)
                .environmentObject(recipeVM)
        }
    }
}
