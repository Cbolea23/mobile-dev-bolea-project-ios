//
//  FavoritesView.swift
//  midterm project
//
//  Created by louis on 9/13/26.
//

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var recipeController: RecipeController
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    
                    // header title and counter badge
                    HStack {
                        Text("Mga Paborito")
                            .font(.system(size: 30, weight: .black, design: .rounded))
                            .foregroundColor(Color.ulamTextDark)
                        Spacer()
                        Text("\(recipeController.savedMeals.count) saved")
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
                    
                    if recipeController.savedMeals.isEmpty {
                        VStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Color.ulamLightOrange)
                                    .frame(width: 72, height: 72)
                                Image(systemName: "heart.slash")
                                    .font(.system(size: 30, weight: .semibold))
                                    .foregroundColor(.ulamOrange)
                            }
                            
                            Text("Wala pang Paboritong Ulam")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(Color.ulamTextDark)
                            
                            Text("I-tap ang puso o bookmark icon sa anumang recipe sa Home para ma-save ito sa iyong account.")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 12)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 44)
                        .padding(.horizontal, 20)
                        .background(Color.ulamCard)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.ulamBorder, lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    } else {
                        // Grid of Bookmarked Recipes
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                            ForEach(recipeController.savedMeals) { meal in
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
            }
            .background(Color.ulamCream.ignoresSafeArea())
        }
    }
}
