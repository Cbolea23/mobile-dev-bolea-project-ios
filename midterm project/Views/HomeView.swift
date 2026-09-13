//
//  HomeView.swift
//  midterm project
//
//  Created by Christian Louis on 9/12/26.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var recipeVM = RecipeViewModel()
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Welcome back, \(authVM.user.username)!")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if recipeVM.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: 200)
                    } else {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            ForEach(recipeVM.categories) { category in
                                NavigationLink(destination: RecipeListView(categoryName: category.strCategory)) {
                                    VStack {
                                        AsyncImage(url: URL(string: category.strCategoryThumb)) { image in
                                            image.resizable().scaledToFit()
                                        } placeholder: {
                                            ProgressView()
                                        }
                                        .frame(height: 100)
                                        .cornerRadius(8)
                                        
                                        Text(category.strCategory)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Recipe Categories")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .onAppear {
                recipeVM.fetchCategories()
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}
