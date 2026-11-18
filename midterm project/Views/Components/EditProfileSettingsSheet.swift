//
//  EditProfileSettingsSheet.swift
//  midterm project
//
//  Created by Christian Louis on 9/12/26.
//

import SwiftUI

struct EditProfileSettingsSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authController: AuthController
    @EnvironmentObject var recipeController: RecipeController
    
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
                        authController.updateProfile(
                            username: username,
                            dietaryPreference: dietaryPreference,
                            skillLevel: skillLevel,
                            notificationsEnabled: notificationsEnabled
                        )
                        recipeController.applyPreferences(
                            dietary: dietaryPreference,
                            skill: skillLevel
                        )
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(.ulamOrange)
                }
            }
            .onAppear {
                username = authController.currentUserName
                dietaryPreference = authController.userProfile.dietaryPreference
                skillLevel = authController.userProfile.skillLevel
                notificationsEnabled = authController.userProfile.notificationsEnabled
            }
        }
    }
}
