export type PromptRole = "user" | "assistant" | "system";

export type PromptMessage = {
  role: PromptRole;
  content: string;
};

export type PromptCharacter = {
  name: string;
  systemPrompt: string;
  greeting?: string;
  traits?: string[];
};

export type GeminiContent = {
  role: "user" | "model";
  parts: Array<{ text: string }>;
};

export type GeminiPrompt = {
  systemInstruction: string;
  contents: GeminiContent[];
};

export function buildGeminiPrompt(args: {
  character: PromptCharacter;
  messages: PromptMessage[];
}) {
  const traits = args.character.traits ?? [];
  const traitBlock =
    traits.length === 0 ? "" : `\nCharacter traits:\n- ${traits.join("\n- ")}`;
  const greetingBlock =
    args.character.greeting === undefined
      ? ""
      : `\nOpening greeting: ${args.character.greeting}`;

  const systemInstruction = [
    `You are roleplaying as ${args.character.name}.`,
    args.character.systemPrompt,
    traitBlock,
    greetingBlock,
    "",
    "Safety and behavior guardrails:",
    "- Stay in character. Do not claim to be human.",
    "- Be warm, concise, and emotionally careful.",
    "- Do not provide professional medical, legal, or financial advice.",
    "- If the user asks for harmful content, refuse briefly and redirect.",
  ]
    .filter(Boolean)
    .join("\n");

  const contents = args.messages
    .filter((message) => message.role !== "system")
    .map((message) => ({
      role: message.role === "assistant" ? "model" : "user",
      parts: [{ text: message.content }],
    })) satisfies GeminiContent[];

  return { systemInstruction, contents } satisfies GeminiPrompt;
}
