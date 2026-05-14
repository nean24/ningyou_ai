import { v } from "convex/values";

import { action } from "./_generated/server";
import type { Id } from "./_generated/dataModel";
import { internal } from "./_generated/api";
import { generateGeminiText } from "./lib/gemini";
import { buildGeminiPrompt } from "./lib/prompts";

type AssistantReplyResult = {
  messageId: Id<"messages">;
  text: string;
  model: string;
};

export const generateAssistantReply = action({
  args: {
    conversationId: v.id("conversations"),
    model: v.optional(v.string()),
  },
  handler: async (ctx, args): Promise<AssistantReplyResult> => {
    const conversation = await ctx.runQuery(
      internal.conversations.getForAction,
      { conversationId: args.conversationId },
    );
    if (!conversation) {
      throw new Error("Conversation not found");
    }

    const character = await ctx.runQuery(internal.characters.getForAction, {
      characterId: conversation.characterId,
    });
    if (!character) {
      throw new Error("Character not found");
    }

    const recentMessages = await ctx.runQuery(
      internal.messages.listRecentForAction,
      {
        conversationId: args.conversationId,
        limit: 24,
      },
    );

    const orderedMessages = [...recentMessages].reverse();
    const prompt = buildGeminiPrompt({
      character,
      messages: orderedMessages.map((message) => ({
        role: message.role,
        content: message.content,
      })),
    });

    try {
      const result = await generateGeminiText({
        model: args.model,
        systemInstruction: prompt.systemInstruction,
        contents: prompt.contents,
      });

      const messageId: Id<"messages"> = await ctx.runMutation(
        internal.messages.saveAssistantMessage,
        {
          conversationId: args.conversationId,
          content: result.text,
          model: result.model,
          tokenCount: result.outputTokens,
        },
      );

      await ctx.runMutation(internal.usageLogs.record, {
        userId: conversation.userId,
        conversationId: args.conversationId,
        model: result.model,
        inputTokens: result.inputTokens,
        outputTokens: result.outputTokens,
      });

      return {
        messageId,
        text: result.text,
        model: result.model,
      };
    } catch (error) {
      await ctx.runMutation(internal.messages.saveFailedAssistantMessage, {
        conversationId: args.conversationId,
        error: error instanceof Error ? error.message : "Unknown AI error",
      });
      throw error;
    }
  },
});
