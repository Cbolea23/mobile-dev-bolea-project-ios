//
//  RecipeListView.swift
//  midterm project
//
//  Created by Christian Louis on 9/12/26.
//

import SwiftUI

struct RecipeListView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var recipeVM: RecipeViewModel
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
                        Text("\(recipeVM.popularMeals.count) dishes available")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
                
                if recipeVM.popularMeals.isEmpty {
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
                                await recipeVM.fetchMeals(for: recipeVM.selectedCategory)
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
                        ForEach(recipeVM.popularMeals) { meal in
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

struct RecipeRowCard: View {
    @EnvironmentObject var recipeVM: RecipeViewModel
    let meal: RecipeItem
    
    var body: some View {
        HStack(spacing: 14) {
            // Thumbnail
            AsyncImage(url: URL(string: meal.imageUrl)) { img in
                img.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 86, height: 86)
            .clipped()
            .cornerRadius(14)
            
            // Text Details
            VStack(alignment: .leading, spacing: 4) {
                Text(meal.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color.ulamTextDark)
                    .lineLimit(1)
                
                Text(meal.nativeName)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                HStack(spacing: 12) {
                    Label(meal.time, systemImage: "clock")
                    Label(meal.calories, systemImage: "flame")
                    Label(meal.rating, systemImage: "star.fill")
                        .foregroundColor(.ulamOrange)
                }
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                recipeVM.toggleSave(meal: meal)
            }) {
                Image(systemName: recipeVM.isSaved(meal: meal) ? "heart.fill" : "heart")
                    .font(.system(size: 15, weight: .bold))
                    .padding(8)
                    .background(recipeVM.isSaved(meal: meal) ? Color.ulamLightOrange : Color.black.opacity(0.05))
                    .foregroundColor(recipeVM.isSaved(meal: meal) ? .ulamOrange : .secondary)
                    .clipShape(Circle())
            }
            .buttonStyle(PlainButtonStyle())
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary.opacity(0.5))
        }
        .padding(10)
        .background(Color.ulamCard)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.ulamBorder, lineWidth: 1)
        )
    }
}
