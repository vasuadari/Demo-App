import Foundation

enum APIConfiguration {
    /// Point this at your running Rails Demo App.
    /// Simulator → local machine: http://127.0.0.1:3000
    /// Physical device → your Mac’s LAN IP, e.g. http://192.168.1.10:3000
    static var baseURL: URL {
        URL(string: ProcessInfo.processInfo.environment["DEMO_APP_API_URL"] ?? "http://127.0.0.1:3000")!
    }
}
