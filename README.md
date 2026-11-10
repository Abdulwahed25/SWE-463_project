# SWE 463: Mobile Application Development — Project
# Souq (Student Marketplace App)

Souq is a marketplace app for KFUPM students to buy and sell used items (books, electronics, furniture and more) inside the university community. Students post listings, browse and filter them, message sellers, and copy the seller's IBAN for a quick bank transfer.

## Group 1 | Team Members

* **Abdulwahab Badirah** (202160410)
* **Abdulwahed Al Adi** (202256380)
* **Ayman Musalli** (202270440)
* **Hady Al Saleem** (202279620)

## Links

* GitHub repository: https://github.com/Abdulwahed25/SWE-463_project
* Figma design: https://www.figma.com/design/8lxB3Gc4IseCK7GgjLE7yf

## How to Run

1. Install Flutter (stable channel) and Chrome or an emulator.
2. Clone the repository:
   ```bash
   git clone https://github.com/Abdulwahed25/SWE-463_project.git
   cd SWE-463_project
   ```
3. Get the packages:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run -d chrome
   ```
5. Run the tests and the analyzer:
   ```bash
   flutter test
   flutter analyze
   ```

No account, key or password is needed. The first time the app opens it adds 6 sample listings.

## Phase 3 Features

| Feature | Status | Where |
|---|---|---|
| Post a listing (form with validation, posting state, success screen) | Implemented | Post tab |
| Browse, search and filter listings (category, max price, available only) | Implemented | Home |
| Listing status: available or sold (badge, Mark as sold, My Listings tabs) | Implemented | Listing Detail, My Listings |
| Favorites (save with the heart, "Saved" filter) | Implemented (optional feature) | Home, Listing Detail |
| User accounts and profiles (KFUPM email validation, local storage session) | Implemented | Login, Sign Up, Profile |
| Profile (account details, Posted / Sold / Saved stats, IBAN reminder) | Implemented | Profile |
| Edit profile (country code picker, phone and IBAN formatted while typing and validated, unsaved-changes warning) | Implemented | Edit Profile, Sign Up (phone) |
| IBAN quick-transfer helper (seller's IBAN sheet on a listing, copy IBAN) | Implemented | Edit Profile, Profile, Listing Detail |
| In-app messaging | In progress | Messages, Chat |

### How to test the main flow

1. Open the app and press **Log in** to reach Home.
2. Press **Post** in the bottom bar.
3. Press **Post listing** with the form empty: each required field shows a red error.
4. Fill in the form and press **Post listing**. The button shows "Posting...", then the success screen opens.
5. Press **Back to Home**: the new listing is first in the list. Close and open the app again: it is still there (saved on the device).
6. Open the listing and press **Mark as sold**: the badge changes to Sold on Home and in My Listings.

### How to test the profile flow

1. Log in with the demo account: `student@kfupm.edu.sa` / `password123`, then open the **Profile** tab.
2. The card shows Posted / Sold / Saved counts. Post a listing or save one with the heart: the counts change right away.
3. Press **Edit Profile & IBAN**. **Save changes** stays disabled until you change a field.
4. Try typing letters in the phone or IBAN field: they are ignored. Digits are grouped while you type (phone `53-034-4226`, IBAN `03 8000 0000 6080 1016 7519` after the fixed `SA`).
5. Clear the name, type `534` as the phone and `12` as the IBAN, then press **Save changes**: each field shows a red error and nothing is saved. An IBAN with a wrong digit (for example `03 8000 0000 6080 1016 7518`) is also rejected (checksum check).
6. Tap **+966** to pick another country code (e.g. Kuwait +965): the phone rules and grouping change to that country.
7. Change something and press the back arrow: a "Discard changes?" dialog appears.
8. Enter a valid name and IBAN (e.g. `03 8000 0000 6080 1016 7519`) and save. The button shows a spinner, then Profile shows the new name and the IBAN in groups of 4, with a copy button. Restart the app: the changes are still there.
9. To test buying with IBAN: sign up a second account, add an IBAN and post a listing. Log in with the first account, open that listing and press **Copy IBAN**: a sheet shows the seller's name and IBAN. Sample listings show "No IBAN yet" because their sellers have no accounts.

## Project Structure

```
lib/
  main.dart                 app entry, providers and MaterialApp
  app_routes.dart           route names and screens
  theme.dart                Material 3 theme (Souq colors)
  models/                   Listing, categories and conditions
  providers/                ListingsProvider (shared state with Provider)
  services/                 ListingRepository (interface) and LocalListingRepository
  screens/                  one file per screen
  widgets/                  reusable widgets (listing card, status badge, empty state, section card, seller payment sheet)
  utils/                    price and time formatting, IBAN helpers, profile validators
test/                       provider tests and a widget test
```

## State Management and Data

* **Provider** (ChangeNotifier) for shared state. `ListingsProvider` holds the listings, search, filters, favorites, and the loading and error states.
* **setState** for state that belongs to one screen (form fields, the posting flag, the selected tab).
* **Data source (temporary):** `LocalListingRepository` saves listings and favorites on the device with `shared_preferences`. Screens only use the `ListingRepository` interface, so Firebase (Firestore) can replace it in Phase 4 without changing the screens.
* `lib/services/session.dart` is a temporary current user until login is connected.

## Packages

| Package | Why we use it | License |
|---|---|---|
| cupertino_icons | iOS style icons (comes with Flutter) | MIT |
| provider | Share app state between screens | MIT |
| shared_preferences | Save listings and favorites on the device | BSD-3-Clause |

Planned for Phase 4: firebase_core, firebase_auth, cloud_firestore, firebase_storage, image_picker.

## Known Issues

* Data is saved only on the device. Other users cannot see your listings until Firebase is added in Phase 4.
* Photos cannot be added yet (the photo box shows a message).
* Chat is still in progress.
* Changing your name does not update the seller name on listings you posted before the change.
* The seller's IBAN can only be found if the seller's account is on the same device (local storage). Firestore will fix this in Phase 4.

## AI Use Disclosure

AI use was allowed by the course instructor. We used an AI assistant for:

* Screen design: the team decided the screens, features and style (KFUPM colors, cart logo). AI helped turn these ideas into Figma screens and suggested layout and color improvements. The team reviewed every screen.
* Navigation diagram: AI helped draw the diagram from the flow the team defined.
* Reports: AI helped write parts of the Phase 2 and Phase 3 reports.
* Code: AI helped write `lib/theme.dart`, the shared widgets, and the Phase 3 listings feature (model, repository, provider, Home, Filter, Post Listing, Listing Detail, My Listings, favorites and tests). Commits made with AI help include a "Co-Authored-By: Claude" line.
* Spelling and grammar checks.

Every team member reviewed the AI-assisted work and can explain the code they are responsible for.
