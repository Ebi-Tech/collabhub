# CollabHub

A Flutter mobile application for university students to discover project collaborators based on skills, availability, and commitment level. Built with Firebase backend, BLoC state management, and full Google Sign-In support.

---

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Firebase Setup](#firebase-setup)
- [API Key Security](#api-key-security)
- [Environment & Configuration](#environment--configuration)
- [Running the App](#running-the-app)
- [Running Tests](#running-tests)
- [SharedPreferences](#sharedpreferences)
- [Contributing](#contributing)

---
Demo Video
https://www.youtube.com/watch?v=899tid1FYQ0


## Features

- **Authentication** — Email/password registration and Google Sign-In via Firebase Auth
- **Profile Management** — Edit name, role, bio, skills; upload avatar from gallery (stored in Firebase Storage); Google account photo auto-synced on first sign-in
- **Project Feed** — Real-time Firestore feed of all posted projects with status badges (Open / Closed)
- **Create Project** — Post a project with title, description, required skills, and open/closed status
- **Upvote / Downvote** — Atomic Firestore transactions to prevent double-voting
- **Filter & Sort** — Filter by Open/Closed status; sort by Most Recent, Most Upvoted, or Most Downvoted; preferences persisted across sessions
- **Edit & Delete** — Project owners can edit or delete their own posts
- **Dark Mode** — Full system-aware dark/light theme toggle; preference persisted locally
- **Responsive UI** — Material 3 design, context-aware color system, works on Android, iOS, macOS, and Web

---

## Tech Stack

| Layer | Technology |
|---|---|
| UI Framework | Flutter 3.x (Dart) |
| State Management | flutter_bloc 8.x (BLoC + Cubit) |
| Authentication | Firebase Auth + Google Sign-In |
| Database | Cloud Firestore |
| File Storage | Firebase Storage |
| Local Persistence | SharedPreferences |
| Image Picking | image_picker |
| Unique IDs | uuid |
| Equality | equatable |

---

## Project Structure

```
lib/
├── main.dart                   # Firebase init + app entry point
├── app.dart                    # MaterialApp, theme, BLoC providers
├── firebase_options.dart       # Generated Firebase config (per platform)
│
├── bloc/
│   ├── auth_bloc.dart          # Authentication events → states
│   ├── auth_event.dart
│   ├── auth_state.dart
│   ├── home_bloc.dart          # Feed CRUD, voting, filtering, sorting
│   ├── home_event.dart
│   ├── home_state.dart
│   └── theme_cubit.dart        # Dark/light mode toggle
│
├── models/
│   ├── user_model.dart         # Firestore user document
│   └── project_model.dart      # Firestore project document
│
├── services/
│   ├── auth_service.dart       # Firebase Auth + Firestore user ops
│   ├── firestore_service.dart  # Project CRUD + vote transactions
│   └── prefs_service.dart      # SharedPreferences wrapper
│
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home/
│   │   └── home_screen.dart    # Feed with BlocConsumer for error toasts
│   ├── create_post/
│   │   └── create_post_screen.dart
│   ├── profile/
│   │   └── profile_screen.dart # View + edit mode, avatar upload
│   └── main_screen.dart        # Bottom navigation shell
│
├── widgets/
│   ├── project_card.dart       # Feed item card
│   ├── skill_badge.dart        # Chip for skills
│   ├── app_header.dart         # Shared top bar
│   ├── custom_button.dart      # Themed button
│   ├── edit_post_dialog.dart   # Inline edit dialog
│   └── filter_sheet.dart       # Bottom sheet for filter/sort
│
└── utils/
    ├── constants.dart          # AppColors (light + dark semantic colors)
    └── validators.dart         # Form field validators
```

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.5.0`
- Dart SDK `>=3.5.0`
- Android Studio / Xcode (for emulator or device)
- A Firebase project with Firestore, Auth (Email + Google), and Storage enabled

### Clone & Install

```bash
git clone <YOUR_REPO_URL>
cd collabhub
flutter pub get
```

---

## Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com) and open the **collabhub-33a9d** project (or create your own).
2. Enable **Authentication** providers: Email/Password and Google Sign-In.
3. Enable **Cloud Firestore** (start in production mode, then apply security rules below).
4. Enable **Firebase Storage**.
5. Download `google-services.json` and place it at `android/app/google-services.json`.
6. Download `GoogleService-Info.plist` and place it at `ios/Runner/GoogleService-Info.plist`.
7. The file `lib/firebase_options.dart` is pre-configured — do **not** regenerate unless you change Firebase projects.

### Firestore Security Rules

Apply these rules in **Firestore → Rules**:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users: only the owner can write their own profile
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // Projects: any authenticated user can read/create;
    // only the author can update or delete
    match /projects/{projectId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null
        && request.auth.uid == resource.data.authorId;
    }
  }
}
```

### SHA-1 Fingerprint (Android)

Each developer must register their debug keystore SHA-1 in Firebase Console under **Project Settings → Your apps → Android app → Add fingerprint**:

```bash
keytool -list -v \
  -keystore ~/.android/debug.keystore \
  -alias androiddebugkey \
  -storepass android -keypass android \
  | grep SHA1
```

Add the output fingerprint in Firebase Console so `google-services.json` picks it up for Google Sign-In on your machine.

---

## API Key Security

The Android API key (`AIzaSy...`) in `google-services.json` **must be restricted** to prevent unauthorised use.

### Steps to restrict in Google Cloud Console

1. Go to [console.cloud.google.com](https://console.cloud.google.com) → select project **collabhub-33a9d**.
2. Navigate to **APIs & Services → Credentials**.
3. Click the API key in the list → **Edit API key**.
4. Under **Application restrictions**, select **Android apps**.
5. Click **Add an item** and enter:

   | Field | Value |
   |---|---|
   | Package name | `com.team11.collabhub` |
   | SHA-1 certificate fingerprint | *(your fingerprint from the step above)* |

6. Click **Save**. Changes propagate within a few minutes.

### For team development

Every team member must add **their own debug keystore SHA-1** to the restriction list. Failure to do so will cause Firebase calls to fail on their machine. Each member:

1. Runs the `keytool` command above to get their SHA-1.
2. Shares it with the project owner.
3. Owner adds it to the Cloud Console API key restriction (same package name, new fingerprint row).

### What the restriction protects

| Without restriction | With restriction |
|---|---|
| Any app or server can use the key | Only signed builds of `com.team11.collabhub` can use it |
| Quota exhaustion / billing risk | Requests from other origins are rejected by Google |
| Potential data scraping | Key exposure in version control is no longer critical |

> **Note:** The OAuth Client IDs (`*.apps.googleusercontent.com`) used for Google Sign-In are already scoped by type (Android / Web) and do not need additional restriction.

---

## Environment & Configuration

No `.env` file is needed. All configuration is embedded in:

| File | Purpose |
|---|---|
| `android/app/google-services.json` | Android Firebase + OAuth config |
| `ios/Runner/GoogleService-Info.plist` | iOS Firebase + OAuth config |
| `lib/firebase_options.dart` | Dart-side Firebase options (auto-selected per platform) |

**Do not commit real credentials to a public repository.** Add the following to `.gitignore` if you fork this project with your own Firebase project:

```
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
lib/firebase_options.dart
```

---

## Running the App

```bash
# Android (connected device or emulator)
flutter run -d android

# iOS (requires Xcode + provisioning)
flutter run -d ios

# macOS desktop
flutter run -d macos

# Chrome (web)
flutter run -d chrome
```

---

## Running Tests

```bash
flutter test
```

Tests are located in `test/widget_test.dart` and cover:

- `HomeBloc` — add, upvote, downvote, delete, toggle status, filter, sort
- `AuthBloc` — login, register, Google sign-in, profile update, logout
- Widget smoke test — app renders without crashing

---

## SharedPreferences

Three preferences are persisted locally via `PrefsService`:

| Key | Type | Default | Description |
|---|---|---|---|
| `dark_mode` | `bool` | `false` | Dark / light theme toggle |
| `status_filter` | `String` | `'all'` | Feed filter: `all`, `open`, or `closed` |
| `sort_by` | `String` | `'recent'` | Feed sort: `recent`, `upvoted`, or `downvoted` |

Preferences survive app restarts and are loaded at startup by `ThemeCubit` and `HomeBloc`.

---

## Contributing

1. Fork the repository and create a feature branch.
2. Run `flutter analyze` — must report **0 issues** before opening a PR.
3. Run `flutter test` — all tests must pass.
4. Register your SHA-1 (see [API Key Security](#api-key-security)) before testing on Android.
5. Open a pull request with a clear description of changes.

---

*CollabHub — Team 11 | Mobile Application Development*
