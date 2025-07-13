# Flutter Notes App

A modern, cross-platform notes app built with Flutter, Firebase Authentication, and Firestore. Features clean architecture, BLoC state management, and a polished UI.

---

## Features
- **Sign up, log in, log out** with email/password (Firebase Auth)
- **Input validation** and clear error messages
- **CRUD operations** for notes (Firestore)
- **Real-time sync** and offline support
- **BLoC state management** (no global setState)
- **Clean architecture**: presentation, domain, data layers
- **Modern UI**: Card/ListTile, FAB, dialogs, responsive, no pixel overflows
- **Theme toggle**: Light, dark, and system
- **Profile editing**: Display name, password
- **Search/filter notes**
- **Snackbar feedback** for all actions

---

## Build & Run Steps

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Firebase project (see below)

### 1. Clone the repository
```sh
git clone https://github.com/idarapatrick/Flutter-Notes-App.git
cd notes_app
```

### 2. Install dependencies
```sh
flutter pub get
```

### 3. Set up Firebase
- Register your app for **Android**, **iOS**, and **Web** in the [Firebase Console](https://console.firebase.google.com/)
- Download the config files:
  - `google-services.json` (Android: `android/app/`)
  - `GoogleService-Info.plist` (iOS: `ios/Runner/`)
  - Add web config to `web/index.html` as instructed
- Enable **Authentication** (Email/Password) and **Firestore** in Firebase

### 4. Run the app
- **Android:**
  ```sh
  flutter run -d android
  ```
- **iOS:**
  ```sh
  flutter run -d ios
  ```
- **Web:**
  ```sh
  flutter run -d chrome
  ```

---

## Architecture Diagram

```
flowchart TD
    A[main.dart] -->|Initializes| B[Firebase]
    A --> C[Repository Providers]
    C --> D[AuthRepositoryImpl]
    C --> E[NoteRepositoryImpl]
    A --> F[Bloc Providers]
    F --> G[AuthBloc]
    F --> H[NotesBloc]
    F --> I[ThemeCubit]
    A --> J[MaterialApp]
    J --> K[SplashScreen]
    J --> L[LoginScreen]
    J --> M[SignupScreen]
    J --> N[HomeScreen]
    J --> O[ProfileScreen]
    N --> P[NotesListScreen]
    P --> Q[Dialogs: Add/Edit/Delete]
    G -->|Auth Events/States| L
    G -->|Auth Events/States| M
    G -->|Auth Events/States| N
    H -->|Notes Events/States| P
    D -->|CRUD| R[Firestore]
    E -->|CRUD| R
    subgraph Data Layer
      D
      E
    end
    subgraph Domain Layer
      G
      H
      I
    end
    subgraph Presentation Layer
      J
      K
      L
      M
      N
      O
      P
      Q
    end
```

---

## State Management: BLoC Pattern
- **BLoC (Business Logic Component)** separates business logic from UI.
- **Events** are dispatched from the UI (e.g., `AddNote`, `LoginRequested`).
- **Blocs** process events, interact with repositories, and emit **states** (e.g., `NotesLoaded`, `AuthError`).
- **UI** listens to state changes and rebuilds accordingly.
- **No global setState**; all app state is managed by BLoC/Cubit.

---

## Folder Structure
```
lib/
  core/           # Shared utilities, constants
  data/           # Firebase/data sources, models, repository implementations
  domain/         # Entities, repository interfaces
  presentation/   # UI, screens, widgets, blocs/cubits
```

---

## Security & Best Practices
- Sensitive files (Firebase configs, .env) are **.gitignore**'d
- Input validation and error handling throughout
- No print/debug statements in production

