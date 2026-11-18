//
//  HomeView.swift
//  midterm project
//
//  Created by Christian Louis on 9/12/26.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authController: AuthController
    @EnvironmentObject var recipeController: RecipeController
    @Binding var selectedTab: Int
    @State private var search = ""
    
    init(selectedTab: Binding<Int> = .constant(0)) {
        _selectedTab = selectedTab
    }
    
    private var avatarInitial: String {
        let trimmed = authController.currentUserName.trimmingCharacters(in: .whitespacesAndNewlines)
        return String(trimmed.prefix(1)).uppercased().isEmpty ? "C" : String(trimmed.prefix(1)).uppercased()
    }
    
    private var listCategoryTitle: String {
        if !search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Results: \(search)"
        }
        return recipeController.selectedCategory == "All"
            ? "Mga Lutuing Pinoy"
            : "\(recipeController.selectedCategory) Dishes"
    }
    
    private var hasActivePreferences: Bool {
        recipeController.dietaryPreference != "No restrictions" ||
        recipeController.skillLevel != "No preference"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Top Header Bar
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Magandang umaga")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                            Text("Tara, luto tayo, \(authController.currentUserName)!")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(Color.ulamTextDark)
                        }
                        Spacer()
                        Button(action: {
                            selectedTab = 2
                        }) {
                            Circle()
                                .fill(Color.ulamOrange)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Text(avatarInitial)
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                )
                        }
                        .accessibilityLabel("Buksan ang Profile")
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    // Search Bar
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search meals, ingredients...", text: $search)
                            .font(.system(size: 14))
                            .onSubmit {
                                Task {
                                    await recipeController.searchMeals(query: search)
                                }
                            }
                        if !search.isEmpty {
                            Button(action: {
                                search = ""
                                Task { await recipeController.fetchMeals(for: recipeController.selectedCategory) }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.ulamCard)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.ulamBorder, lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    
                    // Live Category Filter Pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(recipeController.availableCategories, id: \.self) { cat in
                                Text(cat)
                                    .font(.system(size: 13, weight: .semibold))
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 8)
                                    .background(recipeController.selectedCategory == cat ? Color.ulamOrange : Color.ulamCard)
                                    .foregroundColor(recipeController.selectedCategory == cat ? .white : Color.ulamTextDark)
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(recipeController.selectedCategory == cat ? Color.clear : Color.ulamBorder, lineWidth: 1)
                                    )
                                    .onTapGesture {
                                        search = ""
                                        Task {
                                            await recipeController.fetchMeals(for: cat)
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Active Dietary / Skill Preference Indicator
                    if hasActivePreferences {
                        Button(action: {
                            selectedTab = 2
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "line.3.horizontal.decrease.circle.fill")
                                    .font(.system(size: 13))
                                    .foregroundColor(.ulamOrange)
                                if recipeController.dietaryPreference != "No restrictions" {
                                    Text("Diet: \(recipeController.dietaryPreference)")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.ulamOrange)
                                }
                                if recipeController.skillLevel != "No preference" {
                                    Text("Skill: \(recipeController.skillLevel)")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(Color.ulamTextDark)
                                }
                                Spacer()
                                Text("Baguhin")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.ulamOrange)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(Color.ulamLightOrange)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Ulam ng Araw
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Ulam ng Araw")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(Color.ulamTextDark)
                            Spacer()
                            NavigationLink(destination: RecipeListView(categoryName: listCategoryTitle)) {
                                Text("Tingnan lahat")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.ulamOrange)
                            }
                        }
                        
                        NavigationLink(destination: RecipeDetailView(recipe: recipeController.featuredMeal)) {
                            ZStack(alignment: .bottomLeading) {
                                AsyncImage(url: URL(string: recipeController.featuredMeal.imageUrl)) { img in
                                    img.resizable().aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Color.gray.opacity(0.2)
                                }
                                .frame(height: 200)
                                .clipped()
                                .overlay(
                                    LinearGradient(
                                        colors: [.clear, .black.opacity(0.85)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .cornerRadius(20)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(recipeController.featuredMeal.category)
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color.white.opacity(0.25))
                                        .cornerRadius(8)
                                    
                                    Text(recipeController.featuredMeal.title)
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                    
                                    HStack(spacing: 14) {
                                        Label(recipeController.featuredMeal.time, systemImage: "clock")
                                        Label(recipeController.featuredMeal.calories, systemImage: "flame")
                                        Label(recipeController.featuredMeal.rating, systemImage: "star.fill")
                                            .foregroundColor(.yellow)
                                    }
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                                }
                                .padding(16)
                                
                                VStack {
                                    HStack {
                                        Spacer()
                                        Text(recipeController.featuredMeal.difficulty.uppercased())
                                            .font(.system(size: 10, weight: .heavy))
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(Color.ulamOrange)
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                    }
                                    Spacer()
                                }
                                .padding(14)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Sikat na Lutuin
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("Sikat na Lutuin")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(Color.ulamTextDark)
                            Spacer()
                            NavigationLink(destination: RecipeListView(categoryName: listCategoryTitle)) {
                                Text("Lahat")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.ulamOrange)
                            }
                        }
                        
                        if recipeController.isLoading {
                            HStack {
                                Spacer()
                                ProgressView("Kumukuha ng mga lutuin...")
                                    .tint(Color.ulamOrange)
                                    .padding(.vertical, 30)
                                Spacer()
                            }
                        } else if let error = recipeController.errorMessage, recipeController.popularMeals.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "wifi.exclamationmark")
                                    .font(.system(size: 30))
                                    .foregroundColor(.ulamOrange)
                                Text(error)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                Button("Subukan Muli") {
                                    Task {
                                        await recipeController.fetchFeaturedLive()
                                        await recipeController.fetchMeals(for: recipeController.selectedCategory)
                                    }
                                }
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 10)
                                .background(Color.ulamOrange)
                                .cornerRadius(12)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 28)
                            .padding(.horizontal, 16)
                            .background(Color.ulamCard)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.ulamBorder, lineWidth: 1)
                            )
                        } else if recipeController.popularMeals.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 28))
                                    .foregroundColor(.ulamOrange)
                                Text("Walang nahanap na recipe")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(Color.ulamTextDark)
                                Text("Subukan ang ibang pangalan ng ulam o i-reset ang filter.")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                Button("I-reset") {
                                    search = ""
                                    Task {
                                        await recipeController.fetchMeals(for: "All")
                                    }
                                }
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 10)
                                .background(Color.ulamOrange)
                                .cornerRadius(12)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 28)
                            .padding(.horizontal, 16)
                            .background(Color.ulamCard)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.ulamBorder, lineWidth: 1)
                            )
                        } else {
                            LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                                ForEach(recipeController.popularMeals) { meal in
                                    NavigationLink(destination: RecipeDetailView(recipe: meal)) {
                                        PopularDishCard(meal: meal)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            }
            .background(Color.ulamCream.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
}
