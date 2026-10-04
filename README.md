<div align="center">

# ⚡ Pokédex — Catch. Explore. Favorite.

### A Flutter Pokédex built from the supplied Figma design and powered by live PokéAPI data.

<br>

<img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
<img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
<img src="https://img.shields.io/badge/Riverpod-State%20Management-7C4DFF?style=for-the-badge" alt="Riverpod">
<img src="https://img.shields.io/badge/SharedPreferences-Local%20Storage-6D4C41?style=for-the-badge" alt="SharedPreferences">
<img src="https://img.shields.io/badge/API-Pok%C3%A9API-EF5350?style=for-the-badge" alt="PokéAPI">

<br><br>

**Search • Filter • Sort • Paginate • Inspect • Favorite • Persist**

</div>

---

## 🎯 What is this?

This project is a Flutter implementation of the **Pokédex / Pokémon App** Figma design provided for the take-home assignment.

The app consumes **live data from the public PokéAPI** and focuses on the core requirements of the task:

- a Pokémon list
- infinite pagination
- search
- type filtering
- sorting
- detailed Pokémon information
- locally persisted favorites
- real-time favorite synchronization across screens

> ### 💡 The idea
> **The UI feels like a Pokédex, but the data and favorite state are real.**

The implementation was intentionally kept focused on the areas the assignment evaluates most heavily: Flutter/Dart fundamentals, API integration, state management, clean structure, UI fidelity, and especially the **Favorites real-time synchronization checkpoint**.

---

# 👀 App Showcase

## 🧭 Pokédex — the home base

The main screen combines the core browsing experience:

- Live Pokémon data
- Search by name
- Type filtering
- Sorting
- Infinite scrolling
- Type-themed cards
- Favorite actions
- Four-item bottom navigation

<img src="docs/screenshots/main.png" alt="Pokédex main screen" width="330">

---

## 🔎 Pokémon Details — go deeper

Tap any Pokémon to open its detailed view.

The detail experience includes:

- Pokémon artwork
- Name and ID
- Type badges
- Description
- Weight
- Height
- Category
- Ability
- Gender
- Weaknesses
- Evolutions
- Base stats

<table>
<tr>
<td align="center">

<b>Hero + Information</b>

<br><br>

<img src="docs/screenshots/detail_top.png" alt="Pokémon detail top screen" width="300">

</td>
<td align="center">

<b>Stats + Evolutions</b>

<br><br>

<img src="docs/screenshots/detail_stats.png" alt="Pokémon detail stats screen" width="300">

</td>
</tr>
</table>

---

## ❤️ Favorites — one source of truth

Favorites are not maintained independently on different screens.

Favorite a Pokémon from the list or detail page and the state is reflected throughout the app.

Favorites are also persisted locally, so they remain available after restarting the app.

<img src="docs/screenshots/favorites.png" alt="Favorites screen" width="330">

---

## 🌍 Regions — extending the Figma experience

The supplied Figma also contains a Regions experience, so a lightweight Regions tab was added to make the overall navigation feel complete.

<img src="docs/screenshots/regions.png" alt="Regions screen" width="330">

---

# ⚡ Features

| Area | Implementation |
|---|---|
| Pokémon List | Live data from PokéAPI |
| Pagination | Infinite scroll using the API `next` URL |
| Search | Filters the currently loaded Pokémon by name |
| Type Filter | Filters loaded Pokémon by type |
| Sorting | Lowest Number, Highest Number, A–Z, Z–A |
| Pokémon Detail | Full detail data fetched by ID |
| Type Themes | Type-colored cards, chips and artwork panels |
| Base Stats | HP, Attack, Defense, Sp. Attack, Sp. Defense, Speed |
| Favorites | Add/remove favorites from list and detail |
| Favorite Persistence | Favorite IDs stored locally |
| Shared State | Riverpod single source of truth |
| Favorites Screen | Displays only favorited Pokémon |
| Extra Navigation | Regions + Profile tabs inspired by the supplied design |

---

# ❤️ The Technical Checkpoint

The most important part of the assignment is not the heart icon.

It is **the state behind the heart**.

The app deliberately uses one shared favorites provider:

```text
                    ┌─────────────────────┐
                    │  favoritesProvider  │
                    │    Set<int> IDs     │
                    └──────────┬──────────┘
                               │
              ┌────────────────┼────────────────┐
              │                │                │
              ▼                ▼                ▼
         Pokédex List       Detail           Favorites
              │                │                │
              └────────────────┼────────────────┘
                               │
                               ▼
                       SharedPreferences
                         local persistence
```

This means:

```text
Pokédex ❤️
    ↓
favoritesProvider
    ↓
Detail ❤️ updates
    ↓
Favorites updates
    ↓
Restart app
    ↓
Favorite IDs restored
```

