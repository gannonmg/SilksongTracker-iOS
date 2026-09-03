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
            Text("Hello, world!")
                .padding()
                .background(.red)
        }
        .border(.green)
    }
}

#Preview {
    ContentView()
}
