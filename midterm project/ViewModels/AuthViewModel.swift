//
//  AuthViewModel.swift
//  midterm project
//
//  Created by louis on 9/13/26.
//

import Foundation
import Combine

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUserEmail: String = "christianbolea@gmail.com"
    @Published var currentUserName: String = "Christian"
    
    func login(email: String, password: String) {
        // Validate credentials for demo authentication
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        self.currentUserEmail = email
        self.isAuthenticated = true
    }
    
    func logout() {
        self.isAuthenticated = false
    }
}
