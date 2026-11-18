//
//  SavedDishCard.swift
//  midterm project
//
//  Created by louis on 9/13/26.
//

import SwiftUI

struct SavedDishCard: View {
    @EnvironmentObject var recipeController: RecipeController
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
                        recipeController.removeSaved(id: meal.id)
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
