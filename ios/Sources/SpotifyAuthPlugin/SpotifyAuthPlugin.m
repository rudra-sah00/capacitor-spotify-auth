#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

CAP_PLUGIN(SpotifyAuthPlugin, "SpotifyAuth",
    CAP_PLUGIN_METHOD(authorize, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(logout, CAPPluginReturnPromise);
)
