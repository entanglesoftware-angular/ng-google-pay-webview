import { registerPlugin } from '@capacitor/core';

import type { NgGooglePayWebviewPlugin } from './definitions';

const NgGooglePayWebview = registerPlugin<NgGooglePayWebviewPlugin>('NgGooglePayWebview', {
  web: () => import('./web').then((m) => new m.NgGooglePayWebviewWeb()),
});

export * from './definitions';
export { NgGooglePayWebview };
