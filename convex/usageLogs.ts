import { v } from "convex/values";

import { internalMutation } from "./_generated/server";

export const record = internalMutation({
  args: {
    userId: v.optional(v.id("users")),
    conversationId: v.optional(v.id("conversations")),
    model: v.string(),
    inputTokens: v.number(),
    outputTokens: v.number(),
    costEstimate: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    return await ctx.db.insert("usageLogs", {
      ...args,
      createdAt: Date.now(),
    });
  },
});