There is no duplicated favorites state per screen.

There is no manual refresh.

There is no backend.

---

# 🧠 Why These Technical Choices?

## State Management — Riverpod

**Riverpod** was chosen as the application's shared state-management solution.

Favorites are used by multiple screens, so keeping them inside individual `StatefulWidget`s would make synchronization unnecessarily fragile.

Instead, one provider owns the favorite IDs and all relevant screens observe that same state.

### Screen-local state still uses `setState`

`setState` remains appropriate for local UI state such as:

- search text
- selected type
- selected sorting option
- loading flags
- pagination state

The distinction keeps shared state shared and local state local.

---

## Local Storage — SharedPreferences

The application stores only the **IDs of favorited Pokémon** locally.

For example:

```text
[1, 6, 23, 75]
```

### Why IDs?

- Small amount of data
- Stable identifiers for Pokémon
- Avoids duplicating complete API responses
- Pokémon information can be fetched when needed
- Fits the local-only favorites requirement of the assignment

This also keeps the app simple without introducing a backend or cloud-sync layer.

---

# 🌐 API Integration

The app uses the public **PokéAPI**, which requires no authentication.

## Pokémon List

```http
GET https://pokeapi.co/api/v2/pokemon?limit=20&offset=0
```

The API response provides a `next` URL, which is used to implement infinite scrolling.

## Pokémon Detail

```http
GET https://pokeapi.co/api/v2/pokemon/{id}
```

## Related Detail Data

Additional Pokémon information is retrieved through related PokéAPI resources for:

- Pokémon species
- type relationships
- evolution chains

No authentication is required.

---

# 🏗️ Project Structure

```text
lib/
├── main.dart
│
├── models/
│   ├── pokemon.dart
│   ├── pokemon_detail.dart
│   └── pokemon_page.dart
│
├── providers/
│   └── favorites_provider.dart
│
├── screens/
│   ├── home_screen.dart
│   └── pokemon_detail_screen.dart
│
├── services/
│   └── pokemon_api.dart
│
└── widgets/
    └── pokemon_card.dart
```

### Responsibility flow

```text
API / Parsing
      ↓
Models
      ↓
Shared State
      ↓
Screens
      ↓
Reusable Widgets
```

The goal was to keep API/data access separate from UI code while maintaining a small and understandable project structure.

---

# 🚀 Run Locally

## Prerequisites

Install:

- Flutter SDK
- Dart SDK (included with Flutter)
- Xcode for iOS development

Verify your Flutter environment:

```bash
flutter doctor
```

---

## 1. Clone the repository

```bash
git clone https://github.com/Noor1246/pokedex_flutter.git
cd pokedex_flutter
```

---

## 2. Install dependencies

```bash
flutter pub get
```

---

## 3. Run the app

For an available device:

```bash
flutter devices
flutter run
```

For a specific iOS simulator:

```bash
flutter run -d <device-id>
```

The app is designed for a standard portrait phone layout.

---

# ✅ Code Quality

Before submission, the project was formatted and analyzed using:

```bash
dart format lib/
flutter analyze
```

The final project reports:

```text
No issues found!
```

---

# 🧩 Edge Cases Covered

The application handles the main edge cases requested by the assignment:

- Initial loading state
- API/network failure
- Retry after API failure
- Empty search results
- Empty Favorites state
- Favorite persistence after app restart
- Favorite Pokémon that are not currently loaded in the main list
- Pagination loading state
- Pokémon detail loading failures

---

# 🎨 Design Implementation

The goal was **reasonable Figma fidelity**, not pixel-perfect duplication.

The implementation follows the visual language of the supplied design:

- Rounded Pokémon cards
- Light type-tinted card backgrounds
- Saturated type-colored artwork panels
- Translucent type motifs behind artwork
- Type-colored chips
- Large Pokémon artwork
- Heart actions
- Compact filter/sort pills
- Four-item bottom navigation
- Colored detail hero section
- White information cards
- Weakness chips
- Evolution cards
- Base-stat bars

The application uses the Figma design as the visual reference while keeping the implementation practical within the assignment scope.

---

# 🧭 Navigation

The app contains four navigation destinations inspired by the supplied Figma:

```text
┌────────────┬────────────┬────────────┬────────────┐
│  Pokédex   │  Regiões   │  Favoritos │   Perfil   │
└────────────┴────────────┴────────────┴────────────┘
```

### Pokédex

Core assignment functionality:

- list
- search
- filter
- sort
- pagination

### Regiões

Lightweight visual implementation inspired by the provided Figma.

### Favoritos

Core assignment functionality:

