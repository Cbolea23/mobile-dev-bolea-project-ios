//
//  RecipeDetailView.swift
//  midterm project
//
//  Created by louis on 9/13/26.
//

import SwiftUI

struct RecipeDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var recipeVM: RecipeViewModel
    
    @State var recipe: RecipeItem
    @State private var selectedTab: Int = 0
    @State private var isLoadingDetails: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    
                    // Top Hero Banner
                    ZStack(alignment: .top) {
                        AsyncImage(url: URL(string: recipe.imageUrl)) { img in
                            img.resizable().aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color.gray.opacity(0.3)
                        }
                        .frame(height: 290)
                        .clipped()
                        
                        // Top Nav Buttons
                        HStack {
                            Button(action: { dismiss() }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .bold))
                                    .padding(11)
                                    .background(Color.black.opacity(0.5))
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                            }
                            Spacer()
                            Button(action: { recipeVM.toggleSave(meal: recipe) }) {
                                Image(systemName: recipeVM.isSaved(meal: recipe) ? "bookmark.fill" : "bookmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .padding(11)
                                    .background(Color.black.opacity(0.5))
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.top, 50)
                        .padding(.horizontal, 20)
                        
                        // Difficulty Badge
                        VStack {
                            Spacer()
                            HStack {
                                Text(recipe.difficulty)
                                    .font(.system(size: 11, weight: .bold))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(6)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 16)
                        }
                        .frame(height: 290)
                    }
                    
                    // Recipe Title and Badges
                    VStack(alignment: .leading, spacing: 10) {
                        Text(recipe.title)
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .foregroundColor(Color.ulamTextDark)
                        
                        Text(recipe.nativeName)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 8) {
                            Label(recipe.origin, systemImage: "flag.fill")
                                .font(.system(size: 12, weight: .semibold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.ulamLightOrange)
                                .foregroundColor(.ulamOrange)
                                .cornerRadius(12)
                            
                            Label(recipe.time, systemImage: "clock")
                                .font(.system(size: 12, weight: .semibold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.black.opacity(0.05))
                                .foregroundColor(Color.ulamTextDark)
                                .cornerRadius(12)
                            
                            Label(recipe.servings, systemImage: "person.2")
                                .font(.system(size: 12, weight: .semibold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.black.opacity(0.05))
                                .foregroundColor(Color.ulamTextDark)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // 3 Stats metric
                    HStack(spacing: 12) {
                        StatCard(value: recipe.calories, label: "Calories")
                        StatCard(value: "\(recipe.rating)★", label: "Rating")
                        StatCard(value: recipe.category, label: "Category")
                    }
                    .padding(.horizontal, 20)
                    
                    // Mga Sangkap and Paraan
                    HStack(spacing: 0) {
                        Button(action: { selectedTab = 0 }) {
                            Text("Mga Sangkap")
                                .font(.system(size: 14, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(selectedTab == 0 ? Color.ulamCard : Color.clear)
                                .foregroundColor(selectedTab == 0 ? Color.ulamOrange : .secondary)
                                .cornerRadius(10)
                                .shadow(color: selectedTab == 0 ? Color.black.opacity(0.06) : .clear, radius: 4)
                        }
                        
                        Button(action: { selectedTab = 1 }) {
                            Text("Paraan")
                                .font(.system(size: 14, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(selectedTab == 1 ? Color.ulamCard : Color.clear)
                                .foregroundColor(selectedTab == 1 ? Color.ulamOrange : .secondary)
                                .cornerRadius(10)
                                .shadow(color: selectedTab == 1 ? Color.black.opacity(0.06) : .clear, radius: 4)
                        }
                    }
                    .padding(4)
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    
                    // Tab Content from api data
                    if isLoadingDetails {
                        HStack {
                            Spacer()
                            ProgressView("Kinakarga ang detalye...")
                                .tint(Color.ulamOrange)
                                .padding(.vertical, 30)
                            Spacer()
                        }
                    } else if selectedTab == 0 {
                        // Ingredients Checklist
                        VStack(spacing: 8) {
                            ForEach(recipe.ingredients, id: \.self) { item in
                                let isChecked = recipeVM.checkedIngredients.contains(item)
                                HStack(spacing: 12) {
                                    Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 18))
                                        .foregroundColor(isChecked ? Color.ulamOrange : .secondary)
                                    
                                    Text(item)
                                        .font(.system(size: 14))
                                        .strikethrough(isChecked, color: .secondary)
                                        .foregroundColor(isChecked ? .secondary : Color.ulamTextDark)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(Color.ulamCard)
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.ulamBorder, lineWidth: 1)
                                )
                                .onTapGesture {
                                    recipeVM.toggleIngredient(item)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    } else {
                        // Instructions List
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, step in
                                HStack(alignment: .top, spacing: 12) {
                                    Text("\(index + 1)")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 24, height: 24)
                                        .background(Color.ulamOrange)
                                        .clipShape(Circle())
                                    
                                    Text(step)
                                        .font(.system(size: 14))
                                        .foregroundColor(Color.ulamTextDark)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.ulamCard)
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.ulamBorder, lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
            .task {
                // Fetch full ingredients & instructions if not yet loaded
                if recipe.ingredients.isEmpty {
                    self.isLoadingDetails = true
                    if let full = await recipeVM.fetchRecipeDetails(id: recipe.id) {
                        self.recipe = full
                    }
                    self.isLoadingDetails = false
                }
            }
            
            // Bottom Action Button
            Button(action: {}) {
                Text("Magsimula ng Pagluluto")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.ulamOrange)
                    .cornerRadius(16)
                    .shadow(color: Color.ulamOrange.opacity(0.35), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .background(
                LinearGradient(
                    colors: [Color.ulamCream.opacity(0), Color.ulamCream],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 90)
                .allowsHitTesting(false)
            )
        }
        .background(Color.ulamCream.ignoresSafeArea())
        .navigationBarHidden(true)
        .ignoresSafeArea(edges: .top)
    }
}

struct StatCard: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.ulamOrange)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.ulamCard)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.ulamBorder, lineWidth: 1)
        )
    }
}
