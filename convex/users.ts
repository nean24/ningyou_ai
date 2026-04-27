import { v } from "convex/values";

import { internalMutation, internalQuery, mutation, query } from "./_generated/server";

export const get = query({
  args: { userId: v.id("users") },
  handler: async (ctx, args) => {
    return await ctx.db.get(args.userId);
  },
});

/** Upsert a user from a verified Google profile. Returns the userId. */
export const upsertFromGoogle = internalMutation({
  args: {
    googleId: v.string(),
    email: v.string(),
    displayName: v.string(),
    avatarUrl: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const now = Date.now();
    const existing = await ctx.db
      .query("users")
      .withIndex("by_external_id", (q) => q.eq("externalId", args.googleId))
      .first();

    if (existing) {
      // Update profile info in case it changed
      await ctx.db.patch(existing._id, {
        displayName: args.displayName,
        avatarUrl: args.avatarUrl,
        email: args.email,
        updatedAt: now,
      });
      return existing._id;
    }

    // Create new authenticated user
    const userId = await ctx.db.insert("users", {
      externalId: args.googleId,
      email: args.email,
      displayName: args.displayName,
      avatarUrl: args.avatarUrl,
      isAnonymous: false,
      createdAt: now,
      updatedAt: now,
    });

    await ctx.db.insert("userSettings", {
      userId,
      preferredModel: "gemini-2.5-flash",
      language: "vi",
      createdAt: now,
      updatedAt: now,
    });

    return userId;
  },
});

/** Get a user by email address. */
export const getByEmail = internalQuery({
  args: { email: v.string() },
  handler: async (ctx, { email }) => {
    return await ctx.db
      .query("users")
      .withIndex("by_email", (q) => q.eq("email", email))
      .first();
  },
});

/** Create a new email/password user. Returns the userId. */
export const createWithEmail = internalMutation({
  args: {
    email: v.string(),
    displayName: v.string(),
    passwordHash: v.string(),
  },
  handler: async (ctx, args) => {
    const now = Date.now();
    const userId = await ctx.db.insert("users", {
      email: args.email,
      displayName: args.displayName,
      passwordHash: args.passwordHash,
      isAnonymous: false,
      createdAt: now,
      updatedAt: now,
    });

    await ctx.db.insert("userSettings", {
      userId,
      preferredModel: "gemini-2.5-flash",
      language: "vi",
      createdAt: now,
      updatedAt: now,
    });

    return userId;
  },
});

/** Get a user by their session token (for use in HTTP actions). */
export const getByExternalId = internalQuery({
  args: { externalId: v.string() },
  handler: async (ctx, { externalId }) => {
    return await ctx.db
      .query("users")
      .withIndex("by_external_id", (q) => q.eq("externalId", externalId))
      .first();
  },
});

/** Create an anonymous user and return their userId. */
export const ensureAnonymous = mutation({
  args: {
    displayName: v.optional(v.string()),
    avatarUrl: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const now = Date.now();
    const userId = await ctx.db.insert("users", {
      displayName: args.displayName?.trim() || "Anonymous",
      avatarUrl: args.avatarUrl,
      isAnonymous: true,
      createdAt: now,
      updatedAt: now,
    });

    await ctx.db.insert("userSettings", {
      userId,
      preferredModel: "gemini-2.5-flash",
      language: "vi",
      createdAt: now,
      updatedAt: now,
    });

    return userId;
  },
});
