export const rateLimitWindows = {
  aiMessage: {
    windowMs: 60_000,
    maxRequests: 20,
  },
} as const;
