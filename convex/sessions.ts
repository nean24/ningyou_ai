import { v } from "convex/values";

import { internalMutation, internalQuery } from "./_generated/server";

// 30 days in milliseconds
const SESSION_DURATION_MS = 30 * 24 * 60 * 60 * 1000;

/** Create a new session for a user and return the token. */
export const create = internalMutation({
  args: { userId: v.id("users") },
  handler: async (ctx, { userId }) => {
    const token = crypto.randomUUID();
    const now = Date.now();
    await ctx.db.insert("sessions", {
      userId,
      token,
      expiresAt: now + SESSION_DURATION_MS,
      createdAt: now,
    });
    return token;
  },
});

/** Validate a session token and return the associated user, or null. */
export const validate = internalQuery({
  args: { token: v.string() },
  handler: async (ctx, { token }) => {
    const session = await ctx.db
      .query("sessions")
      .withIndex("by_token", (q) => q.eq("token", token))
      .first();

    if (!session || session.expiresAt < Date.now()) {
      return null;
    }

    const user = await ctx.db.get(session.userId);
    return user ?? null;
  },
});

/** Delete a session by token (sign out). */
export const deleteByToken = internalMutation({
  args: { token: v.string() },
  handler: async (ctx, { token }) => {
    const session = await ctx.db
      .query("sessions")
      .withIndex("by_token", (q) => q.eq("token", token))
      .first();

    if (session) {
      await ctx.db.delete(session._id);
    }
  },
});

/** Delete all sessions for a user. */
export const deleteAllForUser = internalMutation({
  args: { userId: v.id("users") },
  handler: async (ctx, { userId }) => {
    const sessions = await ctx.db
      .query("sessions")
      .filter((q) => q.eq(q.field("userId"), userId))
      .collect();

    await Promise.all(sessions.map((s) => ctx.db.delete(s._id)));
  },
});

/** Delete all sessions whose expiresAt is in the past. Run via cron. */
export const deleteExpired = internalMutation({
  args: {},
  handler: async (ctx) => {
    const now = Date.now();
    const expired = await ctx.db
      .query("sessions")
      .filter((q) => q.lt(q.field("expiresAt"), now))
      .collect();
    await Promise.all(expired.map((s) => ctx.db.delete(s._id)));
    return expired.length;
  },
});
