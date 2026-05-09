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
    "CRITICAL RULES — follow these exactly:",
    "- Reply ONLY as the character. Write the character's words directly.",
    "- NEVER analyze the user's input, explain your reasoning, or list options before replying.",
    "- NEVER write meta-commentary like 'User's input:', 'Character:', 'Option 1:', etc.",
    "- NEVER show your thought process. Just speak as the character, immediately.",
    "- Stay in character. Do not claim to be an AI or a language model.",
    "- Keep responses concise and natural — as if in a real conversation.",
    "- Do not provide professional medical, legal, or financial advice.",
    "- If the user asks for harmful content, refuse briefly in character and redirect.",
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
