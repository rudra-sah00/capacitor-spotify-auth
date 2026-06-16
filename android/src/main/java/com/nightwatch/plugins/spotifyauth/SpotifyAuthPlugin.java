package com.nightwatch.plugins.spotifyauth;

import android.app.Activity;
import android.content.Intent;
import androidx.activity.result.ActivityResult;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.ActivityCallback;
import com.getcapacitor.annotation.CapacitorPlugin;
import com.spotify.sdk.android.auth.AuthorizationClient;
import com.spotify.sdk.android.auth.AuthorizationRequest;
import com.spotify.sdk.android.auth.AuthorizationResponse;

@CapacitorPlugin(name = "SpotifyAuth")
public class SpotifyAuthPlugin extends Plugin {

    @PluginMethod
    public void authorize(PluginCall call) {
        String clientId = call.getString("clientId");
        String redirectUri = call.getString("redirectUri");
        String scopes = call.getString("scopes", "");

        if (clientId == null || redirectUri == null) {
            call.reject("clientId and redirectUri are required");
            return;
        }

        AuthorizationRequest.Builder builder = new AuthorizationRequest.Builder(
            clientId,
            AuthorizationResponse.Type.CODE,
            redirectUri
        );
        builder.setScopes(scopes.split("\\s+"));
        builder.setShowDialog(false);

        AuthorizationRequest request = builder.build();

        Intent intent = AuthorizationClient.createLoginActivityIntent(
            getActivity(),
            request
        );

        startActivityForResult(call, intent, "handleAuthResult");
    }

    @ActivityCallback
    private void handleAuthResult(PluginCall call, ActivityResult result) {
        if (call == null) return;

        int resultCode = result.getResultCode();
        Intent data = result.getData();

        AuthorizationResponse response = AuthorizationClient.getResponse(resultCode, data);

        switch (response.getType()) {
            case CODE:
                JSObject ret = new JSObject();
                ret.put("code", response.getCode());
                ret.put("state", response.getState());
                call.resolve(ret);
                break;
            case ERROR:
                call.reject("Spotify auth error: " + response.getError());
                break;
            default:
                call.reject("Spotify auth cancelled");
                break;
        }
    }

    @PluginMethod
    public void logout(PluginCall call) {
        AuthorizationClient.clearCookies(getContext());
        call.resolve();
    }
}
