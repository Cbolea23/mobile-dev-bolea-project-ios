//
//  ProfileView.swift
//  midterm project
//
//  Created by Christian Louis on 9/12/26.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        Form {
            Section(header: Text("User Profile")) {
                TextField("Username", text: $authVM.user.username)
                TextField("Email", text: $authVM.user.email)
                TextField("Favorite Cuisine", text: $authVM.user.favoriteCuisine)
            }
            
            Section {
                Button("Log Out", role: .destructive) {
                    authVM.logout()
                }
            }
        }
        .navigationTitle("Profile")
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(AuthViewModel())
    }
}
