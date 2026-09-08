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
    private enum MapDataState {
        case loading, loaded(MapData), error(any Error)
    }

    @State private var mapDataState = MapDataState.loading

    var body: some View {
        Group {
            switch mapDataState {
            case .loading:
                Text("Loading Map Data")
            case .loaded(let mapData):
                MapContentView()
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
        HStack {
            TiledMapScrollView()
                .layoutPriority(1)
            MapSidebar()
                .fixedSize(horizontal: true, vertical: false)
        }
    }
}

struct MapSidebar: View {
    @Environment(MapDataViewModel.self) var viewModel

    var body: some View {
        let mapData = viewModel.mapData
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(MarkerCategoryGroup.allCases) { group in
                    Text("\(group.rawValue.capitalized) (\(group.categories.count))")

                    ForEach(group.categories) { category in
                        let count = mapData.markers[category]?.count ?? -1
                        Text("\(category.rawValue.capitalized) (\(count))")
                            .padding(.leading)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    ContentView()
}
