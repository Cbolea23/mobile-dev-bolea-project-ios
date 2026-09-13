//
//  midterm_projectApp.swift
//  midterm project
//
//  Created by Christian Louis on 9/7/26.
//

import SwiftUI

@main
struct midterm_projectApp: App {
    @StateObject private var authVM = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authVM.isLoggedIn {
                    HomeView()
                } else {
                    LoginView()
                }
            }
            .environmentObject(authVM)
        }
    }
}
