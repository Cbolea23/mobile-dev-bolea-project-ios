# Anong Ulam? — Project Context & Progress Summary

**Project:** `midterm project` (Anong Ulam? v1.0)  
**Platform:** iOS (SwiftUI, iOS Deployment Target 18.2)  
**Bundle Identifier:** `-student.mseuf.edu.ph.midterm-project`  
**Firebase Project ID:** `anong-ulam-dffed`

---

## 1. Architecture & Core Modules

- **App Entry Point:** `midterm project/midterm_projectApp.swift`
  - Initializes `AuthViewModel` and `RecipeViewModel` as `@StateObject`s and injects them via `.environmentObject`.
  - Calls `DatabaseService.shared.configureIfNeeded()` on app launch.
- **Models:** `midterm project/Models/RecipeModel.swift`
  - API response models (`CategoryResponse`, `Category`, `MealResponse`, `Meal`) for TheMealDB.
  - App models: `RecipeItem`, `UserProfile`, and `UserAccount`.
- **Controllers / Services:**
  - `midterm project/Controllers/DatabaseService.swift` — Hybrid persistence service (`UserDefaults` local storage + Firebase Auth & Firestore sync).
  - `midterm project/Controllers/AuthViewModel.swift` — Handles login, registration, password reset, guest mode, profile updates, cooked meal count, and sign out.
  - `midterm project/Controllers/RecipeViewModel.swift` — Fetches live recipes/categories from TheMealDB, manages favorites (`savedMeals`), ingredient checklists (`checkedIngredients`), and cooked meals (`cookedMealIds`), synced per user account.
- **Views:** `midterm project/Views/`
  - `ContentView.swift` — Routes between `LoginView` and the main 3-tab `TabView` (`Home`, `Paborito`, `Profile`), syncing `RecipeViewModel` with the active user.
  - `LoginView.swift` — Sign in, Sign up, Guest login, and Forgot Password sheet (adapts UI based on `DatabaseService.shared.isFirebaseActive`).
  - `HomeView.swift` — Featured meal, category browsing, and meal discovery.
  - `RecipeListView.swift` & `RecipeDetailView.swift` — Recipe browsing and detailed view with ingredients & instructions.
  - `CookingModeView.swift` — Step-by-step cooking mode view.
  - `FavoritesView.swift` — Saved/favorite meals (`Paborito`).
  - `ProfileView.swift` — User profile, preferences, and developer info card (displays live `DatabaseService.shared.backendLabel`).

---

## 2. Firebase Integration (Completed Setup)

1. **Configuration File:**
   - `midterm project/GoogleService-Info.plist` is present in the app target and configured for project `anong-ulam-dffed` with matching bundle ID `-student.mseuf.edu.ph.midterm-project`.
2. **Swift Package Dependencies:**
   - `firebase-ios-sdk` (`https://github.com/firebase/firebase-ios-sdk.git`, resolved at `11.15.0` in `Package.resolved`) is added to `midterm project.xcodeproj/project.pbxproj`.
   - `FirebaseCore`, `FirebaseAuth`, and `FirebaseFirestore` are linked to the `midterm project` app target (`Frameworks` build phase and `packageProductDependencies`).
3. **Hybrid Database & Auth Logic (`DatabaseService.swift`):**
   - Uses `#if canImport(FirebaseCore) && canImport(FirebaseAuth) && canImport(FirebaseFirestore)` so it compiles cleanly and activates Firebase automatically when `GoogleService-Info.plist` is bundled.
   - **Authentication:** Supports `signIn`, `register`, `sendPasswordReset`, and `signOut` via `FirebaseAuth`, plus a local guest account (`guest@anongulam.ph`) and seeded default account (`christianbolea@gmail.com`).
   - **Firestore Sync:** Stores/fetches user documents in the `users` collection keyed by Firebase `uid` (sanitizing `password` to `""` before writing to Firestore) and mirrors data locally in `UserDefaults`.
   - **Status Indicator:** Exposes `isFirebaseActive` and `backendLabel` (`"Firebase Auth + Firestore"` when active, `"Local DB (Firebase Ready)"` when in local fallback), displayed in `ProfileView`.

---

## 3. Verification Checklist (Next Steps to Test)

- [ ] **Firebase Console:** Confirm **Email/Password** sign-in is enabled under **Authentication → Sign-in method** and Firestore Database rules allow authenticated users to read/write `users/{uid}`.
- [ ] **Build & Run (`⌘R`):** Run the app in Xcode and check the **Profile** tab → **Database** row shows `Firebase Auth + Firestore`.
- [ ] **Auth & Sync Test:** Register a new account (6+ character password), verify the user appears in **Firebase Auth → Users** and `users/{uid}` in **Firestore**, favorite a recipe, and confirm the Firestore document updates.
