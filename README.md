# SWE 463: Mobile Application Development — Project Phase 2
# Souq (Student Marketplace App)

Souq is a dedicated marketplace application for KFUPM students to securely buy, sell, and organize used items (books, electronics, furniture) within the university community. It features real-time in-app messaging, verified student authentication, and quick IBAN copying to streamline campus transactions.

## Group 1 | Team Members

*   **Abdulwahab Badirah** (202160410)
*   **Abdulwahed Al Adi** (202256380)
*   **Ayman Musalli** (202270440)
*   **Hady Al Saleem** (202279620)

## Project Structure

This repository contains the Phase 2 starter Flutter project.

* `lib/main.dart`: app entry point.
* `lib/theme.dart`: app colors and styles (Material 3), taken from our Figma design.
* `lib/screens/`: one file per screen (Login, Home, Listing Detail, Post Listing, Messages, Profile). These files are still empty placeholders.
* `lib/widgets/`: shared widgets used by many screens (listing card, status badge, empty state).
* `test/`: widget tests (currently the default Flutter starter test).
* `web/`: files needed to run the app in a browser (icons, `index.html`, `manifest.json`).

## Links

* Figma design: https://www.figma.com/design/8lxB3Gc4IseCK7GgjLE7yf

## Packages

| Package | Why we use it | Added in |
|---|---|---|
| cupertino_icons | iOS style icons (comes with Flutter) | Phase 2 |
| provider | Share app data between screens | Phase 3 (planned) |
| go_router | Move between screens | Phase 3 (planned) |
| firebase_core, firebase_auth | Student sign up and login | Phase 3 (planned) |
| cloud_firestore | Save listings, chats and messages | Phase 3 (planned) |
| firebase_storage | Save listing photos | Phase 3 (planned) |
| image_picker | Pick photos for a listing | Phase 3 (planned) |

We will update this table whenever a package is added.

## AI Use Disclosure

AI use was allowed by the course instructor. We used an AI assistant for:

* Screen design: the team decided the screens, features and style (KFUPM colors, cart logo). AI helped turn these ideas into Figma screens and suggested layout and color improvements. The team reviewed every screen.
* Navigation diagram: AI helped draw the diagram from the flow the team defined.
* Report: AI helped write parts of the Phase 2 report.
* Code: AI helped write `lib/theme.dart` and the shared widgets in `lib/widgets/`.
* Spelling and grammar checks.

Every team member reviewed the AI-assisted work and can explain it.

## Getting Started

To run this starter project on your local machine:

1. Clone the repository:
   ```bash
   git clone https://github.com/Abdulwahed25/SWE-463_project.git
   ```
2. Get the packages:
   ```bash
   cd SWE-463_project
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```
