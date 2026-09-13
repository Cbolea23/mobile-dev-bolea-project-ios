//
//  RecipeListView.swift
//  midterm project
//
//  Created by Christian Louis on 9/12/26.
//

import SwiftUI

struct RecipeListView: View {
    let categoryName: String
    @StateObject private var recipeVM = RecipeViewModel()
    
    var body: some View {
        List(recipeVM.meals) { meal in
            HStack(spacing: 15) {
                AsyncImage(url: URL(string: meal.strMealThumb)) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Text(meal.strMeal)
                    .font(.headline)
            }
        }
        .navigationTitle(categoryName)
        .onAppear {
            recipeVM.fetchMeals(category: categoryName)
        }
    }
}

#Preview {
    NavigationStack {
        RecipeListView(categoryName: "Dessert")
    }
}
