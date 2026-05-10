# Ningyou

A Flutter mobile application for AI character conversations, backed by a Convex cloud database and designed with a strict, opinionated design system.

---

## Table of Contents

- [Overview](#overview)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Features](#features)
- [Design System](#design-system)
- [Component Library](#component-library)
- [Backend (Convex)](#backend-convex)
- [Getting Started](#getting-started)
- [State Management](#state-management)
- [Routing](#routing)
- [Local Storage](#local-storage)

---

## Overview

Ningyou lets users discover AI personas (characters), start conversations with them, and chat in real time. The app supports Google OAuth and email/password authentication, anonymous guest mode, an offline-capable SQLite cache, and a dark/light theme.

**Version:** 1.0.0+1  
**Flutter SDK:** >=3.11.5  
**Backend:** Convex

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| UI | Flutter 3.11.5 |
| State | Riverpod 2.6.1 (code generation) |
| Backend | Convex (real-time cloud DB + HTTP actions) |
| Local DB | SQLite via `sqflite` |
| Auth | Google Sign-In + email/password |
| Secure storage | `flutter_secure_storage` |
| Preferences | `shared_preferences` |
| HTTP | `package:http` (thin Convex wrapper) |
| Typography | Google Fonts (Newsreader, IBM Plex Sans, IBM Plex Mono) |

### Full Dependency List

```yaml
dependencies:
  google_fonts: ^6.2.1          # Newsreader, IBM Plex Sans, IBM Plex Mono
  cupertino_icons: ^1.0.8
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1
  google_sign_in: ^6.2.2
  image_picker: ^1.1.2
  sqflite: ^2.4.1
  path: ^1.9.1
  flutter_secure_storage: ^9.2.4
  shared_preferences: ^2.5.3
  http: ^1.3.0

dev_dependencies:
  flutter_lints: ^6.0.0
  riverpod_generator: ^2.6.5
  build_runner: ^2.4.15
  custom_lint: ^0.7.5
  riverpod_lint: ^2.6.3
```

---

## Architecture

The project follows **Clean Architecture** with a feature-first folder layout. Each feature is self-contained with three layers:

```
feature/
  data/        ← data sources + repository implementation
  domain/      ← models + repository interface
  presentation/ ← Riverpod controllers + screens + widgets
```

### Data Flow

```
Screen → Controller (Riverpod) → Repository
                                    ├── Remote Data Source (ConvexHttpClient)
                                    └── Local Data Source (SQLite DAO)
```

Repositories apply a **cache-first** strategy: read from SQLite on cold load, sync from Convex in the background, write-through on mutations.

---

## Project Structure

```
lib/
├── main.dart                            # Entry point
├── app.dart                             # Root widget (theme + router)
│
├── core/
│   ├── config/
│   │   ├── app_config.dart              # App-wide config
│   │   └── env.dart                     # --dart-define env variables
│   ├── constants/
│   │   ├── api_constants.dart
│   │   └── storage_keys.dart
│   ├── database/
│   │   ├── app_database.dart            # SQLite init, migrations
│   │   ├── database_provider.dart
│   │   └── daos/
│   │       ├── characters_dao.dart
│   │       ├── conversations_dao.dart
│   │       └── messages_dao.dart
│   ├── errors/
│   │   ├── app_exception.dart
│   │   └── failure.dart
│   ├── network/
│   │   ├── convex_http_client.dart      # Bearer-token HTTP wrapper
│   │   └── dio_client.dart
│   ├── routing/
│   │   ├── app_router.dart              # Auth-aware route guard
│   │   └── main_shell.dart             # Bottom-nav IndexedStack (3 tabs)
│   ├── theme/
│   │   ├── ningyou_colors.dart          # Light + dark palettes
│   │   ├── ningyou_spacing.dart         # Spacing scale (xxs–huge)
│   │   ├── ningyou_radius.dart          # Radius scale (xs–pill)
│   │   ├── ningyou_text_styles.dart     # Mono label helper
│   │   └── app_theme.dart              # ThemeData factory
│   └── utils/
│       └── date_time_utils.dart
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── auth_remote_data_source.dart
│   │   │   ├── auth_remote_data_source_impl.dart
│   │   │   ├── auth_repository.dart
│   │   │   └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── auth_state.dart          # Sealed: Initial|Loading|Authenticated|Anonymous|Unauthenticated|Error
│   │   │   └── app_user.dart            # AppUser model
│   │   └── presentation/
│   │       ├── auth_controller.dart
│   │       └── sign_in_screen.dart
│   │
│   ├── characters/
│   │   ├── data/
│   │   │   ├── character_local_data_source.dart
│   │   │   ├── character_remote_data_source.dart
│   │   │   ├── character_remote_data_source_impl.dart
│   │   │   ├── character_repository.dart
│   │   │   └── character_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── character.dart           # Character model
│   │   │   └── character_persona.dart
│   │   └── presentation/
│   │       ├── character_controller.dart
│   │       ├── character_list_screen.dart
│   │       ├── character_detail_screen.dart
│   │       └── character_create_screen.dart
│   │
│   ├── conversations/
│   │   ├── data/
│   │   │   ├── conversation_local_data_source.dart
│   │   │   ├── conversation_remote_data_source.dart
│   │   │   ├── conversation_remote_data_source_impl.dart
│   │   │   ├── conversation_repository.dart
│   │   │   └── conversation_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── conversation.dart
│   │   │   └── message.dart             # MessageRole: user|assistant
│   │   └── presentation/
│   │       ├── conversation_controller.dart
│   │       └── conversation_list_screen.dart
│   │
│   ├── chat/
│   │   ├── data/
│   │   │   ├── chat_local_data_source.dart
│   │   │   ├── chat_remote_data_source.dart
│   │   │   ├── chat_remote_data_source_impl.dart
│   │   │   ├── chat_repository.dart
│   │   │   └── chat_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── chat_message.dart
│   │   │   └── send_message_request.dart
│   │   └── presentation/
│   │       ├── chat_controller.dart
│   │       ├── chat_screen.dart
│   │       └── widgets/
│   │           ├── chat_input.dart
│   │           └── typing_indicator.dart
│   │
│   └── settings/
│       ├── data/
│       │   ├── settings_repository.dart
│       │   ├── settings_local_data_source.dart
│       │   └── profile_data_source.dart
│       ├── domain/
│       │   └── app_settings.dart
│       └── presentation/
│           ├── settings_controller.dart
│           ├── settings_screen.dart
│           └── profile_edit_screen.dart
│
└── shared/
    ├── providers/
    │   ├── convex_client_provider.dart
    │   ├── secure_storage_provider.dart
    │   ├── shared_preferences_provider.dart
    │   ├── theme_provider.dart
    │   └── notifications_provider.dart
    └── widgets/
        ├── app_loading.dart
        ├── app_error_view.dart
        ├── avatar_image.dart
        └── ningyou/                     # Design system component library
            ├── ningyou_button.dart
            ├── ningyou_avatar.dart
            ├── ningyou_chat_bubble.dart
            ├── ningyou_badge.dart
            ├── ningyou_text_field.dart
            ├── ningyou_icon_button.dart
            ├── ningyou_composer.dart
            ├── ningyou_persona_card.dart
            ├── ningyou_toast.dart
            ├── ningyou_loading.dart
            └── design_system_preview_screen.dart
```

---

## Features

### Auth

- **Google Sign-In** — OAuth flow with token validation via Convex HTTP action
- **Email/Password** — Sign-up and sign-in with backend validation
- **Anonymous/Guest** — Skip auth and browse with limited access
- **Session persistence** — Token stored in `FlutterSecureStorage`
- **State:** `AuthState` sealed class (Initial → Loading → Authenticated | Anonymous | Unauthenticated | Error)

### Characters (Discover tab)

- Browse public AI personas in a grid with real-time search filter
- View character detail: name, bio, traits, greeting, system prompt
- Create custom characters (name, description, greeting, visibility: public/private/unlisted)
- Cache-first load: SQLite → Convex sync in background

### Conversations (Chats tab)

- List all active conversations, sorted by last message time
- Each conversation is linked to a single character and a single user
- Tapping a conversation opens the ChatScreen

### Chat

- Real-time message exchange with an AI character
- `NingyouChatBubble` differentiates user vs. AI messages visually
- Typing indicator while waiting for AI response
- Auto-scroll to latest message
- Message statuses: pending → sent | failed
- Messages cached locally in SQLite for offline reading

### Settings (Profile tab)

- Toggle light/dark theme
- Edit display name and avatar (image picker)
- View app info
- Sign out

---

## Design System

All UI must follow the Ningyou Design Language. Never use raw `Colors.*`, hardcoded hex values, arbitrary padding/radius numbers, or default Material widgets when a Ningyou component exists.

### Accessing Tokens

```dart
final palette = NingyouColors.of(context);   // color tokens
final text = Theme.of(context).textTheme;    // typography
```

### Color Tokens

| Token | Light | Dark |
|-------|-------|------|
| `palette.background` | `#FBF7EF` cream | `#171411` near-black |
| `palette.backgroundSubtle` | slightly deeper | deeper |
| `palette.backgroundMuted` | card/inset areas | card/inset areas |
| `palette.surface` | `#FFFCF7` | `#211D19` |
| `palette.surfaceRaised` | `#FFFFFF` | `#2A251F` |
| `palette.border` | subtle warm | subtle warm |
| `palette.text` | `#25201B` | `#F4ECE0` |
| `palette.textMuted` | `#74685C` | `#C3B6A7` |
| `palette.textSubtle` | `#9B8E80` | `#938779` |
| `palette.accent` | `#2F8C7E` teal | `#63B9A9` teal |
| `palette.accentSoft` | `#DDEAEA` | soft teal |
| `palette.accentText` | text on soft accent | |
| `palette.onAccent` | text/icon on filled accent | |
| `palette.aiBubble` | `#F1E8DC` | `#302921` |
| `palette.aiBubbleText` | `#302821` | `#F4ECE0` |
| `palette.success/Soft` | green | green |
| `palette.warning/Soft` | amber | amber |
| `palette.danger/Soft` | red | red |
| `palette.info/Soft` | blue | blue |

**Avatar gradients:** `NingyouAvatarGradients.amber/violet/green/rose/blue/neutral`

### Typography

```dart
// Headings / persona names — Newsreader italic
Theme.of(context).textTheme.displayLarge   // 56px
Theme.of(context).textTheme.displayMedium  // 42px
Theme.of(context).textTheme.headlineSmall  // 28px
Theme.of(context).textTheme.titleLarge     // 24px — persona names, section titles

// Body — IBM Plex Sans
Theme.of(context).textTheme.titleMedium    // 17px semibold — top bar
Theme.of(context).textTheme.bodyLarge      // 16px
Theme.of(context).textTheme.bodyMedium     // 15px — default
Theme.of(context).textTheme.bodySmall      // 13px — descriptions

// Metadata / labels — IBM Plex Mono uppercase
NingyouTextStyles.monoLabel(palette.textSubtle)  // 11px, tracking 1.2
```

### Spacing

```dart
NingyouSpacing.xxs   // 4
NingyouSpacing.xs    // 8
NingyouSpacing.sm    // 12
NingyouSpacing.md    // 16
NingyouSpacing.lg    // 20
NingyouSpacing.xl    // 24   ← default horizontal page padding
NingyouSpacing.xxl   // 32
NingyouSpacing.xxxl  // 48
NingyouSpacing.huge  // 64
```

### Border Radius

```dart
NingyouRadius.xs      // 6   — small chips
NingyouRadius.sm      // 10  — nav items
NingyouRadius.md      // 14  — inputs, badges
NingyouRadius.lg      // 18  — cards, chat bubbles
NingyouRadius.xl      // 22  — persona cards
NingyouRadius.modal   // 28  — bottom sheets, modals
NingyouRadius.pill    // 999 — buttons, tags, toggles, avatars
```

### Motion

```dart
const fast = Duration(milliseconds: 120);   // hover/press
const base = Duration(milliseconds: 200);   // screen transitions
const slow = Duration(milliseconds: 360);   // modals, sheets
const easeOut = Curves.easeOut;
```

---

## Component Library

All shared components live in `lib/shared/widgets/ningyou/`. Always use these before writing new widgets.

### `NingyouButton`

```dart
NingyouButton.primary(label: 'Start chat', onPressed: () {})
NingyouButton.secondary(label: 'Browse', onPressed: () {})
NingyouButton.outline(label: 'Cancel', onPressed: () {})
NingyouButton.ghost(label: 'Skip', onPressed: () {})
NingyouButton.danger(label: 'Delete', onPressed: () {})

// Optional
size: NingyouButtonSize.sm  // sm | md | lg
icon: Icons.send
```

### `NingyouAvatar`

```dart
NingyouAvatar(
  initials: 'NA',
  size: NingyouAvatarSize.md,           // xs(28) sm(36) md(48) lg(64) xl(84)
  gradient: NingyouAvatarGradient.amber, // amber|violet|green|rose|blue|neutral
  showStatus: true,
)
```

### `NingyouChatBubble`

```dart
NingyouChatBubble.ai(text: 'Hello!', meta: 'Hana · now')
NingyouChatBubble.user(text: 'Hi there', meta: 'You · 2m ago')
```

### `NingyouBadge`

Status chips, counts, and semantic labels.

### `NingyouTextField`

Replaces all raw `TextField` / `TextFormField` usage.

### `NingyouIconButton`

Replaces all raw `IconButton` usage.

### `NingyouComposer`

The chat message input. Never build a custom chat input.

### `NingyouPersonaCard`

Character card for grids and carousels (avatar, name, bio, tag, chat count).

### `NingyouToast`

```dart
NingyouToast.success(message: 'Saved')
NingyouToast.warning(message: 'Check input')
NingyouToast.danger(message: 'Error occurred')
NingyouToast.info(message: 'Tip: ...')
```

Replaces all `SnackBar` usage.

### `NingyouLoading`

Animated skeleton shimmer for loading states.

---

## Backend (Convex)

Configure your Convex URLs via `--dart-define` or environment variables (see [Getting Started](#getting-started)). Do not hardcode production URLs in source files.

### Database Tables

| Table | Key Indexes |
|-------|------------|
| `users` | by_external_id, by_email, by_created_at |
| `characters` | by_visibility, by_creator, search_characters |
| `conversations` | by_user, by_character |
| `messages` | by_conversation |
| `sessions` | — |
| `rate_limits` | — |
| `usage_logs` | — |
| `crons` | — |

### HTTP Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `auth/google/signin` | POST | Validate Google idToken, create session |
| `auth/validate` | POST | Validate Bearer session token |
| `characters/listPublic` | GET | All public characters |
| `characters/get` | GET | Single character by id |
| `characters/create` | POST | Create new character |
| `conversations/*` | CRUD | Conversation management |
| `messages/*` | CRUD | Message send/list |
| `profile/*` | CRUD | User profile |
| `users/*` | CRUD | User operations |
| `sessions/*` | — | Session management |

### `ConvexHttpClient`

A thin `package:http` wrapper at `lib/core/network/convex_http_client.dart`:

- Attaches `Authorization: Bearer <token>` automatically when a token is present
- Methods: `get()`, `post()`, `patch()`
- Throws `ConvexHttpException` on non-2xx responses

---

## Getting Started

### Prerequisites

- Flutter 3.11.5+
- Dart 3.11.5+
- Xcode (iOS) or Android Studio (Android)
- Node.js (for Convex backend development)

### Install & Run

```bash
# 1. Install Flutter dependencies
flutter pub get

# 2. Generate Riverpod providers (run after adding/modifying providers)
dart run build_runner build

# 3. Run the app (uses default --dart-define values hardcoded in env.dart)
flutter run

# Or with explicit environment overrides:
flutter run \
  --dart-define=CONVEX_URL=<your-convex-url> \
  --dart-define=CONVEX_SITE_URL=<your-convex-site-url> \
  --dart-define=GOOGLE_CLIENT_ID=<your-google-client-id>
```

### Backend Development

```bash
# Install Convex Node dependencies
npm install

# Start local Convex dev server
npm run convex:dev

# Deploy backend to production
npm run convex:deploy
```

### Code Generation

After adding or modifying any `@riverpod` annotated provider:

```bash
dart run build_runner build
# or watch mode during development:
dart run build_runner watch
```

---

## State Management

**Riverpod** with `@riverpod` code generation. Key providers:

| Provider | Type | Purpose |
|----------|------|---------|
| `authControllerProvider` | `AsyncNotifier<AuthState>` | Authentication state + actions |
| `characterListProvider` | `AsyncNotifier<List<Character>>` | Public character list |
| `characterDetailProvider(id)` | `FutureProvider` | Single character |
| `conversationListProvider` | `AsyncNotifier<List<Conversation>>` | User conversations |
| `chatProvider(conversationId)` | `AsyncNotifier<List<ChatMessage>>` | Messages per conversation |
| `themeModeProvider` | `Notifier<ThemeMode>` | Light/dark toggle |
| `convexClientProvider` | `Provider` | ConvexHttpClient singleton |
| `secureStorageProvider` | `Provider` | FlutterSecureStorage singleton |
| `sharedPreferencesProvider` | `Provider` | SharedPreferences singleton |

---

## Routing

Navigation is auth-aware via `AppRouter`:

```
Splash (loading)
  ├── Unauthenticated → SignInScreen
  └── Authenticated / Anonymous → MainShell
        ├── Tab 0: ConversationListScreen  (Chats)
        ├── Tab 1: CharacterListScreen     (Discover)
        └── Tab 2: SettingsScreen          (Profile)
```

- **Implementation:** `IndexedStack` for bottom tabs (no GoRouter)
- **Auth guard:** watches `authControllerProvider`, redirects automatically on state change
- **Deep routes:** CharacterDetailScreen, CharacterCreateScreen, ChatScreen, ProfileEditScreen pushed modally or as routes from within tabs

---

## Local Storage

| Store | Library | Contents |
|-------|---------|---------|
| SQLite (`ningyou.db`) | `sqflite` | characters, conversations, messages tables |
| Secure storage | `flutter_secure_storage` | Session token |
| SharedPreferences | `shared_preferences` | Theme mode, app settings |

### SQLite Tables

- **characters** — id, name, description, greeting, systemPrompt, traits, avatarUrl, visibility, createdAt, updatedAt
- **conversations** — id, characterId, userId, title, lastMessageAt, createdAt, updatedAt
- **messages** — id, conversationId, role (user/assistant/system), content, status (pending/sent/failed), model, createdAt

Indexes on `user_id`, `conversation_id`, and `created_at` for efficient queries.
