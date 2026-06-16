import { registerPlugin } from '@capacitor/core';
import type { SpotifyAuthPlugin } from './definitions';

const SpotifyAuth = registerPlugin<SpotifyAuthPlugin>('SpotifyAuth', {
  web: () => import('./web').then((m) => new m.SpotifyAuthWeb()),
});

export * from './definitions';
export { SpotifyAuth };
