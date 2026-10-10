# PixaMart 🎨

PixaMart is a feature-rich, high-performance wallpaper application built with **Flutter**. It provides users with access to a vast library of high-quality wallpapers from seven sources: **Pexels, Unsplash, Pixabay, Wallhaven, Openverse, NASA Image Library and Bing Daily**. The app offers a seamless user experience with smooth animations, offline capabilities, and cloud synchronization.

## 📱 Features

*   **Multiple Wallpaper Sources**: Switch between Pexels, Unsplash, Pixabay, Wallhaven (SFW only), Openverse, NASA and Bing Daily with the source picker on the home screen. Photographer/licence credit is shown on each image.
*   **Categories**: Explore wallpapers organized into various categories for easy discovery.
*   **Search Functionality**: Quickly find specific wallpapers using keywords.
*   **User Authentication**: Secure login and signup using **Firebase Auth** (including Google Sign-In).
*   **Cloud Synchronization**: Sync your **Favourites** and **Downloads** across multiple devices using **Firebase Realtime Database** and **Firestore**.
*   **Wallpaper Management**:
    *   Set images as Home Screen, Lock Screen, or Both directly from the app.
    *   Download images to your device gallery.
*   **Favourites**: Save your preferred wallpapers to a dedicated list for quick access.
*   **Sharing**: Share a link to the wallpaper's source page with the system share sheet.
*   **Offline Support**: Uses **Hive** for local storage to cache favourites and downloads for offline access.
*   **Optimized Performance**: Implements advanced caching strategies with `flutter_cache_manager` and `cached_network_image` to save data and load images instantly.
*   **Beautiful UI/UX**:
    *   Dark-themed, immersive interface.
    *   Smooth animations using **Lottie** and **Rive**.
    *   Custom page transitions and liquid progress indicators.
*   **In-App Updates**: Automatically checks for new app versions via Firestore and prompts the user to update.

## 🛠 Tech Stack

### Frontend
*   **Framework**: [Flutter](https://flutter.dev/) (Dart)
*   **State Management**: [GetX](https://pub.dev/packages/get) for reactive state management and navigation.
*   **UI Components**:
    *   `lottie` & `rive` for animations.
    *   `curved_navigation_bar` for the bottom nav.
    *   `flutter_speed_dial` for floating action buttons.
    *   `liquid_progress_indicator_ns` for loading states.

### Backend & Services
*   **Firebase**:
    *   **Authentication**: User management.
    *   **Firestore**: Storing user data (downloads history, app versioning).
    *   **Realtime Database**: Real-time syncing of favourites.
*   **APIs**: [Pexels](https://www.pexels.com/api/), [Unsplash](https://unsplash.com/developers), [Pixabay](https://pixabay.com/api/docs/), [Wallhaven](https://wallhaven.cc/help/api), [Openverse](https://api.openverse.org/v1/), [NASA Image Library](https://images.nasa.gov/docs/images.nasa.gov_api_docs.pdf) and Bing's daily image archive (unofficial, best-effort).

### Data & Networking
*   **Local Storage**: [Hive](https://docs.hivedb.dev/) (NoSQL database) for fast local data persistence.
*   **Networking**: `http` and `dio` for API requests.
*   **Caching**: `flutter_cache_manager` and `cached_network_image`.

## 📂 Project Structure

The project is organized into a clean and scalable structure:

```
lib/
├── backend/
│   ├── functions/       # Utility functions (e.g., sharing, animations)
│   └── model/           # Data models (Auth, Categories, Wallpaper, Favourites)
├── front_end/
│   ├── pages/           # Application screens (Home, ImageView, Account, etc.)
│   └── widget/          # Reusable UI components
├── private/             # API keys and sensitive configuration
├── routing/             # Route generation and navigation logic
├── firebase_options.dart # Firebase configuration
└── main.dart            # Application entry point
```

## 🚀 Getting Started

### Prerequisites
*   Flutter SDK 3.22+ (Dart 3.4+)
*   Dart SDK
*   Android Studio / VS Code
*   (Optional) Pexels, Unsplash and Pixabay API keys
*   A Firebase Project

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/UpayanGhosh/pixamart.git
    cd pixamart
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Setup Firebase:**
    *   Create a project in the [Firebase Console](https://console.firebase.google.com/).
    *   Add Android and iOS apps to your Firebase project.
    *   Download `google-services.json` (for Android) and place it in `android/app/`.
    *   Download `GoogleService-Info.plist` (for iOS) and place it in `ios/Runner/`.

4.  **Configure API Keys (optional):**
    Keys are injected at build time and never committed. Copy the example file and fill in any keys you have:
    ```bash
    cp api_keys.example.json api_keys.json   # api_keys.json is git-ignored
    ```
    Sources whose key is empty are hidden automatically. Wallhaven, Openverse, NASA and Bing need no key.

5.  **Run the App:**
    ```bash
    flutter run --dart-define-from-file=api_keys.json
    ```

6.  **Build an APK:**
    ```bash
    flutter build apk --release --dart-define-from-file=api_keys.json
    ```
    Without `android/key.properties` the release APK is signed with the debug key (fine for sideloading, not for the Play Store).
    To sign properly, create `android/key.properties` with `storeFile`, `storePassword`, `keyAlias` and `keyPassword`.

### Firebase security rules
`firestore.rules` and `database.rules.json` restrict each user to their own favourites/downloads. Deploy them with `firebase deploy --only firestore:rules,database`.

## 🤝 Contributing

Contributions are welcome! If you find any bugs or want to add new features, please open an issue or submit a pull request.

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
