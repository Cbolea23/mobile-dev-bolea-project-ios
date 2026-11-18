//
//  ProfileComponents.swift
//  midterm project
//
//  Created by Christian Louis on 9/12/26.
//

import SwiftUI

struct ProfileStatColumn: View {
    let number: String
    let title: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(number)
                .font(.system(size: 20, weight: .heavy, design: .rounded))
                .foregroundColor(.ulamOrange)
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct SettingListRow: View {
    let emoji: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 14) {
            Text(emoji)
                .font(.system(size: 22))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.ulamTextDark)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary.opacity(0.6))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}

struct DevMetricRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.85))
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
        }
    }
}
