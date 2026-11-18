//
//  RecipeRowCard.swift
//  midterm project
//
//  Created by Christian Louis on 9/12/26.
//

import SwiftUI

struct RecipeRowCard: View {
    @EnvironmentObject var recipeController: RecipeController
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
                recipeController.toggleSave(meal: meal)
            }) {
                Image(systemName: recipeController.isSaved(meal: meal) ? "heart.fill" : "heart")
                    .font(.system(size: 15, weight: .bold))
                    .padding(8)
                    .background(recipeController.isSaved(meal: meal) ? Color.ulamLightOrange : Color.black.opacity(0.05))
                    .foregroundColor(recipeController.isSaved(meal: meal) ? .ulamOrange : .secondary)
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
