import Foundation

/// Single place to change the backend URL.
///
/// Simulator: `http://127.0.0.1:8000` talks to uvicorn on your Mac.
/// Physical iPhone: 127.0.0.1 is the *phone*, not your Mac.
/// Change `baseURL` to `http://YOUR_MAC_LAN_IP:8000` for same-Wi-Fi testing,
/// or to the hosted HTTPS URL for the multi-device demo.
enum APIConfig {
    static let baseURL = URL(string: "http://127.0.0.1:8000")!
}
