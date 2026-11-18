//
//  RecipeListView.swift
//  midterm project
//
//  Created by Christian Louis on 9/12/26.
//

import SwiftUI

struct RecipeListView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var recipeController: RecipeController
    var categoryName: String = "Mga Lutuing Pinoy"
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                
                // Header Details
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(categoryName)
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(Color.ulamTextDark)
                        Text("\(recipeController.popularMeals.count) dishes available")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
                
                if recipeController.popularMeals.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "fork.knife.circle")
                            .font(.system(size: 40))
                            .foregroundColor(.ulamOrange)
                        Text("Walang nakitang lutuin")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color.ulamTextDark)
                        Text("Subukan i-reload o pumili ng ibang kategorya sa Home.")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button("I-load Muli") {
                            Task {
                                await recipeController.fetchMeals(for: recipeController.selectedCategory)
                            }
                        }
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.ulamOrange)
                        .cornerRadius(12)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .padding(.horizontal, 20)
                } else {
                    // Vertical Dish Cards
                    LazyVStack(spacing: 14) {
                        ForEach(recipeController.popularMeals) { meal in
                            NavigationLink(destination: RecipeDetailView(recipe: meal)) {
                                RecipeRowCard(meal: meal)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            }
        }
        .background(Color.ulamCream.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }
}
