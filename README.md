# chatapp


A real-time chat application built with Flutter and Firebase, supporting text and image messages, user authentication, and live updates.

## System Overview

This system integrates Firebase Authentication, Firestore, and Riverpod for managing user accounts, authentication states, and profile data efficiently across the app.

## AuthModel (auth_model.dart)

**Purpose:**  
Defines the structure of a user record in Firestore and provides conversion methods between Firestore and Dart objects.

**Key Features:**
- **Constructor:** Manually creates a new AuthModel.
- **Factory Constructor (fromFirestore):** Converts Firestore documents to AuthModel instances, handling timestamps and default values.
- **toMap():** Converts Dart objects into Firestore-compatible maps.
- **copyWith():** Creates modified copies without changing the original object.

## AuthFormState

**Purpose:**  
Manages state for authentication forms (login/signup).

**Responsibilities:**
- Tracks name, email, and password fields.
- Manages validation errors and password visibility.
- Controls loading spinner during submission.
- Includes isFormValid getter for form submission validation.

## Authentication Screens

### login_screen.dart

**Purpose:** Handles user login through Firebase Authentication.

**Implementation Details:**
- Built as a ConsumerWidget to use Riverpod providers.
- Uses formState and formNotifier for real-time UI updates.
- Interacts with AuthMethod for Firebase sign-in.

**Login Workflow:**
1. Show loading spinner.
2. Call loginUser() via AuthMethod.
3. Hide spinner upon completion.

**UI Elements:**
- Scaffold layout with header image.
- Input fields for email and password with validation.
- Login button disabled until form is valid.
- Redirect link to signup screen.

### signup_screen.dart

**Purpose:** Handles user registration.

**Implementation Details:**
- Also built as a ConsumerWidget.
- Uses AuthFormState for field management.

**Signup Workflow:**
1. Show loading indicator.
2. Call signUpUser() from AuthMethod.
3. Redirect to login after success.

**UI Elements:**
- Banner image on top.
- Fields for name, email, password.
- Signup button with loading indicator.

## Providers and Authentication Logic

### auth_provider.dart

**authStateProvider:**
- Listens to Firebase authentication changes.
- Updates UI automatically based on auth status.

**authFormProvider:**
- Manages login/signup form state.

**AuthFormNotifier Functions:**
- `togglePasswordVisibility()`
- `updateName()`, `updateEmail()`, `updatePassword()`
- `setLoading(bool)`

### auth_method.dart

**Purpose:** Centralizes all Firebase Authentication logic.

**Dependencies:** firebase_auth, cloud_firestore, flutter_riverpod

**Workflows:**

**signUpUser():**
- Validates input.
- Creates user in Firebase Auth.
- Saves data in Firestore.

**loginUser():**
- Authenticates user.
- Sets isOnline = true and updates lastSeen timestamp.

**signOut():**
- Marks user as offline and updates lastSeen time.
- Signs out from Firebase.

## Chat System Providers (chat_provider.dart)

- **chatServiceProvider:** Provides ChatService globally.
- **usersProvider:** Streams Firestore users in real time.
- **requestsProvider:** Manages chat/friend requests.
- **autoRefreshProvider:** Refreshes related providers when auth status changes.

## User List Logic (user_list_provider.dart)

**UserListNotifier:** Handles creation and initialization of chat rooms.

**Chat Document Fields:** chatId, participants, lastMessage, lastMessageTime, unreadCount, createdAt

**userListProvider:** Manages UI updates for each user tile efficiently.

## Profile Management (profile_provider.dart)

**ProfileNotifier:**
- Manages loading, updating, and syncing user profile data.
- Listens to FirebaseAuth state and updates in Firestore.

**Features:**
- Allows photo updating via Firebase Storage.
- Reflects real-time updates in app.

**profileProvider:** Exposes profile operations globally.

## User Online Status (user_status_provider.dart)

**userStatusProvider (StreamProvider.family):**
- Monitors user online/offline state live.
- Useful for showing online indicators and last seen timestamps.

## Chat Screen (chat_screen.dart)

**Purpose:** One-to-one real-time chat with text, image, and location features.

**Main Functions:**
- Streams chat messages live from Firestore.
- Typing indicator visible when user types.
- Read receipts update in real-time.
- Shows status (Online, Typing, Last Seen) in app bar.

**Media Features:**
- Uploads images via Firebase Storage.
- Shares clickable location links via Geolocator.

**UI Components:**
- Profile info in AppBar.
- Reversed ListView for message display.
- Input bar with text, image, and location buttons.

**State Management:**
- Relies on chatServiceProvider, userStatusProvider, and authStateProvider to sync data.

## Main Screens Overview

### MainHomeScreen.dart

Acts as the navigation hub with bottom navigation bar:

**Chats | Users | Profile**

### ChatListScreen.dart

Displays all active chats in real time using Firestore snapshots.  
Supports delete, rename, and navigation to ChatDetailScreen.

### ChatDetailScreen

Handles live one-on-one messages using Firestore streams.

### UserListScreen.dart

Shows registered users, with search and pull-to-refresh.

### ProfileScreen.dart

Displays user profile details.  
Allows profile image update and logout functionality.

## ChatService Overview

**Purpose:** Manages chat interactions and synchronization using Firebase Authentication, Firestore, and Storage.

**Features:**
- **Users:** Streams all users except current.
- **Message Requests:** Manages friend/chats requests.
- **Messages:** Handles text/image messages, uploads, and read status.
- **Typing Indicator:** Tracks and auto-resets typing states.

## Utils Overview

### TimeFormat
- `formatMessageTime()`: HH:mm format
- `formatTime()`: Returns relative time like "2h" or "5m"

