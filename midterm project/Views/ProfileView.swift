//
//  ProfileView.swift
//  midterm project
//
//  Created by Christian Louis on 9/12/26.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authController: AuthController
    @EnvironmentObject var recipeController: RecipeController
    @ObservedObject private var dbService = DatabaseService.shared
    
    @State private var showEditProfileSheet: Bool = false
    
    private var avatarInitial: String {
        let trimmed = authController.currentUserName.trimmingCharacters(in: .whitespacesAndNewlines)
        return String(trimmed.prefix(1)).uppercased().isEmpty ? "C" : String(trimmed.prefix(1)).uppercased()
    }
    
    private var cookedDisplayCount: Int {
        max(authController.userProfile.cookedCount, recipeController.cookedMealIds.count)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                
                // Profile Header
                VStack(spacing: 8) {
                    Circle()
                        .fill(Color.ulamOrange)
                        .frame(width: 84, height: 84)
                        .overlay(
                            Text(avatarInitial)
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .shadow(color: Color.ulamOrange.opacity(0.35), radius: 10, y: 5)
                    
                    Text(authController.currentUserName)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color.ulamTextDark)
                    
                    Text(authController.currentUserEmail)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        showEditProfileSheet = true
                    }) {
                        Label("I-edit ang Profile", systemImage: "pencil")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.ulamOrange)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(Color.ulamLightOrange)
                            .cornerRadius(20)
                    }
                    .padding(.top, 2)
                }
                .padding(.top, 16)
                
                // 3 Dynamic Stats
                HStack {
                    ProfileStatColumn(number: "\(max(recipeController.popularMeals.count, 8))", title: "Recipes")
                    Divider().frame(height: 28)
                    ProfileStatColumn(number: "\(recipeController.savedMeals.count)", title: "Saved")
                    Divider().frame(height: 28)
                    ProfileStatColumn(number: "\(cookedDisplayCount)", title: "Cooked")
                }
                .padding(.vertical, 4)
                
                // Interactive Settings
                VStack(alignment: .leading, spacing: 8) {
                    Text("MGA SETTING")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 0) {
                        Button(action: { showEditProfileSheet = true }) {
                            SettingListRow(
                                emoji: "🥗",
                                title: "Dietary Preferences",
                                subtitle: authController.userProfile.dietaryPreference
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Divider().padding(.leading, 52)
                        
                        Button(action: { showEditProfileSheet = true }) {
                            SettingListRow(
                                emoji: "🧑‍🍳",
                                title: "Cooking Skill Level",
                                subtitle: authController.userProfile.skillLevel
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Divider().padding(.leading, 52)
                        
                        Button(action: { showEditProfileSheet = true }) {
                            SettingListRow(
                                emoji: "🔔",
                                title: "Notifications",
                                subtitle: authController.userProfile.notificationsEnabled ? "Enabled" : "Disabled"
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .background(Color.ulamCard)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.ulamBorder, lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                }
                
                // DEVELOPER INFO Card
                VStack(alignment: .leading, spacing: 8) {
                    Text("DEVELOPER INFO")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                    
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Image(systemName: "laptopcomputer")
                                        .font(.title3)
                                        .foregroundColor(.white)
                                )
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Christian Louis Bolea")
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(.white)
                                Text("iOS App Developer")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        
                        VStack(spacing: 10) {
                            DevMetricRow(label: "Project", value: "Final iOS App")
                            DevMetricRow(label: "App", value: "Anong Ulam? v1.0")
                            DevMetricRow(label: "Stack", value: "SwiftUI + MVC / TheMealDB")
                            DevMetricRow(label: "Database", value: dbService.backendLabel)
                        }
                        .padding(14)
                        .background(Color.white.opacity(0.16))
                        .cornerRadius(12)
                        
                        if let githubURL = URL(string: "https://github.com/Cbolea23/mobile-dev-bolea-project-ios") {
                            Link(destination: githubURL) {
                                HStack(spacing: 8) {
                                    Image(systemName: "link")
                                    Text("GitHub Repository")
                                        .font(.system(size: 14, weight: .bold))
                                }
                                .foregroundColor(Color.ulamTextDark)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.white)
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.ulamOrange)
                    .cornerRadius(20)
                    .shadow(color: Color.ulamOrange.opacity(0.25), radius: 8, y: 4)
                    .padding(.horizontal, 20)
                }
                
                // Sign Out Button
                Button(action: {
                    authController.logout()
                }) {
                    Text("Mag-Sign Out")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.red)
                        .padding(.top, 4)
                        .padding(.bottom, 30)
                }
            }
        }
        .background(Color.ulamCream.ignoresSafeArea())
        .sheet(isPresented: $showEditProfileSheet) {
            EditProfileSettingsSheet()
                .environmentObject(authController)
                .environmentObject(recipeController)
        }
    }
}
