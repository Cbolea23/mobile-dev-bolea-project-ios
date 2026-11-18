//
//  StatCard.swift
//  midterm project
//
//  Created by louis on 9/13/26.
//

import SwiftUI

struct StatCard: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.ulamOrange)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.ulamCard)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.ulamBorder, lineWidth: 1)
        )
    }
}
