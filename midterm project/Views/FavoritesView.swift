//
//  FavoriteView.swift
//  midterm project
//
//  Created by louis on 9/13/26.
//

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var recipeVM: RecipeViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    
                    // Header Title & Counter Badge
                    HStack {
                        Text("Mga Paborito")
                            .font(.system(size: 30, weight: .black, design: .rounded))
                            .foregroundColor(Color.ulamTextDark)
                        Spacer()
                        Text("\(recipeVM.savedMeals.count) saved")
                            .font(.system(size: 12, weight: .bold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.ulamOrange)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                    
                    Text("Ang iyong mga naka-save na recipe")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                    
                    // Grid of Bookmarked Recipes
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                        ForEach(recipeVM.savedMeals) { meal in
                            NavigationLink(destination: RecipeDetailView(recipe: meal)) {
                                SavedDishCard(meal: meal)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 6)
                    .padding(.bottom, 30)
                }
            }
            .background(Color.ulamCream.ignoresSafeArea())
        }
    }
}

struct SavedDishCard: View {
    @EnvironmentObject var recipeVM: RecipeViewModel
    let meal: RecipeItem
    
    var badgeColor: Color {
        switch meal.difficulty.lowercased() {
        case "easy": return .green
        case "hard": return .red
        default: return .orange
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .top) {
                AsyncImage(url: URL(string: meal.imageUrl)) { img in
                    img.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(height: 120)
                .clipped()
                .cornerRadius(14)
                
                HStack {
                    Text(meal.difficulty)
                        .font(.system(size: 10, weight: .heavy))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(badgeColor)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                    
                    Spacer()
                    
                    Button(action: {
                        recipeVM.removeSaved(id: meal.id)
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .heavy))
                            .padding(6)
                            .background(Color.black.opacity(0.6))
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                }
                .padding(8)
            }
            
            Text(meal.title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color.ulamTextDark)
                .lineLimit(1)
            
            HStack {
                Text(meal.time)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                Spacer()
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.ulamOrange)
                    Text(meal.rating)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color.ulamTextDark)
                }
            }
            
            HStack(spacing: 4) {
                Image(systemName: "flame")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                Text(meal.calories)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
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
