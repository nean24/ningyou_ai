import bcrypt from "bcryptjs";
import { httpRouter } from "convex/server";

import { httpAction } from "./_generated/server";
import { api, internal } from "./_generated/api";

function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

function clientIp(request: Request): string {
  return (
    request.headers.get("x-forwarded-for")?.split(",")[0]?.trim() ??
    request.headers.get("x-real-ip") ??
    "unknown"
  );
}

const LIMITS = {
  register: { maxRequests: 5,  windowMs: 60 * 60 * 1000 },  // 5 / hour
  signin:   { maxRequests: 10, windowMs: 15 * 60 * 1000 },  // 10 / 15 min
  google:   { maxRequests: 20, windowMs: 60 * 60 * 1000 },  // 20 / hour
} as const;

const http = httpRouter();

// ---------------------------------------------------------------------------
// POST /auth/google/signin
// ---------------------------------------------------------------------------
http.route({
  path: "/auth/google/signin",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const ip = clientIp(request);
      const rl = await ctx.runMutation(internal.rateLimiter.checkAndIncrement, {
        key: `${ip}:google`,
        ...LIMITS.google,
      });
      if (!rl.allowed) {
        return json({ error: "Too many requests. Please try again later." }, 429);
      }

      const body = await request.json() as { idToken?: string };
      if (!body.idToken) {
        return json({ error: "idToken is required" }, 400);
      }

      const tokenInfoRes = await fetch(
        `https://oauth2.googleapis.com/tokeninfo?id_token=${body.idToken}`,
      );
      const tokenInfo = await tokenInfoRes.json() as {
        error?: string;
        sub?: string;
        email?: string;
        name?: string;
        picture?: string;
        email_verified?: string;
      };

      if (tokenInfo.error || !tokenInfo.sub) {
        return json({ error: "Invalid Google token" }, 401);
      }
      if (tokenInfo.email_verified !== "true") {
        return json({ error: "Email not verified" }, 401);
      }

      const userId = await ctx.runMutation(internal.users.upsertFromGoogle, {
        googleId: tokenInfo.sub,
        email: tokenInfo.email ?? "",
        displayName: tokenInfo.name ?? tokenInfo.email ?? "User",
        avatarUrl: tokenInfo.picture,
      });

      const sessionToken = await ctx.runMutation(internal.sessions.create, { userId });

      return json({ sessionToken, userId });
    } catch (error) {
      console.error("[auth/google/signin]", error);
      return json({ error: "Internal server error" }, 500);
    }
  }),
});

// ---------------------------------------------------------------------------
// POST /auth/validate
// ---------------------------------------------------------------------------
http.route({
  path: "/auth/validate",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    const token = request.headers.get("Authorization")?.replace("Bearer ", "").trim();
    if (!token) return json({ valid: false }, 401);

    const user = await ctx.runQuery(internal.sessions.validate, { token });
    if (!user) return json({ valid: false }, 401);

    return json({ valid: true, userId: user._id });
  }),
});

// ---------------------------------------------------------------------------
// POST /auth/signout
// ---------------------------------------------------------------------------
http.route({
  path: "/auth/signout",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    const token = request.headers.get("Authorization")?.replace("Bearer ", "").trim();
    if (token) {
      await ctx.runMutation(internal.sessions.deleteByToken, { token });
    }
    return json({ success: true });
  }),
});

// ---------------------------------------------------------------------------
// POST /auth/email/register
// ---------------------------------------------------------------------------
http.route({
  path: "/auth/email/register",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const ip = clientIp(request);
      const rl = await ctx.runMutation(internal.rateLimiter.checkAndIncrement, {
        key: `${ip}:register`,
        ...LIMITS.register,
      });
      if (!rl.allowed) {
        return json({ error: "Too many requests. Please try again later." }, 429);
      }

      const body = await request.json() as {
        email?: string;
        password?: string;
        displayName?: string;
      };
      const { email, password, displayName } = body;

      if (!email || !password || !displayName) {
        return json({ error: "email, password, and displayName are required" }, 400);
      }
      if (password.length < 8) {
        return json({ error: "Password must be at least 8 characters" }, 400);
      }

      const existing = await ctx.runQuery(internal.users.getByEmail, {
        email: email.toLowerCase(),
      });
      if (existing) {
        return json({ error: "Email already registered" }, 409);
      }

      const passwordHash = await bcrypt.hash(password, 12);
      const userId = await ctx.runMutation(internal.users.createWithEmail, {
        email: email.toLowerCase(),
        displayName: displayName.trim(),
        passwordHash,
      });

      const sessionToken = await ctx.runMutation(internal.sessions.create, { userId });
      return json({ sessionToken, userId }, 201);
    } catch (error) {
      console.error("[auth/email/register]", error);
      return json({ error: "Internal server error" }, 500);
    }
  }),
});

