import { cronJobs } from "convex/server";

import { internal } from "./_generated/api";

const crons = cronJobs();

crons.weekly(
  "delete expired sessions",
  { dayOfWeek: "sunday", hourUTC: 3, minuteUTC: 0 },
  internal.sessions.deleteExpired,
  {},
);

// Every hour — purge rate-limit records older than 2 hours.
crons.hourly(
  "delete stale rate limit records",
  { minuteUTC: 30 },
  internal.rateLimiter.deleteStale,
  { olderThanMs: 2 * 60 * 60 * 1000 },
);

export default crons;
