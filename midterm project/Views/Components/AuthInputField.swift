//
//  AuthInputField.swift
//  midterm project
//
//  Created by Christian Louis on 9/12/26.
//

import SwiftUI

struct AuthInputField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    let isSecure: Bool
    var autocapitalization: TextInputAutocapitalization = .never
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.secondary)
            
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .textInputAutocapitalization(autocapitalization)
                        .autocorrectionDisabled()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.ulamCard)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.ulamBorder, lineWidth: 1)
            )
        }
    }
}
