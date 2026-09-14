//
//  HomeView.swift
//  midterm project
//
//  Created by Christian Louis on 9/12/26.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var recipeVM: RecipeViewModel
    @State private var search = ""
    let categories = ["All", "Beef", "Chicken", "Pork", "Seafood"]
    
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
                            Text("Tara, luto tayo, Christian!")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(Color.ulamTextDark)
                        }
                        Spacer()
                        Circle()
                            .fill(Color.ulamOrange)
                            .frame(width: 44, height: 44)
                            .overlay(
                                Text("C")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                            )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    // search Bar
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search meals, ingredients...", text: $search)
                            .font(.system(size: 14))
                            .onSubmit {
                                Task {
                                    await recipeVM.searchMeals(query: search)
                                }
                            }
                        if !search.isEmpty {
                            Button(action: {
                                search = ""
                                Task { await recipeVM.fetchMeals(for: recipeVM.selectedCategory) }
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
                            ForEach(categories, id: \.self) { cat in
                                Text(cat)
                                    .font(.system(size: 13, weight: .semibold))
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 8)
                                    .background(recipeVM.selectedCategory == cat ? Color.ulamOrange : Color.ulamCard)
                                    .foregroundColor(recipeVM.selectedCategory == cat ? .white : Color.ulamTextDark)
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(recipeVM.selectedCategory == cat ? Color.clear : Color.ulamBorder, lineWidth: 1)
                                    )
                                    .onTapGesture {
                                        Task {
                                            await recipeVM.fetchMeals(for: cat)
                                        }
                                    }
                            }
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
                            NavigationLink(destination: RecipeListView()) {
                                Text("Tingnan lahat")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.ulamOrange)
                            }
                        }
                        
                        NavigationLink(destination: RecipeDetailView(recipe: recipeVM.featuredMeal)) {
                            ZStack(alignment: .bottomLeading) {
                                AsyncImage(url: URL(string: recipeVM.featuredMeal.imageUrl)) { img in
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
                                    Text(recipeVM.featuredMeal.category)
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color.white.opacity(0.25))
                                        .cornerRadius(8)
                                    
                                    Text(recipeVM.featuredMeal.title)
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                    
                                    HStack(spacing: 14) {
                                        Label(recipeVM.featuredMeal.time, systemImage: "clock")
                                        Label(recipeVM.featuredMeal.calories, systemImage: "flame")
                                        Label(recipeVM.featuredMeal.rating, systemImage: "star.fill")
                                            .foregroundColor(.yellow)
                                    }
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                                }
                                .padding(16)
                                
                                VStack {
                                    HStack {
                                        Spacer()
                                        Text(recipeVM.featuredMeal.difficulty.uppercased())
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
                            NavigationLink(destination: RecipeListView()) {
                                Text("Lahat")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.ulamOrange)
                            }
                        }
                        
                        if recipeVM.isLoading {
                            HStack {
                                Spacer()
                                ProgressView("Kumukuha ng mga lutuin...")
                                    .tint(Color.ulamOrange)
                                    .padding(.vertical, 30)
                                Spacer()
                            }
                        } else {
                            LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                                ForEach(recipeVM.popularMeals) { meal in
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

struct PopularDishCard: View {
    @EnvironmentObject var recipeVM: RecipeViewModel
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
                    recipeVM.toggleSave(meal: meal)
                }) {
                    Image(systemName: recipeVM.isSaved(meal: meal) ? "heart.fill" : "heart")
                        .font(.system(size: 12, weight: .bold))
                        .padding(7)
                        .background(Color.black.opacity(0.45))
                        .foregroundColor(recipeVM.isSaved(meal: meal) ? Color.ulamOrange : .white)
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
