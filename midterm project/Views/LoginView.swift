//
//  LoginView.swift
//  midterm project
//
//  Created by Christian Louis on 9/12/26.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authController: AuthController
    @State private var isRegistering: Bool = false
    @State private var username: String = ""
    @State private var email: String = DatabaseService.defaultEmail
    @State private var password: String = DatabaseService.demoPlaceholderPassword
    @State private var confirmPassword: String = ""
    @State private var showForgotPasswordSheet: Bool = false
    
    var body: some View {
        ZStack {
            Color.ulamCream.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    Spacer(minLength: 32)
                    
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
                    
                    // Brand and Tagline
                    VStack(spacing: 6) {
                        Text("Anong\nUlam?")
                            .font(.system(size: 40, weight: .black, design: .rounded))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.ulamTextDark)
                        
                        Text("A culinary app by Christian Louis Bolea")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    
                    // Banner
                    HStack(spacing: 8) {
                        Image(systemName: "sparkle.magnifyingglass")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.ulamOrange)
                        Text(isRegistering
                             ? "Gumawa ng account at i-save ang iyong mga paborito!"
                             : "Discover Foods that you never tried before!")
                            .font(.system(size: 13.5, weight: .semibold))
                            .foregroundColor(.ulamOrange)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 12)
                    .background(Color.ulamLightOrange)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.ulamOrange.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal, 24)
                    
                    // Feedback Banners
                    if let error = authController.authError {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(error)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.red)
                            Spacer()
                        }
                        .padding(12)
                        .background(Color.red.opacity(0.08))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red.opacity(0.25), lineWidth: 1)
                        )
                        .padding(.horizontal, 24)
                    } else if let success = authController.authSuccessMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(success)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.green)
                            Spacer()
                        }
                        .padding(12)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.green.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal, 24)
                    }
                    
                    // Input Fields
                    VStack(alignment: .leading, spacing: 14) {
                        if isRegistering {
                            AuthInputField(
                                label: "USERNAME",
                                placeholder: "Hal. Juan Dela Cruz",
                                text: $username,
                                isSecure: false,
                                autocapitalization: .words
                            )
                        }
                        
                        AuthInputField(
                            label: "EMAIL",
                            placeholder: "Email",
                            text: $email,
                            isSecure: false,
                            autocapitalization: .never
                        )
                        
                        AuthInputField(
                            label: "PASSWORD",
                            placeholder: "Password",
                            text: $password,
                            isSecure: true,
                            autocapitalization: .never
                        )
                        
                        if isRegistering {
                            AuthInputField(
                                label: "CONFIRM PASSWORD",
                                placeholder: "Ulitin ang password",
                                text: $confirmPassword,
                                isSecure: true,
                                autocapitalization: .never
                            )
                        } else {
                            HStack {
                                Spacer()
                                Button(action: {
                                    authController.clearMessages()
                                    showForgotPasswordSheet = true
                                }) {
                                    Text("Nakalimutan ang password?")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.ulamOrange)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Primary Action Button
                    Button(action: {
                        Task {
                            if isRegistering {
                                await authController.register(
                                    username: username,
                                    email: email,
                                    password: password,
                                    confirmPassword: confirmPassword
                                )
                            } else {
                                await authController.login(email: email, password: password)
                            }
                        }
                    }) {
                        HStack(spacing: 8) {
                            if authController.isSubmitting {
                                ProgressView()
                                    .tint(.white)
                            }
                            Text(isRegistering ? "Gumawa ng Account" : "Mag-Sign In")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.ulamOrange)
                        .cornerRadius(16)
                        .shadow(color: Color.ulamOrange.opacity(0.38), radius: 10, x: 0, y: 5)
                    }
                    .disabled(authController.isSubmitting)
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
                    .padding(.top, 2)
                    
                    // Account Creation Toggle & Guest Mode
                    VStack(spacing: 12) {
                        Button(action: toggleAuthMode) {
                            Text(isRegistering
                                 ? "May Account Na? Mag-Sign In"
                                 : "Gumawa ng Bagong Account")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.ulamOrange)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.ulamCard)
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.ulamOrange.opacity(0.35), lineWidth: 1)
                                )
                        }
                        
                        Button(action: {
                            authController.continueAsGuest()
                        }) {
                            Text("Magpatuloy bilang Bisita")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondary)
                                .padding(.vertical, 6)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 24)
                }
            }
        }
        .sheet(isPresented: $showForgotPasswordSheet) {
            ForgotPasswordSheet(initialEmail: email)
                .environmentObject(authController)
        }
    }
    
    private func toggleAuthMode() {
        authController.clearMessages()
        withAnimation(.easeInOut(duration: 0.2)) {
            isRegistering.toggle()
        }
        if isRegistering {
            if email == DatabaseService.defaultEmail {
                email = ""
            }
            if password == DatabaseService.demoPlaceholderPassword {
                password = ""
            }
            confirmPassword = ""
        } else if email.isEmpty {
            email = DatabaseService.defaultEmail
            password = DatabaseService.demoPlaceholderPassword
        }
    }
}
