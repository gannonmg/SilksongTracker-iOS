import SwiftUI

@main struct MyApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
    }
}

struct ContentView: View {
    var body: some View {
        TiledMapScrollView(tileSet: .silksong)
    }
}

#Preview {
    ContentView()
}
