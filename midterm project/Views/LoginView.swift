//
//  LoginView.swift
//  midterm project
//
//  Created by Christian Louis on 9/12/26.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var usernameInput = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "fork.knife.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.orange)
            
            Text("ChefCraft")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            TextField("Enter your name", text: $usernameInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 40)
            
            Button(action: {
                authVM.login(username: usernameInput)
            }) {
                Text("Get Started")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)
            .disabled(usernameInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
