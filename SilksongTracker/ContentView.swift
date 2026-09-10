import SwiftUI
import TipKit

@main
struct MyApp: App {
    init() {
        do {
            // Configure and load all tips in the app
            try Tips.configure()
        }
        catch {
            print("Error initializing tips: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup { ContentView() }
    }
}

struct ContentView: View {
    var body: some View {
        MapDataStagingView {
            MapContentView()
        }
    }
}


struct MapDataStagingView<Content: View>: View {
    private enum MapDataState {
        case loading, loaded(MapData), error(any Error)
    }

    @State private var mapDataState = MapDataState.loading

    @ContentBuilder let content: () -> Content

    var body: some View {
        Group {
            switch mapDataState {
            case .loading:
                Text("Loading Map Data")
            case .loaded(let mapData):
                content()
                    .environment(MapDataViewModel(mapData: mapData))
            case .error(let error):
                Text("Failed to load map data: \(error.localizedDescription)")
            }
        }
        .onAppear {
            switch SWImporter.importMapData() {
            case .success(let scriptersData):
                let mapData = MapDataFactory.buildMapData(from: scriptersData)
                self.mapDataState = .loaded(mapData)
            case .failure(let error):
                print(error)
                self.mapDataState = .error(error)
            }
        }
    }
}


struct MapContentView: View {
    var body: some View {
        NavigationSplitView {
            SidebarView()
        } detail: {
            TiledMapScrollView()
                .background(.black)
        }
    }
}

#Preview {
    ContentView()
}