- locally persisted favorites
- shared state
- real-time synchronization

### Perfil

Lightweight UI inspired by the supplied navigation design.

---

# 🚫 Deliberate Scope Decisions

## No Login / Authentication

The supplied Figma contains login-related screens, but authentication is explicitly **out of scope** for this assignment.

Therefore, this project intentionally does not implement:

```text
Backend authentication
Login
Registration
Cloud accounts
Cloud favorite synchronization
```

Favorites are local-only by design.

---

## No Full Offline Pokémon Cache

Full offline caching of Pokémon data was not implemented.

Favorite IDs are persisted locally as required, while Pokémon information is retrieved from PokéAPI when necessary.

---

## No CI/CD or Release Packaging

The assignment explicitly excludes:

- automated CI/CD
- release packaging
- App Store / Play Store packaging
- test coverage targets

The implementation therefore focuses on functionality and code quality instead.

---

# 🔧 Known Limitations

With additional development time, I would improve:

1. Extract all type colors/icons into a centralized theme utility instead of defining them across multiple UI files.
2. Introduce stronger API abstractions and request caching/deduplication.
3. Add automated tests for favorites synchronization and API parsing.
4. Expand the Regions experience into a fully data-driven feature.
5. Add richer offline caching where useful.
6. Continue refining spacing and typography toward pixel-level Figma fidelity.

---

# 📋 Assignment Requirement Coverage

| Assignment Requirement | Status |
|---|:---:|
| Live PokéAPI data | ✅ |
| Paginated Pokémon list | ✅ |
| Infinite scroll / API `next` | ✅ |
| Search currently loaded Pokémon by name | ✅ |
| Loading indicator | ✅ |
| Retry/error state | ✅ |
| Favorite toggle on cards | ✅ |
| Pokémon detail screen | ✅ |
| Detail artwork / name / ID | ✅ |
| Type-colored detail chips | ✅ |
| Height / Weight | ✅ |
| Abilities | ✅ |
| Base Stats | ✅ |
| Favorite toggle in detail header | ✅ |
| Local favorite persistence | ✅ |
| List ↔ Detail synchronization | ✅ |
| Favorites real-time synchronization | ✅ |
| Single shared source of truth | ✅ |
| Favorites tab | ✅ |
| Empty favorites state | ✅ |
| Empty search state | ✅ |
| Network failure handling | ✅ |
| Portrait phone layout | ✅ |
| Organized project structure | ✅ |
| `dart format` | ✅ |
| `flutter analyze` | ✅ |
| README | ✅ |

---

# 📝 Git Workflow

The project was developed with incremental Git commits rather than a single giant commit.

Example commit history:

```text
docs: add project README and app screenshots
feat: implement Pokédex, details and favorites
feat: add PokéAPI integration and data models
chore: initialize Flutter Pokédex project
```

This keeps the development history easier to follow and reflects the incremental nature of the implementation.

---

# 🎯 What Was Prioritized?

The assignment has a fixed amount of time and explicitly says it is evaluating Flutter/Dart fundamentals, API integration, state management, design fidelity, and especially favorites synchronization.

Because of that, development effort was intentionally prioritized toward:

```text
                    ┌──────────────────────┐
                    │   Core Requirements  │
                    └──────────┬───────────┘
                               │
          ┌────────────────────┼────────────────────┐
          ▼                    ▼                    ▼
       Flutter             PokéAPI             Favorites
          │                    │                    │
          ▼                    ▼                    ▼
       UI/UX              Pagination          Persistence
                           Detail API        Real-time sync
```

The goal was to build the required experience completely rather than spend most of the available time on out-of-scope backend/authentication features.

---

# 📌 Assignment Reference

This project was implemented against the supplied:

**Take-Home Assignment: Pokédex Flutter App**

Core task areas included:

- Flutter/Dart implementation
- PokéAPI integration
- Figma-inspired Pokémon list
- Pagination
- Search
- Pokémon detail screen
- Local favorites
- Real-time favorite synchronization
- Shared source of truth
- Clean project organization
- README and technical justification

---

# 🎨 Design Attribution

### UI Reference

**Pokédex / Pokémon App — Figma Community**  
by **Junior Saraiva**

The assignment identifies the design reference as licensed under **CC BY 4.0**.

### Data Source

**PokéAPI**

Public Pokémon API used for live application data.

This project is an independent Flutter implementation created for the take-home assignment and is not an official Pokémon product.

---

<div align="center">

# ⚡ Built with Flutter. Powered by PokéAPI. Driven by one source of truth. ❤️

### Catch something. Explore something. Favorite something.

<br>

**GitHub:**  
https://github.com/Noor1246/pokedex_flutter

</div>