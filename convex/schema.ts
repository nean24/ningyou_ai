import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

const visibility = v.union(
  v.literal("public"),
  v.literal("private"),
  v.literal("unlisted"),
);

const messageRole = v.union(
  v.literal("user"),
  v.literal("assistant"),
  v.literal("system"),
);

const messageStatus = v.union(
  v.literal("pending"),
  v.literal("sent"),
  v.literal("failed"),
);

export default defineSchema({
  users: defineTable({
    displayName: v.string(),
    avatarUrl: v.optional(v.string()),
    email: v.optional(v.string()),
    externalId: v.optional(v.string()),
    passwordHash: v.optional(v.string()),
    isAnonymous: v.boolean(),
    createdAt: v.number(),
    updatedAt: v.number(),
  })
    .index("by_external_id", ["externalId"])
    .index("by_email", ["email"])
    .index("by_created_at", ["createdAt"]),

  sessions: defineTable({
    userId: v.id("users"),
    token: v.string(),
    expiresAt: v.number(),
    createdAt: v.number(),
  }).index("by_token", ["token"]),

  authAttempts: defineTable({
    key: v.string(),
    count: v.number(),
    windowStart: v.number(),
  }).index("by_key", ["key"]),


  characters: defineTable({
    name: v.string(),
    avatarUrl: v.optional(v.string()),
    description: v.string(),
    greeting: v.optional(v.string()),
    systemPrompt: v.string(),
    traits: v.array(v.string()),
    creatorUserId: v.optional(v.id("users")),
    visibility,
    createdAt: v.number(),
    updatedAt: v.number(),
  })
    .index("by_visibility", ["visibility"])
    .index("by_creator", ["creatorUserId"])
    .searchIndex("search_characters", {
      searchField: "name",
      filterFields: ["visibility"],
    }),

  conversations: defineTable({
    userId: v.optional(v.id("users")),
    characterId: v.id("characters"),
    title: v.optional(v.string()),
    lastMessageAt: v.number(),
    createdAt: v.number(),
    updatedAt: v.number(),
  })
    .index("by_user", ["userId", "lastMessageAt"])
    .index("by_character", ["characterId", "lastMessageAt"]),

  messages: defineTable({
    conversationId: v.id("conversations"),
    role: messageRole,
    content: v.string(),
    status: messageStatus,
    model: v.optional(v.string()),
    tokenCount: v.optional(v.number()),
    error: v.optional(v.string()),
    createdAt: v.number(),
  }).index("by_conversation", ["conversationId", "createdAt"]),

  userSettings: defineTable({
    userId: v.id("users"),
    preferredModel: v.string(),
    language: v.string(),
    createdAt: v.number(),
    updatedAt: v.number(),
  }).index("by_user", ["userId"]),

  usageLogs: defineTable({
    userId: v.optional(v.id("users")),
    conversationId: v.optional(v.id("conversations")),
    model: v.string(),
    inputTokens: v.number(),
    outputTokens: v.number(),
    costEstimate: v.optional(v.number()),
    createdAt: v.number(),
  })
    .index("by_user", ["userId", "createdAt"])
    .index("by_conversation", ["conversationId", "createdAt"]),
});
