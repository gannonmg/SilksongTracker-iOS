import SwiftUI
import ZoomableScrollView

@main struct MyApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
    }
}

struct ContentView: View {
    var body: some View {
        ZoomableScrollView {
            MapView(map: .mossGrotto)
        }
    }
}

#Preview {
    ContentView()
}
