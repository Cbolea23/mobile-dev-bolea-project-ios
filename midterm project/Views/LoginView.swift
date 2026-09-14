//
//  LoginView.swift
//  midterm project
//
//  Created by Christian Louis on 9/12/26.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var email: String = "christianbolea@gmail.com"
    @State private var password: String = "••••••••"
    
    var body: some View {
        ZStack {
            Color.ulamCream.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    Spacer(minLength: 40)
                    
                    // App Logo Icon
                    ZStack {
                        Circle()
                            .fill(Color.ulamLightOrange)
                            .frame(width: 88, height: 88)
                        
                        Image(systemName: "cooktop.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 46, height: 46)
                            .foregroundColor(.ulamOrange)
                    }
                    
                    // brand and tagline
                    VStack(spacing: 6) {
                        Text("Anong\nUlam?")
                            .font(.system(size: 40, weight: .black, design: .rounded))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.ulamTextDark)
                        
                        Text("A culinary app by Christian Louis Bolea")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    
                    // banner
                    HStack(spacing: 8) {
                        Image(systemName: "sparkle.magnifyingglass")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.ulamOrange)
                        Text("Discover Foods that you never tried before!")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.ulamOrange)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.ulamLightOrange)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.ulamOrange.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal, 24)
                    
                    // Input
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("EMAIL")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.secondary)
                            
                            TextField("Email", text: $email)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(Color.ulamCard)
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.ulamBorder, lineWidth: 1)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("PASSWORD")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.secondary)
                            
                            SecureField("Password", text: $password)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(Color.ulamCard)
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.ulamBorder, lineWidth: 1)
                                )
                        }
                        
                        HStack {
                            Spacer()
                            Button(action: {}) {
                                Text("Nakalimutan ang password?")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.ulamOrange)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // button
                    Button(action: {
                        authVM.login(email: email, password: password)
                    }) {
                        Text("Mag-Sign In")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.ulamOrange)
                            .cornerRadius(16)
                            .shadow(color: Color.ulamOrange.opacity(0.38), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 24)
                    
                    // Separator
                    HStack(spacing: 12) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 1)
                        Text("o")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 4)
                    
                    Spacer(minLength: 20)
                }
            }
        }
    }
}
