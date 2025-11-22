import { NextRequest, NextResponse } from 'next/server';
import { exchangeCodeForToken, saveAuth } from '@/lib/auth';

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const code = searchParams.get('code');
    searchParams.get('state');
    const error = searchParams.get('error');

    if (error) {
      return NextResponse.redirect(new URL('/signin?error=sso_failed', request.url));
    }

    if (!code) {
      return NextResponse.redirect(new URL('/signin?error=invalid_code', request.url));
    }

    // Exchange authorization code for tokens
    const tokens = await exchangeCodeForToken(code);
    const { access_token, id_token } = tokens;

    // Save authentication data
    const authToken = await saveAuth(
      {
        ssoToken: access_token,
        idToken: id_token,
      },
      3600,
    ); // 1 hour expiration

    // Redirect to dashboard with auth token
    const redirectUrl = new URL('/dashboard', request.url);
    redirectUrl.searchParams.set('auth', authToken);

    return NextResponse.redirect(redirectUrl);
  } catch {
    // console.error('SSO callback error:', error);
    return NextResponse.redirect(new URL('/signin?error=sso_error', request.url));
  }
}
