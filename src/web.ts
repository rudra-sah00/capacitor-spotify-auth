import { WebPlugin } from '@capacitor/core';
import type { SpotifyAuthOptions, SpotifyAuthPlugin, SpotifyAuthResult } from './definitions';

export class SpotifyAuthWeb extends WebPlugin implements SpotifyAuthPlugin {
  async authorize(options: SpotifyAuthOptions): Promise<SpotifyAuthResult> {
    // On web, redirect to Spotify and resolve when we get back
    const state = crypto.randomUUID();
    const params = new URLSearchParams({
      client_id: options.clientId,
      response_type: 'code',
      redirect_uri: options.redirectUri,
      scope: options.scopes,
      state,
    });

    // Check if we're already on the callback URL with a code
    const url = new URL(window.location.href);
    const code = url.searchParams.get('code');
    const returnedState = url.searchParams.get('state');

    if (code) {
      // Clean up URL
      url.searchParams.delete('code');
      url.searchParams.delete('state');
      window.history.replaceState({}, '', url.toString());
      return { code, state: returnedState ?? undefined };
    }

    // Redirect to Spotify
    window.location.href = `https://accounts.spotify.com/authorize?${params.toString()}`;

    // This won't resolve since we're navigating away
    return new Promise(() => {});
  }

  async logout(): Promise<void> {
    // Nothing to clear on web
  }
}
