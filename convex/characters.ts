import { v } from "convex/values";

import { internalQuery, mutation, query } from "./_generated/server";
import { sanitizeMessageContent, sanitizeOptionalText } from "./lib/safety";

const visibility = v.union(
  v.literal("public"),
  v.literal("private"),
  v.literal("unlisted"),
);

export const listPublic = query({
  args: {
    limit: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    return await ctx.db
      .query("characters")
      .withIndex("by_visibility", (q) => q.eq("visibility", "public"))
      .order("desc")
      .take(args.limit ?? 50);
  },
});

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

export const get = query({
  args: { characterId: v.id("characters") },
  handler: async (ctx, args) => {
    return await ctx.db.get(args.characterId);
  },
});

export const getForAction = internalQuery({
  args: { characterId: v.id("characters") },
  handler: async (ctx, args) => {
    return await ctx.db.get(args.characterId);
  },
});

export const generateAvatarUploadUrl = mutation({
  args: {},
  handler: async (ctx) => {
    return await ctx.storage.generateUploadUrl();
  },
});

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
    visibility,
  },
  handler: async (ctx, args) => {
    const now = Date.now();

    let finalAvatarUrl = args.avatarUrl;
    if (args.avatarStorageId) {
      finalAvatarUrl = (await ctx.storage.getUrl(args.avatarStorageId)) ?? undefined;
    }

    return await ctx.db.insert("characters", {
      name: sanitizeMessageContent(args.name),
      avatarUrl: sanitizeOptionalText(finalAvatarUrl),
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
