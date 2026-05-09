/* eslint-disable */
/**
 * Generated `api` utility.
 *
 * THIS CODE IS AUTOMATICALLY GENERATED.
 *
 * To regenerate, run `npx convex dev`.
 * @module
 */

import type * as ai from "../ai.js";
import type * as characters from "../characters.js";
import type * as conversations from "../conversations.js";
import type * as crons from "../crons.js";
import type * as http from "../http.js";
import type * as lib_gemini from "../lib/gemini.js";
import type * as lib_prompts from "../lib/prompts.js";
import type * as lib_safety from "../lib/safety.js";
import type * as messages from "../messages.js";
import type * as profile from "../profile.js";
import type * as rateLimiter from "../rateLimiter.js";
import type * as rateLimits from "../rateLimits.js";
import type * as seed from "../seed.js";
import type * as sessions from "../sessions.js";
import type * as usageLogs from "../usageLogs.js";
import type * as users from "../users.js";

import type {
  ApiFromModules,
  FilterApi,
  FunctionReference,
} from "convex/server";

declare const fullApi: ApiFromModules<{
  ai: typeof ai;
  characters: typeof characters;
  conversations: typeof conversations;
  crons: typeof crons;
  http: typeof http;
  "lib/gemini": typeof lib_gemini;
  "lib/prompts": typeof lib_prompts;
  "lib/safety": typeof lib_safety;
  messages: typeof messages;
  profile: typeof profile;
  rateLimiter: typeof rateLimiter;
  rateLimits: typeof rateLimits;
  seed: typeof seed;
  sessions: typeof sessions;
  usageLogs: typeof usageLogs;
  users: typeof users;
}>;

/**
 * A utility for referencing Convex functions in your app's public API.
 *
 * Usage:
 * ```js
 * const myFunctionReference = api.myModule.myFunction;
 * ```
 */
export declare const api: FilterApi<
  typeof fullApi,
  FunctionReference<any, "public">
>;

/**
 * A utility for referencing Convex functions in your app's internal API.
 *
 * Usage:
 * ```js
 * const myFunctionReference = internal.myModule.myFunction;
 * ```
 */
export declare const internal: FilterApi<
  typeof fullApi,
  FunctionReference<any, "internal">
>;

export declare const components: {};
