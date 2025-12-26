#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

// IMPORTANT:
// First param = Swift class name *without* module prefix
// Second param = JS plugin name (must match registerPlugin('NgGooglePayWebview'))
// Then list methods you want callable from JS (even if you auto-run in load()).

CAP_PLUGIN(NgGooglePayWebviewPlugin, "NgGooglePayWebview",
           CAP_PLUGIN_METHOD(setup, CAPPluginReturnPromise);
)