// ---------------------------------------------------------------------------
// POST /auth/email/signin
// ---------------------------------------------------------------------------
http.route({
  path: "/auth/email/signin",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const ip = clientIp(request);
      const rl = await ctx.runMutation(internal.rateLimiter.checkAndIncrement, {
        key: `${ip}:signin`,
        ...LIMITS.signin,
      });
      if (!rl.allowed) {
        return json({ error: "Too many requests. Please try again later." }, 429);
      }

      const body = await request.json() as { email?: string; password?: string };
      const { email, password } = body;

      if (!email || !password) {
        return json({ error: "email and password are required" }, 400);
      }

      const user = await ctx.runQuery(internal.users.getByEmail, {
        email: email.toLowerCase(),
      });

      // Same error whether email doesn't exist or password is wrong
      if (!user || !user.passwordHash) {
        return json({ error: "Invalid email or password" }, 401);
      }
      const valid = await bcrypt.compare(password, user.passwordHash);
      if (!valid) {
        return json({ error: "Invalid email or password" }, 401);
      }

      const sessionToken = await ctx.runMutation(internal.sessions.create, {
        userId: user._id,
      });
      return json({ sessionToken, userId: user._id, displayName: user.displayName });
    } catch (error) {
      console.error("[auth/email/signin]", error);
      return json({ error: "Internal server error" }, 500);
    }
  }),
});

// ---------------------------------------------------------------------------
// POST /users/avatar-upload-url
// Returns a short-lived Convex Storage upload URL.
// ---------------------------------------------------------------------------
http.route({
  path: "/users/avatar-upload-url",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    const token = request.headers.get("Authorization")?.replace("Bearer ", "").trim();
    if (!token) return json({ error: "Unauthorized" }, 401);

    const user = await ctx.runQuery(internal.sessions.validate, { token });
    if (!user) return json({ error: "Unauthorized" }, 401);

    const uploadUrl = await ctx.runMutation(internal.profile.generateAvatarUploadUrl, {});
    return json({ uploadUrl });
  }),
});

// ---------------------------------------------------------------------------
// PATCH /users/profile
// Body: { displayName?: string, avatarStorageId?: string }
// ---------------------------------------------------------------------------
http.route({
  path: "/users/profile",
  method: "PATCH",
  handler: httpAction(async (ctx, request) => {
    const token = request.headers.get("Authorization")?.replace("Bearer ", "").trim();
    if (!token) return json({ error: "Unauthorized" }, 401);

    const user = await ctx.runQuery(internal.sessions.validate, { token });
    if (!user) return json({ error: "Unauthorized" }, 401);

    const body = await request.json() as {
      displayName?: string;
      avatarStorageId?: string;
    };

    const result = await ctx.runMutation(internal.profile.updateProfile, {
      userId: user._id,
      displayName: body.displayName,
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      avatarStorageId: body.avatarStorageId as any,
    });

    return json({ success: true, avatarUrl: result.avatarUrl });
  }),
});

// ---------------------------------------------------------------------------
// GET /characters  (public, no auth required)
// ---------------------------------------------------------------------------
http.route({
  path: "/characters",
  method: "GET",
  handler: httpAction(async (ctx, _request) => {
    try {
      const characters = await ctx.runQuery(api.characters.listPublic, { limit: 50 });
      return json({ characters });
    } catch (error) {
      console.error("[GET /characters]", error);
      return json({ error: "Internal server error" }, 500);
    }
  }),
});

// ---------------------------------------------------------------------------
// POST /characters/get  { id: string }
// ---------------------------------------------------------------------------
http.route({
  path: "/characters/get",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const body = await request.json() as { id?: string };
      if (!body.id) return json({ error: "id is required" }, 400);
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const character = await ctx.runQuery(api.characters.get, { characterId: body.id as any });
      if (!character) return json({ error: "Not found" }, 404);
      return json({ character });
    } catch (error) {
      console.error("[POST /characters/get]", error);
      return json({ error: "Internal server error" }, 500);
    }
  }),
});

export default http;
