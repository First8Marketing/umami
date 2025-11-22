import debug from 'debug';
import {
  ROLE_PERMISSIONS,
  ROLES,
  SHARE_TOKEN_HEADER,
  SSO_TOKEN_HEADER,
  SSO_ISSUER,
  SSO_CLIENT_ID,
  SSO_JWKS_ENDPOINT,
  SSO_AUTH_ENDPOINT,
  SSO_TOKEN_ENDPOINT,
  SSO_REDIRECT_URI,
} from '@/lib/constants';
import { secret } from '@/lib/crypto';
import { getRandomChars } from '@/lib/generate';
import { createSecureToken, parseSecureToken, parseToken } from '@/lib/jwt';
import { ensureArray } from '@/lib/utils';
import redis from '@/lib/redis';
import { getUser, getUserByEmail, createUser } from '@/queries/prisma/user';
import { jwtVerify } from 'jose';

const log = debug('umami:auth');

export function getBearerToken(request: Request) {
  const auth = request.headers.get('authorization');
  return auth?.split(' ')[1];
}

export function getSSOToken(request: Request) {
  return request.headers.get(SSO_TOKEN_HEADER);
}

export async function checkAuth(request: Request) {
  const token = getBearerToken(request);
  const ssoToken = getSSOToken(request);
  const payload = parseSecureToken(token, secret());
  const shareToken = await parseShareToken(request);

  let user = null;
  const { userId, authKey } = payload || {};

  // Check SSO token first
  if (ssoToken) {
    user = await validateSSOToken(ssoToken);
  } else if (userId) {
    user = await getUser(userId);
  } else if (redis.enabled && authKey) {
    const key = await redis.client.get(authKey);
    if (key?.userId) {
      user = await getUser(key.userId);
    }
  }

  log({ token, ssoToken, payload, authKey, shareToken, user });

  if (!user?.id && !shareToken) {
    log('User not authorized');
    return null;
  }

  if (user) {
    user.isAdmin = user.role === ROLES.admin;
  }

  return {
    token,
    ssoToken,
    authKey,
    shareToken,
    user,
  };
}

export async function validateSSOToken(token: string) {
  try {
    // Fetch JWKS keys from SSO server
    const jwksResponse = await fetch(SSO_JWKS_ENDPOINT);
    const jwks = await jwksResponse.json();

    // Find the signing key
    const { payload } = await jwtVerify(
      token,
      async header => {
        const key = jwks.keys.find((k: any) => k.kid === header.kid);
        if (!key) throw new Error('Key not found');

        const publicKey = await importJWK(key, 'RS256');
        return publicKey;
      },
      {
        issuer: SSO_ISSUER,
        audience: SSO_CLIENT_ID,
      },
    );

    // Extract user information from token
    const { sub, email, name, picture } = payload;

    // Find or create user in Umami database
    let user = await getUserByEmail(email as string);

    if (!user) {
      // Create new user with SSO information
      user = await createUser({
        email: email as string,
        username: email as string,
        password: null, // No password for SSO users
        role: ROLES.user,
        name: (name as string) || (email as string),
        picture: (picture as string) || null,
        ssoSubject: sub as string,
      });
    } else if (!user.ssoSubject) {
      // Update existing user with SSO subject
      // Note: updateUser function needs to be imported from queries
      const { updateUser } = await import('@/queries/prisma/user');
      user = await updateUser(user.id, { ssoSubject: sub as string });
    }

    return user;
  } catch (error) {
    log('SSO token validation failed:', error);
    return null;
  }
}

export async function ssoAuthentication(redirectUrl?: string) {
  const authUrl = new URL(SSO_AUTH_ENDPOINT);
  authUrl.searchParams.set('client_id', SSO_CLIENT_ID);
  authUrl.searchParams.set('redirect_uri', redirectUrl || SSO_REDIRECT_URI);
  authUrl.searchParams.set('response_type', 'code');
  authUrl.searchParams.set('scope', 'openid profile email');
  authUrl.searchParams.set('state', generateState());

  return authUrl.toString();
}

export async function exchangeCodeForToken(code: string) {
  const response = await fetch(SSO_TOKEN_ENDPOINT, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'authorization_code',
      code,
      redirect_uri: SSO_REDIRECT_URI,
      client_id: SSO_CLIENT_ID,
    }),
  });

  if (!response.ok) {
    throw new Error('Failed to exchange code for token');
  }

  const tokens = await response.json();
  return tokens;
}

export async function saveAuth(data: any, expire = 0) {
  const authKey = `auth:${getRandomChars(32)}`;

  if (redis.enabled) {
    await redis.client.set(authKey, data);

    if (expire) {
      await redis.client.expire(authKey, expire);
    }
  }

  return createSecureToken({ authKey }, secret());
}

export async function hasPermission(role: string, permission: string | string[]) {
  return ensureArray(permission).some(e => ROLE_PERMISSIONS[role]?.includes(e));
}

export function parseShareToken(request: Request) {
  try {
    return parseToken(request.headers.get(SHARE_TOKEN_HEADER), secret());
  } catch (e) {
    log(e);
    return null;
  }
}

function generateState() {
  return getRandomChars(32);
}

async function importJWK(jwk: any) {
  return await crypto.subtle.importKey(
    'jwk',
    jwk,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['verify'],
  );
}
