import type { GeminiContent } from "./prompts";

export const defaultGeminiModel = "gemma-4-31b-it";

export type GeminiGenerateArgs = {
  model?: string;
  systemInstruction: string;
  contents: GeminiContent[];
};

export type GeminiGenerateResult = {
  text: string;
  model: string;
  inputTokens: number;
  outputTokens: number;
};

type GeminiResponse = {
  candidates?: Array<{
    content?: {
      parts?: Array<{ text?: string; thought?: boolean }>;
    };
  }>;
  usageMetadata?: {
    promptTokenCount?: number;
    candidatesTokenCount?: number;
  };
};

export async function generateGeminiText(args: GeminiGenerateArgs) {
  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    throw new Error("Missing GEMINI_API_KEY Convex environment variable");
  }

  const model = args.model ?? defaultGeminiModel;
  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        systemInstruction: {
          parts: [{ text: args.systemInstruction }],
        },
        contents: args.contents,
      }),
    },
  );

  if (!response.ok) {
    const detail = await response.text();
    throw new Error(`Gemini request failed: ${response.status} ${detail}`);
  }

  const data = (await response.json()) as GeminiResponse;

  // Filter out thinking parts (thought: true) — only keep the actual response
  const text =
    data.candidates?.[0]?.content?.parts
      ?.filter((part) => !part.thought)
      .map((part) => part.text ?? "")
      .join("")
      .trim() ?? "";

  if (!text) {
    throw new Error("Gemini returned an empty response");
  }

  return {
    text,
    model,
    inputTokens: data.usageMetadata?.promptTokenCount ?? 0,
    outputTokens: data.usageMetadata?.candidatesTokenCount ?? 0,
  } satisfies GeminiGenerateResult;
}
