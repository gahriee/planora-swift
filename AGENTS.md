# Planora - AI Agent Instructions

This document provides guidelines and context for AI coding assistants working on the **Planora** iOS application.

## ⚠️ Critical Constraints
- **Platform:** iOS 15.0 Minimum
- **Language:** Swift 5.9
- **IDE:** Xcode 15.0
- **macOS:** Ventura 13.6.1 (Build Machine)
- **Do NOT Use:** 
  - `@Observable` macro (iOS 17+)
  - `SwiftData` (iOS 17+)
  - `NavigationStack` (iOS 16+)
  - `FirebaseFirestoreSwift` `@DocumentID`
  - Any API marked `@available(iOS 16, *)` or higher without an `#available` guard.

## Architecture
- **Pattern:** MVVM + Repository Pattern.
- **State Management:** `ObservableObject` + `@Published` + `@StateObject` + `@EnvironmentObject`.
- **Navigation:** `NavigationView` (iOS 15).
- **Concurrency:** `async/await`, `Task`, `@MainActor`.
- **Firebase:** Manual Firestore serialization (do NOT use `FirebaseFirestoreSwift`).

## Code Style
- Ensure UI components are modular and adhere to the project's styling.
- Keep ViewModels decoupled from Firebase using Protocols.
- All ViewModels should be marked with `@MainActor`.
