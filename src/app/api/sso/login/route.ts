import { NextRequest, NextResponse } from 'next/server';
import { ssoAuthentication } from '@/lib/auth';

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const redirectUrl = searchParams.get('redirect_url') || '/dashboard';

    const authUrl = await ssoAuthentication(redirectUrl);
    return NextResponse.redirect(authUrl);
  } catch {
    // console.error('SSO login error:', error);
    return NextResponse.redirect(new URL('/signin?error=sso_error', request.url));
  }
}
