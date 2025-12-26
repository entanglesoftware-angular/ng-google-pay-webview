import { WebPlugin } from '@capacitor/core';

import type { NgGooglePayWebviewPlugin } from './definitions';

export class NgGooglePayWebviewWeb extends WebPlugin implements NgGooglePayWebviewPlugin {
  async setup(): Promise<void> {
    // no-op for web
  }
}
