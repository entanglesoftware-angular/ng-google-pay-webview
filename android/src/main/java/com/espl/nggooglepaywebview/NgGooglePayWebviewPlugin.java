package com.espl.nggooglepaywebview;
import android.webkit.WebSettings;
import android.webkit.WebView;

import androidx.webkit.WebSettingsCompat;
import androidx.webkit.WebViewFeature;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

@CapacitorPlugin(name = "NgGooglePayWebview")
public class NgGooglePayWebviewPlugin extends Plugin {

   @Override
  public void load() {
    // Auto-run when plugin loads
    enablePaymentRequest();
  }

  @PluginMethod
  public void setup(PluginCall call) {
    try {
      enablePaymentRequest();
      call.resolve(new JSObject());
    } catch (Exception e) {
      call.reject("Failed to enable PaymentRequest in Android WebView", e);
    }
  }

  private void enablePaymentRequest() {
    WebView webView = getBridge().getWebView();
    if (webView == null) return;

    WebSettings webSettings = webView.getSettings();
    webSettings.setJavaScriptEnabled(true);

    if (WebViewFeature.isFeatureSupported(WebViewFeature.PAYMENT_REQUEST)) {
      WebSettingsCompat.setPaymentRequestEnabled(webSettings, true);
    }
  }

}
