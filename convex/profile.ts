import { v } from "convex/values";

import { internalMutation } from "./_generated/server";

export const generateAvatarUploadUrl = internalMutation({
  args: {},
  handler: async (ctx) => {
    return await ctx.storage.generateUploadUrl();
  },
});

export const updateProfile = internalMutation({
  args: {
    userId: v.id("users"),
    displayName: v.optional(v.string()),
    avatarStorageId: v.optional(v.id("_storage")),
  },
  handler: async (ctx, args) => {
    const patch: Record<string, unknown> = { updatedAt: Date.now() };

    if (args.displayName !== undefined) {
      patch.displayName = args.displayName.trim();
    }

    let avatarUrl: string | undefined;
    if (args.avatarStorageId !== undefined) {
      avatarUrl = (await ctx.storage.getUrl(args.avatarStorageId)) ?? undefined;
      if (avatarUrl) patch.avatarUrl = avatarUrl;
    }

    await ctx.db.patch(args.userId, patch);
    return { avatarUrl };
  },
});
