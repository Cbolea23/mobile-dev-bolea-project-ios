# Anong Ulam? — Project Context & Progress Summary

**Project:** `midterm project` (Anong Ulam? v1.0)  
**Platform:** iOS (SwiftUI, iOS Deployment Target 18.2)  
**Bundle Identifier:** `-student.mseuf.edu.ph.midterm-project`  
**Firebase Project ID:** `anong-ulam-dffed`

---

## 1. Architecture & Core Modules (MVC)

- **App Entry Point:** `midterm project/midterm_projectApp.swift`
  - Initializes `AuthController` and `RecipeController` as `@StateObject`s and injects them via `.environmentObject`.
  - Calls `DatabaseService.shared.configureIfNeeded()` on app launch.
- **Models:** `midterm project/Models/`
  - `RecipeModel.swift` — API response models (`CategoryResponse`, `Category`, `MealResponse`, `Meal`) for TheMealDB and `RecipeItem`.
  - `UserModel.swift` — `UserProfile` and `UserAccount` (with salted SHA-256 `passwordHash` and per-meal `checkedIngredientsByMeal`).
- **Controllers / Services:** `midterm project/Controllers/`
  - `DatabaseService.swift` — Hybrid persistence service (`UserDefaults` local storage with salted SHA-256 credential verification + Firebase Auth & Firestore sync, plus seeded demo account fallback).
  - `AuthController.swift` — Handles login, registration (6+ char password validation), password reset, guest mode, profile updates, cooked meal count, and sign out.
  - `RecipeController.swift` — Fetches live recipes/categories from TheMealDB using `URLComponents` and HTTP status checks, applies dietary & skill preferences, manages favorites (`savedMeals` with automatic full-detail hydration), per-meal ingredient checklists (`checkedIngredientsByMeal`), and cooked meals (`cookedMealIds`).
- **Views:** `midterm project/Views/`
  - `ContentView.swift` — Routes between `LoginView` and the main 3-tab `TabView` (`Home`, `Paborito`, `Profile`), syncing `RecipeController` with the active user.
  - `LoginView.swift` — Sign in, Sign up, Guest login, and Forgot Password sheet.
  - `HomeView.swift` — Featured meal, dietary/skill preference indicator, category browsing, search, and tappable profile avatar.
  - `RecipeListView.swift` & `RecipeDetailView.swift` — Recipe browsing and detailed view with per-meal ingredient checklist & instructions.
  - `CookingModeView.swift` — Step-by-step cooking mode view with built-in timer, completion alert, and optional local notification (`UNUserNotificationCenter`).
  - `FavoritesView.swift` — Saved/favorite meals (`Paborito`).
  - `ProfileView.swift` — User profile, interactive preferences, and developer info card (displays live `DatabaseService.shared.backendLabel`).
- **Reusable View Components:** `midterm project/Views/Components/`
  - `AuthInputField.swift`, `ForgotPasswordSheet.swift`, `PopularDishCard.swift`, `RecipeRowCard.swift`, `SavedDishCard.swift`, `StatCard.swift`, `TimerPresetButton.swift`, `EditProfileSettingsSheet.swift`, `ProfileComponents.swift`.

---

## 2. Firebase Integration (Completed Setup)

1. **Configuration File:**
   - `midterm project/GoogleService-Info.plist` is present in the app target and configured for project `anong-ulam-dffed` with matching bundle ID `-student.mseuf.edu.ph.midterm-project`.
2. **Swift Package Dependencies:**
   - `firebase-ios-sdk` (`https://github.com/firebase/firebase-ios-sdk.git`, resolved at `11.15.0` in `Package.resolved`) is added to `midterm project.xcodeproj/project.pbxproj`.
   - `FirebaseCore`, `FirebaseAuth`, and `FirebaseFirestore` are linked to the `midterm project` app target (`Frameworks` build phase and `packageProductDependencies`).
3. **Hybrid Database & Auth Logic (`DatabaseService.swift`):**
   - Uses `#if canImport(FirebaseCore) && canImport(FirebaseAuth) && canImport(FirebaseFirestore)` so it compiles cleanly and activates Firebase automatically when `GoogleService-Info.plist` is bundled.
   - **Authentication:** Supports `signIn`, `register`, `sendPasswordReset`, and `signOut` via `FirebaseAuth`, local guest account (`guest@anongulam.ph`), and seeded default demo account (`christianbolea@gmail.com`) fallback.
   - **Firestore Sync:** Stores/fetches user documents in the `users` collection keyed by Firebase `uid` (clearing `passwordHash` before writing to Firestore) and mirrors hashed credentials locally in `UserDefaults`.
   - **Status Indicator:** Exposes `isFirebaseActive` and `backendLabel` (`"Firebase Auth + Firestore"` when active, `"Local DB (Firebase Ready)"` when in local fallback), displayed in `ProfileView`.
