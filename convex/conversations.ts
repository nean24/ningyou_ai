import { v } from "convex/values";

import { internalQuery, mutation, query } from "./_generated/server";
import { sanitizeOptionalText } from "./lib/safety";

export const get = query({
  args: { conversationId: v.id("conversations") },
  handler: async (ctx, args) => {
    return await ctx.db.get(args.conversationId);
  },
});

export const getForAction = internalQuery({
  args: { conversationId: v.id("conversations") },
  handler: async (ctx, args) => {
    return await ctx.db.get(args.conversationId);
  },
});

export const listByUser = query({
  args: {
    userId: v.optional(v.id("users")),
    limit: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    return await ctx.db
      .query("conversations")
      .withIndex("by_user", (q) => q.eq("userId", args.userId))
      .order("desc")
      .take(args.limit ?? 50);
  },
});

export const create = mutation({
  args: {
    userId: v.optional(v.id("users")),
    characterId: v.id("characters"),
    title: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const character = await ctx.db.get(args.characterId);
    if (!character) {
      throw new Error("Character not found");
    }

    const now = Date.now();
    return await ctx.db.insert("conversations", {
      userId: args.userId,
      characterId: args.characterId,
      title: sanitizeOptionalText(args.title) ?? character.name,
      lastMessageAt: now,
      createdAt: now,
      updatedAt: now,
    });
  },
});
