export interface SpotifyAuthPlugin {
  /**
   * Authenticate with Spotify. On Android/iOS, opens the Spotify app if installed,
   * otherwise falls back to a web-based login. On web, redirects to Spotify OAuth page.
   */
  authorize(options: SpotifyAuthOptions): Promise<SpotifyAuthResult>;

  /**
   * Log out and clear any cached Spotify session tokens.
   */
  logout(): Promise<void>;
}

export interface SpotifyAuthOptions {
  /** Spotify application Client ID. */
  clientId: string;
  /** OAuth redirect URI registered in Spotify Developer Dashboard. */
  redirectUri: string;
  /** OAuth scopes to request (space-separated). */
  scopes: string;
  /** Token swap URL (optional — for Authorization Code flow with backend exchange). */
  tokenSwapUrl?: string;
}

export interface SpotifyAuthResult {
  /** Authorization code (use with Authorization Code flow). */
  code: string;
  /** State parameter if provided. */
  state?: string;
}
