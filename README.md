# Planora

Planora is a modern iOS To-Do application built with SwiftUI and Firebase, focusing on simplicity and task management. It employs an MVVM architecture with Repository pattern for clean separation of concerns.

## Features
- **Authentication**: Register and login securely using Firebase Auth.
- **Dashboard**: View completion statistics, today's tasks, weekly overview, and overdue items.
- **Calendar**: Select a date to view tasks due on that specific day.
- **Tasks Management**: Create, read, update, and delete tasks with priorities, due dates, and statuses. Features search and filtering.
- **Profile**: Manage your account and sign out.

## Tech Stack
- **Platform**: iOS 15.0+
- **Language**: Swift 5.9
- **Framework**: SwiftUI 3
- **Architecture**: MVVM + Repository
- **Database / Auth**: Firebase (Firestore & Firebase Auth via Swift Package Manager)
- **Concurrency**: `async/await`, `@MainActor`

## Requirements
- Xcode 15.0
- macOS Ventura 13.6.1 (or higher, compatible with Xcode 15)
- iOS 15.0 Simulator or Device

## Setup Instructions
1. Clone the repository.
2. Open `Planora.xcodeproj` in Xcode 15.
3. Add your `GoogleService-Info.plist` to the project root for Firebase configuration.
4. Ensure Swift Package Manager resolves the `firebase-ios-sdk` dependencies.
5. Select an iOS 15+ simulator and build the project (Cmd + R).

## Architecture Notes
- The project intentionally avoids iOS 16/17 specific APIs (like `@Observable` or `NavigationStack`) to maintain compatibility with iOS 15.
- Manual Firestore serialization is used over `FirebaseFirestoreSwift` for explicit and safe data handling.
