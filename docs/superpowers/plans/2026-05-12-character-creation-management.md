# Character Creation & Management Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Enhance the existing character creation feature to support avatar uploads, and allow users to view their own created characters.

**Architecture:** 
- **Backend (Convex):** Add support for character avatar storage (upload URL generation, storage ID resolution). Add new query for fetching user's own characters. Expose these via HTTP Actions.
- **Frontend (Flutter):** Add `image_picker` for avatar upload in `CharacterCreateScreen`. Create a "My Characters" view to show the `listByCreator` characters.

**Tech Stack:** Convex (TypeScript), Flutter (Riverpod), `image_picker`, `dio` or `http`.

---

### Task 1: Backend - Avatar Upload Support for Characters

**Files:**
- Modify: `convex/characters.ts`
- Modify: `convex/http.ts`

- [ ] **Step 1: Write avatar upload URL mutation**

Modify `convex/characters.ts` to add a mutation for generating upload URLs:
```typescript
export const generateAvatarUploadUrl = mutation({
  args: {},
  handler: async (ctx) => {
    return await ctx.storage.generateUploadUrl();
  },
});
```

- [ ] **Step 2: Update create mutation to accept avatarStorageId**

Modify `convex/characters.ts` `create` mutation:

```typescript
export const create = mutation({
  args: {
    name: v.string(),
    avatarUrl: v.optional(v.string()),
    avatarStorageId: v.optional(v.id("_storage")),
    description: v.string(),
    greeting: v.optional(v.string()),
    systemPrompt: v.string(),
    traits: v.optional(v.array(v.string())),
    creatorUserId: v.optional(v.id("users")),
    visibility: visibility,
  },
  handler: async (ctx, args) => {
    const now = Date.now();
    let avatarUrl = args.avatarUrl;
    if (args.avatarStorageId) {
      avatarUrl = (await ctx.storage.getUrl(args.avatarStorageId)) ?? undefined;
    }

    return await ctx.db.insert("characters", {
      name: sanitizeMessageContent(args.name),
      avatarUrl: sanitizeOptionalText(avatarUrl),
      description: sanitizeMessageContent(args.description),
      greeting: sanitizeOptionalText(args.greeting),
      systemPrompt: sanitizeMessageContent(args.systemPrompt),
      traits: (args.traits ?? []).map((trait) => sanitizeMessageContent(trait)),
      creatorUserId: args.creatorUserId,
      visibility: args.visibility,
      createdAt: now,
      updatedAt: now,
    });
  },
});
```

- [ ] **Step 3: Add HTTP Action for Avatar Upload URL**

Modify `convex/http.ts` to add `/characters/avatar-upload-url`:
```typescript
http.route({
  path: "/characters/avatar-upload-url",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    const token = request.headers.get("Authorization")?.replace("Bearer ", "").trim();
    if (!token) return json({ error: "Unauthorized" }, 401);
    const user = await ctx.runQuery(internal.sessions.validate, { token });
    if (!user) return json({ error: "Unauthorized" }, 401);

    const uploadUrl = await ctx.runMutation(api.characters.generateAvatarUploadUrl, {});
    return json({ uploadUrl });
  }),
});
```

- [ ] **Step 4: Update POST /characters/create HTTP Action**

Modify `convex/http.ts` inside `POST /characters/create` handler:
```typescript
      const body = await request.json() as {
        name?: string;
        description?: string;
        systemPrompt?: string;
        greeting?: string;
        traits?: string[];
        visibility?: string;
        avatarStorageId?: string;
      };

      // ... below, inside ctx.runMutation(api.characters.create) ...
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        avatarStorageId: body.avatarStorageId as any,
```

### Task 2: Backend - "My Characters" API

**Files:**
- Modify: `convex/characters.ts`
- Modify: `convex/http.ts`

- [ ] **Step 1: Write listByCreator query**

Modify `convex/characters.ts`:
```typescript
export const listByCreator = query({
  args: { creatorUserId: v.id("users") },
  handler: async (ctx, args) => {
    return await ctx.db
      .query("characters")
      .withIndex("by_creator", (q) => q.eq("creatorUserId", args.creatorUserId))
      .order("desc")
      .collect();
  },
});
```

- [ ] **Step 2: Add HTTP Action for My Characters**

