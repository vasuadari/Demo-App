import SwiftUI

@main
struct StudentsApp: App {
    @StateObject private var store = StudentStore()

    var body: some Scene {
        WindowGroup {
            StudentsListView()
                .environmentObject(store)
                .preferredColorScheme(.light)
        }
    }
}
