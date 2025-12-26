# ng-google-pay-webview

A Capacitor plugin that enables **Google Pay Web** inside **Capacitor WebView** on **iOS** and **Android**.

This plugin fixes missing WebView capabilities required by Google Pay when using web-based integrations such as:
- `@google-pay/button-angular`
- Google Pay Web API (`PaymentRequest`, `isReadyToPay()`)

---

## Features

### Android
- Enables `PaymentRequest` in Android WebView using `androidx.webkit`
- Adds required `<queries>` intents for Google Pay
- Works with Capacitor WebView

### iOS
- Appends `GOOGLE_PAY_SUPPORTED` to WKWebView user agent (required for `isReadyToPay()` in WKWebView)
- Supports Google Pay popup flows (`window.open`, `target="_blank"`) using `WKUIDelegate`
- Optional bottom-sheet style popup UI (native)

---

## Installation

```bash
npm install ng-google-pay-webview
npx cap sync
