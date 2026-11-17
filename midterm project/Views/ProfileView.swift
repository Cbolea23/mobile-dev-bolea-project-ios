//
//  ProfileView.swift
//  midterm project
//
//  Created by Christian Louis on 9/12/26.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var recipeVM: RecipeViewModel
    @ObservedObject private var dbService = DatabaseService.shared
    
    @State private var showEditProfileSheet: Bool = false
    
    private var avatarInitial: String {
        let trimmed = authVM.currentUserName.trimmingCharacters(in: .whitespacesAndNewlines)
        return String(trimmed.prefix(1)).uppercased().isEmpty ? "C" : String(trimmed.prefix(1)).uppercased()
    }
    
    private var cookedDisplayCount: Int {
        max(authVM.userProfile.cookedCount, recipeVM.cookedMealIds.count)
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
                    
                    Text(authVM.currentUserName)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color.ulamTextDark)
                    
                    Text(authVM.currentUserEmail)
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
                    ProfileStatColumn(number: "\(max(recipeVM.popularMeals.count, 8))", title: "Recipes")
                    Divider().frame(height: 28)
                    ProfileStatColumn(number: "\(recipeVM.savedMeals.count)", title: "Saved")
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
                                subtitle: authVM.userProfile.dietaryPreference
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Divider().padding(.leading, 52)
                        
                        Button(action: { showEditProfileSheet = true }) {
                            SettingListRow(
                                emoji: "🧑‍🍳",
                                title: "Cooking Skill Level",
                                subtitle: authVM.userProfile.skillLevel
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Divider().padding(.leading, 52)
                        
                        Button(action: { showEditProfileSheet = true }) {
                            SettingListRow(
                                emoji: "🔔",
                                title: "Notifications",
                                subtitle: authVM.userProfile.notificationsEnabled ? "Enabled" : "Disabled"
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
                        
                        Link(destination: URL(string: "https://github.com/Cbolea23/mobile-dev-bolea-project-ios")!) {
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
                    .padding(16)
                    .background(Color.ulamOrange)
                    .cornerRadius(20)
                    .shadow(color: Color.ulamOrange.opacity(0.25), radius: 8, y: 4)
                    .padding(.horizontal, 20)
                }
                
                // Sign Out Button
                Button(action: {
                    authVM.logout()
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
                .environmentObject(authVM)
        }
    }
}

struct EditProfileSettingsSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    
    @State private var username: String = ""
    @State private var dietaryPreference: String = "No restrictions"
    @State private var skillLevel: String = "No preference"
    @State private var notificationsEnabled: Bool = true
    
    private let dietaryOptions = [
        "No restrictions",
        "Halal",
        "Vegetarian",
        "Pescatarian",
        "Low-Carb",
        "Dairy-Free"
    ]
    
    private let skillOptions = [
        "No preference",
        "Beginner",
        "Home Cook",
        "Intermediate",
        "Chef"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    TextField("Username", text: $username)
                }
                
                Section("Mga Setting sa Pagluluto") {
                    Picker("Dietary Preferences", selection: $dietaryPreference) {
                        ForEach(dietaryOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    
                    Picker("Cooking Skill Level", selection: $skillLevel) {
                        ForEach(skillOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    
                    Toggle("Notifications", isOn: $notificationsEnabled)
                        .tint(.ulamOrange)
                }
            }
            .navigationTitle("I-edit ang Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Kanselahin") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("I-save") {
                        authVM.updateProfile(
                            username: username,
                            dietaryPreference: dietaryPreference,
                            skillLevel: skillLevel,
                            notificationsEnabled: notificationsEnabled
                        )
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(.ulamOrange)
                }
            }
            .onAppear {
                username = authVM.currentUserName
                dietaryPreference = authVM.userProfile.dietaryPreference
                skillLevel = authVM.userProfile.skillLevel
                notificationsEnabled = authVM.userProfile.notificationsEnabled
            }
        }
    }
}

struct ProfileStatColumn: View {
    let number: String
    let title: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(number)
                .font(.system(size: 20, weight: .heavy, design: .rounded))
                .foregroundColor(.ulamOrange)
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct SettingListRow: View {
    let emoji: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 14) {
            Text(emoji)
                .font(.system(size: 22))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.ulamTextDark)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary.opacity(0.6))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}

struct DevMetricRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.85))
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
        }
    }
}
