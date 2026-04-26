import { describe, expect, it } from "vitest";

import { buildGeminiPrompt } from "../../convex/lib/prompts";
import { sanitizeMessageContent } from "../../convex/lib/safety";

describe("buildGeminiPrompt", () => {
  it("combines persona, safety guardrails, and recent messages", () => {
    const prompt = buildGeminiPrompt({
      character: {
        name: "Linh",
        systemPrompt: "You are a patient literature tutor.",
        traits: ["gentle", "never writes the essay for the user"],
      },
      messages: [
        { role: "user", content: "Mình cần ôn văn trước." },
        { role: "assistant", content: "Được, đọc cho mình câu mở đầu." },
      ],
    });

    expect(prompt.systemInstruction).toContain("Linh");
    expect(prompt.systemInstruction).toContain("patient literature tutor");
    expect(prompt.systemInstruction).toContain("never writes the essay");
    expect(prompt.systemInstruction).toContain("Do not claim to be human");
    expect(prompt.contents).toEqual([
      { role: "user", parts: [{ text: "Mình cần ôn văn trước." }] },
      {
        role: "model",
        parts: [{ text: "Được, đọc cho mình câu mở đầu." }],
      },
    ]);
  });
});

describe("sanitizeMessageContent", () => {
  it("trims whitespace and rejects empty messages", () => {
    expect(sanitizeMessageContent("  xin chào  ")).toBe("xin chào");
    expect(() => sanitizeMessageContent("   ")).toThrow("Message is empty");
  });
});
