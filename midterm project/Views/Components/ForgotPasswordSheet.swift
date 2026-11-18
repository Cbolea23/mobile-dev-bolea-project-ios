//
//  ForgotPasswordSheet.swift
//  midterm project
//
//  Created by Christian Louis on 9/12/26.
//

import SwiftUI

struct ForgotPasswordSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authController: AuthController
    
    @State private var resetEmail: String
    @State private var newPassword: String = ""
    
    init(initialEmail: String) {
        _resetEmail = State(initialValue: initialEmail)
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                Text("I-reset ang iyong password")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(Color.ulamTextDark)
                
                Text(DatabaseService.shared.isFirebaseActive
                     ? "Ilagay ang iyong email address para makatanggap ng password reset link."
                     : "Ilagay ang email ng iyong account at ang iyong bagong password.")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                if let error = authController.authError {
                    Text(error)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.red)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.red.opacity(0.08))
                        .cornerRadius(12)
                }
                
                AuthInputField(
                    label: "EMAIL",
                    placeholder: "Email",
                    text: $resetEmail,
                    isSecure: false,
                    autocapitalization: .never
                )
                
                if !DatabaseService.shared.isFirebaseActive {
                    AuthInputField(
                        label: "BAGONG PASSWORD",
                        placeholder: "Minimum 6 characters",
                        text: $newPassword,
                        isSecure: true,
                        autocapitalization: .never
                    )
                }
                
                Button(action: {
                    Task {
                        let ok = await authController.resetPassword(email: resetEmail, newPassword: newPassword)
                        if ok {
                            dismiss()
                        }
                    }
                }) {
                    Text("I-save ang Bagong Password")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Color.ulamOrange)
                        .cornerRadius(14)
                }
                .disabled(authController.isSubmitting)
                
                Spacer()
            }
            .padding(24)
            .background(Color.ulamCream.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Isara") {
                        authController.clearMessages()
                        dismiss()
                    }
                    .foregroundColor(.ulamOrange)
                }
            }
        }
    }
}
