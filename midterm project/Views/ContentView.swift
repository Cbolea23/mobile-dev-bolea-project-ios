//
//  ContentView.swift
//  midterm project
//
//  Created by Christian Louis on 9/7/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authController: AuthController
    @EnvironmentObject var recipeController: RecipeController
    @State private var selectedTab = 0
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.ulamCream)
        appearance.shadowColor = UIColor.black.withAlphaComponent(0.06)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        Group {
            if !authController.isAuthenticated {
                LoginView()
            } else {
                TabView(selection: $selectedTab) {
                    HomeView(selectedTab: $selectedTab)
                        .tabItem {
                            Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                            Text("Home")
                        }
                        .tag(0)
                    
                    FavoritesView()
                        .tabItem {
                            Image(systemName: selectedTab == 1 ? "heart.fill" : "heart")
                            Text("Paborito")
                        }
                        .tag(1)
                    
                    ProfileView()
                        .tabItem {
                            Image(systemName: selectedTab == 2 ? "person.fill" : "person")
                            Text("Profile")
                        }
                        .tag(2)
                }
                .tint(Color.ulamOrange)
            }
        }
        .onAppear {
            recipeController.syncForUser(email: authController.currentUserEmail)
        }
        .onChange(of: authController.currentUserEmail) { _, newEmail in
            recipeController.syncForUser(email: newEmail)
        }
        .onChange(of: authController.isAuthenticated) { _, isAuth in
            if isAuth {
                recipeController.syncForUser(email: authController.currentUserEmail)
            } else {
                selectedTab = 0
            }
        }
    }
}
