import { v } from "convex/values";

import { internalMutation } from "./_generated/server";

/**
 * Check and increment a rate limit counter.
 * Returns { allowed: true } or { allowed: false, retryAfterMs }.
 *
 * key        — unique string, typically "ip:endpoint"
 * maxRequests — max allowed in the window
 * windowMs    — window size in milliseconds
 */
export const checkAndIncrement = internalMutation({
  args: {
    key: v.string(),
    maxRequests: v.number(),
    windowMs: v.number(),
  },
  handler: async (ctx, { key, maxRequests, windowMs }) => {
    const now = Date.now();

    const existing = await ctx.db
      .query("authAttempts")
      .withIndex("by_key", (q) => q.eq("key", key))
      .first();

    // No record yet, or window has expired → start fresh
    if (!existing || now - existing.windowStart >= windowMs) {
      if (existing) {
        await ctx.db.patch(existing._id, { count: 1, windowStart: now });
      } else {
        await ctx.db.insert("authAttempts", { key, count: 1, windowStart: now });
      }
      return { allowed: true };
    }

    // Within window — check count
    if (existing.count >= maxRequests) {
      const retryAfterMs = existing.windowStart + windowMs - now;
      return { allowed: false, retryAfterMs };
    }

    await ctx.db.patch(existing._id, { count: existing.count + 1 });
    return { allowed: true };
  },
});

/** Purge stale rate-limit records (called from cron). */
export const deleteStale = internalMutation({
  args: { olderThanMs: v.number() },
  handler: async (ctx, { olderThanMs }) => {
    const cutoff = Date.now() - olderThanMs;
    const stale = await ctx.db
      .query("authAttempts")
      .filter((q) => q.lt(q.field("windowStart"), cutoff))
      .collect();
    await Promise.all(stale.map((r) => ctx.db.delete(r._id)));
    return stale.length;
  },
});
