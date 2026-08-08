# CITIZEN

**iOS app for preparing for the Georgian citizenship exam.**

A full question bank with practice and mistake-review modes, the Georgian alphabet, a word dictionary, a mock exam and a public leaderboard. Content is available in English, Georgian and Russian. Progress syncs across devices and works offline.

Built solo, in Swift 6 with strict concurrency enabled — the project compiles with zero warnings.

---

## Features

**Learning**
- Question bank organised as categories → topics → questions
- Quiz with multi-round mistake handling: a wrong answer returns to the queue until it is answered correctly
- Separate practice sessions from any source — mistakes pool, saved questions, a folder, or every question containing a given word
- Global mistake pool and a "refresh" mode that revisits already-solved questions
- Bookmark folders, full-text search, per-topic statistics (attempts, best streak, completions)
- Scoring that rewards learning and penalises regression: first correct answer earns points, forgetting a previously solved question costs more than learning it

**Georgian language**
- All 33 letters with example words, images and audio
- Dictionary of ~5,400 word forms with an inverted index mapping each word to every question it appears in
- Tap any word inside a question to see its translation and other occurrences

**Social & premium**
- Public leaderboard with progress rings, mood badges and premium highlighting
- Subscriptions through RevenueCat, mirrored server-side for cross-platform use
- Directory of useful contacts (lawyers, translators, courses) with one-tap saving to the system address book

**Platform**
- Optional voice-over for questions and alphabet
- Light/dark themes, eight accent colours, four alternate app icons
- Screenshot protection, haptics, sound effects

---

## Tech stack

| Area | Choice |
|---|---|
| Language | Swift 6, strict concurrency (complete) |
| UI | SwiftUI, iOS 18+, iPhone only |
| Architecture | MVVM with `@Observable` view models |
| Local storage | Core Data (progress), `UserDefaults` (preferences) |
| Backend | Supabase — Auth, Postgres with RLS, Storage, Edge Functions, pg_cron |
| Payments | RevenueCat + StoreKit |
| Auth | Email/password with OTP, Sign in with Apple |
| Media | AVFoundation, ImageIO |
| Networking | URLSession, Network (reachability) |

---

## Architecture

Strict layering, enforced by convention throughout:

```
View  →  ViewModel  →  Manager  →  Service  →  network / disk
```

- **Views** contain layout only. Each view exposes a single root content property; extensions carry exactly two sections, `Builder` and `Logic`.
- **ViewModels, Managers and Models never import SwiftUI or UIKit.** All display strings live in view models and go through the `L10n(...)` localisation helper.
- **Services** are `Sendable` value types that own a single network concern.
- Colours, gradients and images are reachable only through dedicated extensions — no inline literals in views.

### Offline-first sync

The app is usable without a network connection and reconciles with the server on its own.

- **Progress** — whole-snapshot last-write-wins over a JSON blob, guarded by a monotonic change counter (not a boolean dirty flag) and an opaque server token. A corrupted server payload never wipes local data, and a newer schema version freezes syncing instead of guessing.
- **Profile** — per-field sync. Only fields the user actually edited on this device are pushed; everything else is accepted from the server. Two devices editing different fields no longer overwrite each other.
- Heavy work — catalogue decoding, index building, image decoding, avatar resizing — runs off the main actor.

---

## Project layout

```
Citizen/
├─ App/                 entry point, root gate, tab host
├─ Auth Module/         welcome, sign in/up, OTP, password reset
├─ Learn Module/        quiz, practice, mistakes, saved, search, exam, leaderboard, contacts
├─ Dictionary Module/   alphabet, dictionary, word occurrences
├─ Settings Module/     settings, account, paywall, appearance
├─ Managers/            singletons: sync, auth, content, media, store
├─ Models/              decodable content and DTOs
├─ Service Views/       reusable UI components
├─ Modifiers/           view modifiers
├─ Enums/ Helpers/ Extensions/ States/
└─ Resources/           assets, Core Data model, localisation
```

Content (questions, dictionary, alphabet) is **not bundled** — it is downloaded from Supabase Storage on first launch and version-gated afterwards, so updating the question bank needs no App Store release.

---

## Building

Requires **Xcode 16.2+** and an iOS 18 device or simulator.

```bash
git clone https://github.com/GE-Developer/Citizen-GE.git
cd Citizen-GE
open Citizen.xcodeproj
```

Dependencies resolve through Swift Package Manager:
- [supabase-swift](https://github.com/supabase/supabase-swift)
- [purchases-ios](https://github.com/RevenueCat/purchases-ios)

The app reads its backend configuration from `Citizen/Resources/Property List.plist`. To run against your own infrastructure, replace the Supabase project URL and publishable key, and the RevenueCat key and entitlement identifier.

> The first launch requires a network connection — content and media are fetched from the server.

---

## Localization

Three languages: **English**, **Georgian**, **Russian**. All 343 keys are translated in every language. Language is a user setting rather than a system one, so it can be changed inside the app and follows the account across devices.

---

## Status

In active development, not yet released. Working: authentication, content delivery, quiz and practice, dictionary and alphabet, progress sync, leaderboard, contacts, subscriptions. In progress: exam engine, question voice-over.
