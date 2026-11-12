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
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                
                // profile
                VStack(spacing: 8) {
                    Circle()
                        .fill(Color.ulamOrange)
                        .frame(width: 84, height: 84)
                        .overlay(
                            Text("C")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .shadow(color: Color.ulamOrange.opacity(0.35), radius: 10, y: 5)
                    
                    Text("Christian")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color.ulamTextDark)
                    
                    Text("christianbolea@gmail.com")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 16)
                
                // 3 stats
                HStack {
                    ProfileStatColumn(number: "12", title: "Recipes")
                    Divider().frame(height: 28)
                    ProfileStatColumn(number: "4", title: "Saved")
                    Divider().frame(height: 28)
                    ProfileStatColumn(number: "8", title: "Cooked")
                }
                .padding(.vertical, 4)
                
                // settings
                VStack(alignment: .leading, spacing: 8) {
                    Text("MGA SETTING")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 0) {
                        SettingListRow(emoji: "🥗", title: "Dietary Preferences", subtitle: "No restrictions")
                        Divider().padding(.leading, 52)
                        SettingListRow(emoji: "🧑‍🍳", title: "Cooking Skill Level", subtitle: "No preference")
                        Divider().padding(.leading, 52)
                        SettingListRow(emoji: "🔔", title: "Notifications", subtitle: "Enabled")
                    }
                    .background(Color.ulamCard)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.ulamBorder, lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                }
                
                // DEVELOPER INFO Card
                VStack(alignment: .leading, spacing: 8) {
                    Text("DEVELOPER INFO")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                    
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Image(systemName: "laptopcomputer")
                                        .font(.title3)
                                        .foregroundColor(.white)
                                )
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Christian Louis Bolea")
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(.white)
                                Text("iOS App Developer")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        
                        VStack(spacing: 10) {
                            DevMetricRow(label: "Project", value: "Midterm iOS App")
                            DevMetricRow(label: "App", value: "Anong Ulam? v1.0")
                            DevMetricRow(label: "Stack", value: "SwiftUI + MVC / TheMealDB")
                        }
                        .padding(14)
                        .background(Color.white.opacity(0.16))
                        .cornerRadius(12)
                        
                        Link(destination: URL(string: "https://github.com/Cbolea23/mobile-dev-bolea-project-ios")!) {
                            HStack(spacing: 8) {
                                Image(systemName: "link")
                                Text("GitHub Repository")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .foregroundColor(Color.ulamTextDark)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                    }
                    .padding(16)
                    .background(Color.ulamOrange)
                    .cornerRadius(20)
                    .shadow(color: Color.ulamOrange.opacity(0.25), radius: 8, y: 4)
                    .padding(.horizontal, 20)
                }
                
                // signout button
                Button(action: {
                    authVM.logout()
                }) {
                    Text("Mag-Sign Out")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.red)
                        .padding(.top, 4)
                        .padding(.bottom, 30)
                }
            }
        }
        .background(Color.ulamCream.ignoresSafeArea())
    }
}

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