Modify `convex/http.ts` to add `/characters/my-list`:
```typescript
http.route({
  path: "/characters/my-list",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    const token = request.headers.get("Authorization")?.replace("Bearer ", "").trim();
    if (!token) return json({ error: "Unauthorized" }, 401);
    const user = await ctx.runQuery(internal.sessions.validate, { token });
    if (!user) return json({ error: "Unauthorized" }, 401);

    try {
      const characters = await ctx.runQuery(api.characters.listByCreator, {
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        creatorUserId: user._id as any,
      });
      return json({ characters });
    } catch (error) {
      console.error("[POST /characters/my-list]", error);
      return json({ error: "Internal server error" }, 500);
    }
  }),
});
```

### Task 3: Frontend - Dependencies and Remote Data Source

**Files:**
- Modify: `pubspec.yaml`
- Modify: `lib/features/characters/data/character_remote_data_source.dart`
- Modify: `lib/features/characters/data/character_remote_data_source_impl.dart`

- [ ] **Step 1: Add dependencies**
Run `flutter pub add image_picker dio` in the terminal to ensure packages are available.

- [ ] **Step 2: Update Remote Data Source Interface**

Modify `lib/features/characters/data/character_remote_data_source.dart`:
```dart
  Future<String> getAvatarUploadUrl();
  Future<List<Map<String, dynamic>>> listByCreator();
  // Update create signature:
  Future<Map<String, dynamic>> create({
    required String name,
    required String description,
    required String systemPrompt,
    String? greeting,
    List<String> traits = const [],
    String visibility = 'public',
    String? avatarStorageId,
  });
```

- [ ] **Step 3: Update Remote Data Source Implementation**

Modify `lib/features/characters/data/character_remote_data_source_impl.dart`:
```dart
  @override
  Future<String> getAvatarUploadUrl() async {
    final res = await _client.post('/characters/avatar-upload-url');
    return res['uploadUrl'] as String;
  }

  @override
  Future<List<Map<String, dynamic>>> listByCreator() async {
    final res = await _client.post('/characters/my-list');
    return (res['characters'] as List<dynamic>).cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>> create({
    required String name,
    required String description,
    required String systemPrompt,
    String? greeting,
    List<String> traits = const [],
    String visibility = 'public',
    String? avatarStorageId,
  }) async {
    final res = await _client.post('/characters/create', body: {
      'name': name,
      'description': description,
      'systemPrompt': systemPrompt,
      if (greeting != null && greeting.isNotEmpty) 'greeting': greeting,
      'traits': traits,
      'visibility': visibility,
      if (avatarStorageId != null) 'avatarStorageId': avatarStorageId,
    });
    return res['character'] as Map<String, dynamic>;
  }
```

### Task 4: Frontend - Character Repository and Controller

**Files:**
- Modify: `lib/features/characters/data/character_repository.dart`
- Modify: `lib/features/characters/data/character_repository_impl.dart`
- Modify: `lib/features/characters/presentation/character_controller.dart`

- [ ] **Step 1: Update Repository Interface**
Modify `lib/features/characters/data/character_repository.dart` to add `listByCreator` and add `avatarStorageId` to `createCharacter` signature.

- [ ] **Step 2: Update Repository Implementation**
Modify `lib/features/characters/data/character_repository_impl.dart` to implement `listByCreator` (fetching from remote and caching locally using `_local.cacheAll`) and pass `avatarStorageId` through to the remote data source in `createCharacter`.

- [ ] **Step 3: Update CharacterController**
Modify `lib/features/characters/presentation/character_controller.dart`. Add `avatarStorageId` to `createCharacter` parameters. Add a new `MyCharactersNotifier` or a method to fetch user's characters.

### Task 5: Frontend - Avatar Upload UI in Create Screen

**Files:**
- Modify: `lib/features/characters/presentation/character_create_screen.dart`

- [ ] **Step 1: Add Image Picker UI**
Add a circular avatar widget with a camera icon at the top of the create screen. Use `ImagePicker` from `package:image_picker/image_picker.dart` to select an image from the gallery.

- [ ] **Step 2: Implement Upload Logic**
In the `_submit` method, if an image is selected:
1. Call `getAvatarUploadUrl` to get the pre-signed Convex URL.
2. Use `Dio` to HTTP POST the file bytes to the upload URL.
3. Parse the response to get the `storageId`.
4. Pass the `storageId` to the `createCharacter` controller method.

### Task 6: Frontend - "My Characters" View

**Files:**
- Modify: `lib/features/characters/presentation/character_list_screen.dart`

- [ ] **Step 1: Add Tab Bar**
Convert the `CharacterListScreen` to use a `DefaultTabController` with two tabs: "Discover" (Public characters) and "My Characters" (Created by the user). Update the UI to display the respective lists in each tab.
