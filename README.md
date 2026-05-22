# SabancıInsight

**SabancıInsight** is a Flutter mobile application for Sabancı University students to browse course reviews, share feedback, verify enrollment via transcript upload, and view AI-generated summaries of peer reviews. The app uses Firebase for authentication and cloud data storage, and **Provider** for state management.

---

## Motivation and Purpose

Choosing courses at university is often based on limited or scattered information. SabancıInsight centralizes student course feedback in one place so students can make more informed academic decisions. The app restricts access to `@sabanciuniv.edu` accounts, requires transcript-based enrollment verification before submitting reviews for a course, and uses Google Gemini to summarize review sentiment for each course page.

---

## Main Features and Functionalities

- **Authentication**
  - Register and log in with a Sabancı University email (`@sabanciuniv.edu`)
  - Form validation for email domain and password length
  - Forgot-password flow via Firebase Authentication

- **Home and navigation**
  - Personalized greeting on the home screen
  - Quick access to **Courses** and **My Reviews**
  - Bottom navigation between home and profile

- **Course reviews**
  - Browse courses loaded from the shared Firestore `courses` collection
  - Search courses by code or title
  - View course-specific reviews, star ratings, and average rating (from the `feedbacks` collection)
  - Add a new review (rating + text) after enrollment verification

- **Enrollment verification**
  - Upload a PDF transcript to extract course codes
  - Verify enrollment for a specific course before posting a review
  - Reuse a previously uploaded transcript when applicable
  - View and manage uploaded transcript data from the profile screen

- **AI course insights**
  - Gemini-powered Turkish summary of student reviews on each course detail page

- **Profile and settings**
  - Profile screen with transcript management entry point
  - Dark mode toggle (persisted with `shared_preferences`)
  - Logout, delete account, delete uploaded transcript data
  - Contact support dialog

- **State management**
  - `AuthProvider`, `FeedbackProvider`, and `ThemeProvider` using the **Provider** package

---

## Technologies and Packages Used

| Category | Technology / Package |
|---|---|
| Framework | Flutter (Dart SDK ^3.11.1) |
| State management | `provider` |
| Backend | Firebase (`firebase_core`, `firebase_auth`, `cloud_firestore`) |
| AI | `google_generative_ai` (Gemini 2.5 Flash) |
| PDF parsing | `syncfusion_flutter_pdf` |
| File upload | `file_picker` |
| Local preferences | `shared_preferences` |
| HTTP | `http` |
| Testing | `flutter_test` |

---

## Flutter Version Requirements

This project was developed and tested with:

- **Flutter:** 3.41.x (stable channel recommended)
- **Dart:** 3.11.x (as specified in `pubspec.yaml`: `sdk: ^3.11.1`)

Before running the project, verify your environment:

```bash
flutter --version
flutter doctor
```

Use a recent stable Flutter SDK compatible with Dart 3.11+.

---

## Firebase Setup and Configuration

The app connects to the Firebase project `sabanciinsight`.

### 1. Firebase services enabled

Ensure the following are enabled in the [Firebase Console](https://console.firebase.google.com/):

- **Authentication** → Email/Password sign-in method
- **Cloud Firestore** → Database created (production or test mode as appropriate for your environment)

### 2. Project configuration files

The repository already includes:

- `lib/firebase_options.dart` — generated Firebase options (Android, Web, Windows)
- `android/app/google-services.json` — Android Firebase config
- `.firebaserc` — Firebase CLI project mapping (`sabanciinsight`)
- `firestore.rules` — security rules for `feedbacks` and `enrollment_verifications`

### 3. Firestore security rules

Deploy the rules from `firestore.rules` to your Firebase project:

- **Firebase Console:** Build → Firestore Database → Rules → paste contents of `firestore.rules` → Publish
- **Or with Firebase CLI:**

```bash
firebase deploy --only firestore:rules
```

### 4. Reconfiguring Firebase (optional)

If you clone the repo into a new Firebase project, regenerate configuration with FlutterFire CLI:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Then replace/update `firebase_options.dart` and platform-specific config files as needed.

### 5. Google Gemini API (AI summaries)

Course insight summaries use the Gemini API in `lib/services/ai_service.dart`. For grading or production use, replace the API key with your own key from [Google AI Studio](https://aistudio.google.com/) and avoid committing secrets to a public repository.

---

## Installation and Running the Application

### Prerequisites

- Flutter SDK (stable, 3.41.x recommended)
- Android Studio / VS Code with Flutter extensions
- An emulator or physical device (Android is the primary tested platform)
- Internet connection (Firebase and AI features require network access)

### Steps

**1. Clone the repository**

```bash
git clone https://github.com/cadis230/SabanciInsight.git
cd SabanciInsight
```

**2. Install dependencies**

```bash
flutter pub get
```

**3. Firebase configuration**

- Confirm `lib/firebase_options.dart` and `android/app/google-services.json` are present.
- Ensure Email/Password auth and Firestore are enabled in Firebase Console.
- Publish `firestore.rules` as described above.

**4. Run the application**

```bash
flutter run
```

For a specific device:

```bash
flutter devices
flutter run -d <device_id>
```

> **Note:** `firebase_options.dart` is configured for **Android**, **Web**, and **Windows**. iOS, macOS, and Linux are not fully configured in the current `firebase_options.dart`; use Android or Windows for the most reliable demo experience.

---

## Testing

Testing was implemented as part of the final project requirements. The project includes both unit tests and widget tests to verify important application behavior.

### Unit Tests

Unit tests were added to test core logic independently from the user interface.

- **`auth_validators_test.dart`** tests authentication validation logic, including:
  - Valid Sabancı University email validation
  - Invalid non-Sabancı email validation
  - Empty email validation
  - Password length validation

- **`transcript_course_extractor_test.dart`** tests transcript course extraction logic, including:
  - Extracting course codes from plain text
  - Normalizing course codes regardless of spacing and capitalization
  - Avoiding duplicate course codes
  - Extracting course codes from text-based PDF files
  - Handling invalid PDF input

### Widget Tests

Widget tests were added to verify important UI behavior.

- **`auth_screens_test.dart`** tests authentication screen behavior, including:
  - Showing an error when the login email field is empty
  - Showing an error when a non-Sabancı email is entered
  - Showing an error when the password is shorter than 6 characters
  - Disabling the forgot password button for invalid emails
  - Enabling the forgot password button for valid Sabancı University emails

- **`settings_test.dart`** tests the settings screen rendering, including:
  - Displaying the main settings title
  - Displaying dark mode, logout, delete account, delete transcript, and contact options

### Running Tests

All tests can be run with the following command:

```bash
flutter test
```

---

## Known Limitations, Assumptions, and Unresolved Issues

- **Platform support:** Firebase is fully wired for Android, Web, and Windows. iOS, macOS, and Linux builds require additional FlutterFire configuration.
- **Course catalog:** Courses shown in the app come from the Firestore `courses` collection and from course codes extracted from transcripts; this is not an official Sabancı University course API.
- **Transcript PDF parsing:** Extraction works best on text-based PDF transcripts; scanned/image-only PDFs may fail or return incomplete course codes.
- **Enrollment verification:** Verification is based on course codes found in the uploaded transcript, not on direct integration with university registration systems.
- **AI summaries:** Gemini responses depend on network availability and API quotas; summaries are generated in Turkish and may vary in quality with few reviews.

---


## Group Members

- Ece Özdemir — 32030
- Yağız Efe İmrek — 33846
- Ayşe Çamlı — 34456
- Azra Arslan — 32621
- Sıla Çalman — 32412
- Arda Kanalıcı — 34411

---
