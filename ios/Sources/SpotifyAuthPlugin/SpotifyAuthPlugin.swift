import Foundation
import Capacitor
import AuthenticationServices

@objc(SpotifyAuthPlugin)
public class SpotifyAuthPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "SpotifyAuthPlugin"
    public let jsName = "SpotifyAuth"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "authorize", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "logout", returnType: CAPPluginReturnPromise)
    ]

    private var authSession: ASWebAuthenticationSession?

    @objc func authorize(_ call: CAPPluginCall) {
        guard let clientId = call.getString("clientId"),
              let redirectUri = call.getString("redirectUri") else {
            call.reject("clientId and redirectUri are required")
            return
        }

        let scopes = call.getString("scopes") ?? ""
        let state = UUID().uuidString

        var components = URLComponents(string: "https://accounts.spotify.com/authorize")!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "redirect_uri", value: redirectUri),
            URLQueryItem(name: "scope", value: scopes),
            URLQueryItem(name: "state", value: state)
        ]

        guard let authURL = components.url else {
            call.reject("Failed to build auth URL")
            return
        }

        guard let callbackScheme = URL(string: redirectUri)?.scheme else {
            call.reject("Invalid redirectUri scheme")
            return
        }

        DispatchQueue.main.async { [weak self] in
            let session = ASWebAuthenticationSession(
                url: authURL,
                callbackURLScheme: callbackScheme
            ) { callbackURL, error in
                self?.authSession = nil

                if let error = error {
                    if (error as NSError).code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
                        call.reject("Spotify auth cancelled")
                    } else {
                        call.reject("Spotify auth error: \(error.localizedDescription)")
                    }
                    return
                }

                guard let callbackURL = callbackURL,
                      let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
                      let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
                    call.reject("No authorization code received")
                    return
                }

                let returnedState = components.queryItems?.first(where: { $0.name == "state" })?.value

                call.resolve([
                    "code": code,
                    "state": returnedState ?? ""
                ])
            }

            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = true
            self?.authSession = session
            session.start()
        }
    }

    @objc func logout(_ call: CAPPluginCall) {
        let cookieStore = HTTPCookieStorage.shared
        if let cookies = cookieStore.cookies {
            for cookie in cookies where cookie.domain.contains("spotify.com") {
                cookieStore.deleteCookie(cookie)
            }
        }
        call.resolve()
    }
}

extension SpotifyAuthPlugin: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return bridge?.webView?.window ?? ASPresentationAnchor()
    }
}