### Snackbar
- Displays toast messages using CherryToast.
- Supports success and error message types.

## Chat Module Widgets

- **ThreeDots:** Animated typing indicator.
- **MessageAndImageDisplay:** Handles message rendering with timestamps.
- **BuildMessageStatusIcon:** Displays message delivery/read status.
- **UserChatProfile:** Shows name, online status, and typing animation.
- **UserListTile:** Displays users with online indicator and quick chat option.

## Wrapper State and Session Management

### AppStateManager
- Tracks user session and lifecycle.
- Updates user presence online/offline automatically.
- Initializes Firestore user document if missing.

### AuthenticationWrapper
- Waits for initialization before showing main screen.
- Displays loading progress indicator with timeout.

### MainHomeScreen
- Central screen post-login for all chat operations.

## AuthFormState Class

**Purpose:** Manages authentication form state.

**Properties:** name, email, password, errors, isLoading, isPasswordHidden

**Methods:**
- `isFormValid`: Returns true if inputs valid.
- `copyWith`: Updates selective fields immutably.

**Usage:**
- Shared by login/signup forms to handle state and visuals.

## DefaultFirebaseOptions

**Purpose:** Provides Firebase configuration for available platforms.

**Platforms:**
- Web and Android configured
- iOS, macOS, Windows, Linux throw errors if accessed

**Properties:** currentPlatform, web, android

**Usage:** currentPlatform selects Firebase config automatically.

## LocationHelper

**Purpose:** Manages device location services for chat/location features.

**Methods:**
- `currentPosition()`: Gets device location with permissions.
- `getLocationUrl()`: Generates a Google Maps link.
- `getLocationData()`: Returns latitude, longitude, and map link.

**Usage:** Simplifies fetching and sharing current location.

## Main.dart

**Purpose:** Main entry point of the Flutter app.

**Initialization:**
- Sets Firebase and Riverpod.
- Configures platform options.

**Auth Flow States:**
1. **Loading:** progress indicator
2. **Authenticated:** loads AuthenticationWrapper
3. **Unauthenticated:** shows Login Screen
4. **Error:** displays retry option

**Dependencies:** firebase_core, riverpod, auth modules

**Usage:** Automatically routes based on Firebase user state.

## Route.dart

**Purpose:** Simplifies screen navigation operations.

**Methods:**
- `push(context, screen)`: Navigates to a new screen (stacked).
- `pushReplacement(context, screen)`: Replaces current screen.

**Usage:** Provides centralized navigation without direct Navigator calls.

## Android build.gradle

**Configuration:**
- Application ID: com.example.chatapp
- Compile SDK: 36
- Min SDK: 21
- Target SDK: 34

**Reasons for SDK 36:**
- Required for newer Firebase and Google Play services.
- Compatibility with Google Services plugin 4.4.4.
- Supports latest Flutter Firebase plugins.

**Build Settings:**
- Java 11
- Kotlin JVM target 11

**Plugins:**
- Android application
- Kotlin Android
- Flutter Gradle Plugin
- Google Services

**Note:** Update signing configuration for production releases.

## google-services.json

**Purpose:** Firebase configuration for Android integration.

**Source:** Generated by Firebase Console.

**Contents:**
- Project ID: chatapp-58ec3
- Storage Bucket: chatapp-58ec3.firebasestorage.app
- App ID and API Key configurations.

**Location:** android/app/ directory.

**Usage:** Enables Firebase Authentication, Firestore, and Storage integration automatically.

## Dependencies Overview

### Backend & Authentication
- **firebase_core:** Initializes and connects the Flutter app to Firebase services.
- **firebase_auth:** Manages user sign-up, sign-in, and session management.
- **google_sign_in:** Enables sign-in using Google accounts.
- **cloud_firestore:** Provides a flexible, scalable NoSQL cloud database for storing chat messages and user data in real-time.
- **firebase_storage:** Stores and manages user-uploaded files, such as profile pictures and chat images.

### Real-time Communication
- **zego_uikit_prebuilt_call:** A high-level toolkit to quickly implement ready-to-use audio and video calling features.
- **zego_uikit_signaling_plugin:** Handles call signaling (invitations, status updates) for the Zego call system.
- **zego_uikit:** The core ZegoCloud UI Kit for building custom calling features.

### Mapping & Location Services
- **maps_flutter:** Integrates Google Maps into the application for displaying location data.
- **geolocator:** Provides easy access to platform-specific location services (GPS, Wi-Fi, etc.).
- **location:** Used for managing user location and background location services.
- **flutter_polyline_points:** Decodes map polylines (routes) into coordinates for display on a map.
- **flutter_svg:** Renders Scalable Vector Graphics (SVG) files.

### State Management & Utilities
- **flutter_riverpod:** A popular state management library for managing application state.
- **intl:** Provides internationalization and localization features, particularly for date/time formatting.
- **uuid:** Generates universally unique identifiers (UUIDs) for messages or chat rooms.
- **permission_handler:** A utility for checking and requesting various permissions (camera, location, etc.).

### UI & Media
- **image_picker:** Allows users to select images from the device gallery or take new pictures.
- **cherry_toast:** Provides customizable toast/notification messages for displaying alerts or feedback.
- **google_mobile_ads:** Integrates Google AdMob into the application to display advertisements.
- **cupertino_icons:** Provides Apple-style icons for iOS-specific UI elements.

<img width="244" height="427" alt="Screenshot 2025-10-26 174623" src="https://github.com/user-attachments/assets/b268c502-e976-4ce8-8a48-de4532222133" />
<img width="240" height="431" alt="Screenshot 2025-10-26 174700" src="https://github.com/user-attachments/assets/ab9a84ff-598c-4f7a-8e46-6e42e2401911" />


