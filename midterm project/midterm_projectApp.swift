//
//  midterm_projectApp.swift
//  midterm project
//
//  Created by Christian Louis on 9/7/26.
//

import SwiftUI
import UserNotifications

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}

@main
struct midterm_projectApp: App {
    @StateObject private var authController = AuthController()
    @StateObject private var recipeController = RecipeController()
    
    init() {
        DatabaseService.shared.configureIfNeeded()
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authController)
                .environmentObject(recipeController)
        }
    }
}
