# capacitor-spotify-auth

Capacitor plugin for Spotify OAuth authentication with native platform support.

- **Android**: Uses Spotify `auth-lib` SDK — opens Spotify app for SSO if installed, falls back to in-app WebView
- **iOS**: Uses `ASWebAuthenticationSession` — shows native auth sheet with Spotify login, supports saved Safari credentials
- **Web**: Standard OAuth redirect flow

## Install

```bash
npm install capacitor-spotify-auth
npx cap sync
```

## Setup

### Spotify Developer Dashboard

1. Create an app at https://developer.spotify.com/dashboard
2. Add your redirect URIs
3. **Android**: Add your SHA-1 fingerprint and package name under Android Packages
4. **iOS**: Add your Bundle ID under iOS settings

### Android

No additional setup needed. The plugin uses Spotify's `auth-lib` which handles everything automatically.

### iOS

Add your custom URL scheme to `Info.plist` so Spotify can redirect back to your app:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>your-app-scheme</string>
    </array>
  </dict>
</array>
```

## Usage

```typescript
import { SpotifyAuth } from 'capacitor-spotify-auth';

// Authenticate
const result = await SpotifyAuth.authorize({
  clientId: 'your-spotify-client-id',
  redirectUri: 'your-app-scheme://spotify/callback',
  scopes: 'playlist-read-private playlist-read-collaborative',
});

console.log(result.code); // Authorization code to exchange for access token

// Logout
await SpotifyAuth.logout();
```

## API

### authorize(options)

| Param | Type | Description |
|-------|------|-------------|
| clientId | `string` | Spotify app Client ID |
| redirectUri | `string` | OAuth redirect URI |
| scopes | `string` | Space-separated OAuth scopes |

**Returns**: `Promise<{ code: string; state?: string }>`

### logout()

Clears cached Spotify auth session.

**Returns**: `Promise<void>`

## Platform Behavior

| Platform | Spotify Installed | Spotify Not Installed |
|----------|-------------------|----------------------|
| Android | Opens Spotify app → instant SSO | In-app WebView login |
| iOS | ASWebAuthenticationSession (uses saved Safari credentials) | Same (login form shown) |
| Web | Redirect to accounts.spotify.com | Same |

## License

MIT
