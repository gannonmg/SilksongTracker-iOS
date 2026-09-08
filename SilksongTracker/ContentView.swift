import SwiftUI

@main struct MyApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
    }
}

struct ContentView: View {
    var body: some View {
        TiledMapScrollView()
    }
}

#Preview {
    ContentView()
}
