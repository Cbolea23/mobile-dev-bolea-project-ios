//
//  PopularDishCard.swift
//  midterm project
//
//  Created by Christian Louis on 9/12/26.
//

import SwiftUI

struct PopularDishCard: View {
    @EnvironmentObject var recipeController: RecipeController
    let meal: RecipeItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: meal.imageUrl)) { img in
                    img.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(height: 120)
                .clipped()
                .cornerRadius(14)
                
                Button(action: {
                    recipeController.toggleSave(meal: meal)
                }) {
                    Image(systemName: recipeController.isSaved(meal: meal) ? "heart.fill" : "heart")
                        .font(.system(size: 12, weight: .bold))
                        .padding(7)
                        .background(Color.black.opacity(0.45))
                        .foregroundColor(recipeController.isSaved(meal: meal) ? Color.ulamOrange : .white)
                        .clipShape(Circle())
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
