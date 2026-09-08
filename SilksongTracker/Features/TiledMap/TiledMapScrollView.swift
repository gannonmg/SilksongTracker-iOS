//
//  TiledMapScrollView.swift
//  SilksongTracker
//
//  Created by Matt Gannon on 9/7/26.
//

import SwiftUI
import ZoomableScrollView

struct TiledMapScrollView<Overlay: View>: View {
    let tileSet: TileSet
    let overlay: () -> Overlay

    @Environment(\.scrollViewport) private var scrollViewport

    // MARK: - Cache
    @State private var images: [MapTileID: UIImage] = [:]
    @State private var loadingIDs: Set<MapTileID> = []
    @State private var missingIDs: Set<MapTileID> = []

    // MARK: - Zooming
    private let zoomRange: ClosedRange<CGFloat> = 0.8...5
    @State private var zoomResetCommit: ZoomResetCommit?
    @State private var effectiveZoomScale: CGFloat = 1
    @State private var currentResolution: TileResolutionLevel = .lowest

    // MARK: - Init
    init(
        tileSet: TileSet,
        @ContentBuilder overlay: @escaping () -> Overlay
    ) {
        self.tileSet = tileSet
        self.overlay = overlay
    }

    // MARK: - Body
    var body: some View {
        ZoomableScrollView(
            zoomRange: zoomRange,
            onZoomEvent: onZoomEvent(_:),
            zoomResetCommit: zoomResetCommit
        ) {
            let tiles = tileSet.visibileTiles(in: scrollViewport, at: currentResolution)
            ZStack {
                ForEach(tiles) { tile in
                    canvas(for: tile)
                }
            }
            .frame(size: tileSet.contentSize(at: currentResolution))
            .contentShape(.rect)
        }
    }

    @ContentBuilder
    private func canvas(for tile: MapTile) -> some View {
        Canvas { context, size in
            guard let image = cachedImage(for: tile.id) else { return }
            let bounds = CGRect(origin: .zero, size: size)
            context.draw(Image(uiImage: image), in: bounds)
        }
        .frame(width: tile.frame.width, height: tile.frame.height)
        .position(x: tile.frame.midX, y: tile.frame.midY)
        .task(id: tile.id) {
            await loadImage(for: tile.id)
        }
    }

    // MARK: Zoom
    private func onZoomEvent(_ event: ZoomEvent) {
        effectiveZoomScale = event.scale
        print("Set scale to \(effectiveZoomScale)")

        let desiredResolution: TileResolutionLevel = .preferredResolution(for: effectiveZoomScale)
        guard desiredResolution != currentResolution else { return }
        self.currentResolution = desiredResolution
//        self.zoomResetCommit = ZoomResetCommit(previousId: zoomResetCommit?.id, event: event)
    }
}

struct TileSet: Hashable, Sendable {
    static let silksong = TileSet(id: "silksong", accessibilityLabel: "Silksong map")

    let id: String
    let accessibilityLabel: String

    func contentSize(at resolution: TileResolutionLevel) -> CGSize {
        let contentEdgeLength = CGFloat(resolution.edgeTileCount) * Constants.tileSideLength
        return CGSize(width: contentEdgeLength, height: contentEdgeLength)
    }

    private func bufferedVisibleRect(from viewport: CGRect, contentSize: CGSize) -> CGRect {
        let contentRect = CGRect(origin: .zero, size: contentSize)
        guard !viewport.isEmpty else { return contentRect }

        let bufferInset = UIEdgeInsets(all: 128)
        return viewport
            .inset(by: bufferInset)
            .intersection(contentRect)
    }

    func visibileTiles(in viewport: CGRect, at resolution: TileResolutionLevel) -> [MapTile] {
        let tileLength = Constants.tileSideLength
        let contentSize = contentSize(at: resolution)
        let rect = bufferedVisibleRect(from: viewport, contentSize: contentSize)

        guard !rect.isNull else { return [] }

        let minX = max(0, Int(floor(rect.minX / tileLength)))
        let maxX = min(resolution.edgeTileCount - 1, Int(floor((rect.maxX - 1) / tileLength)))
        let minY = max(0, Int(floor(rect.minY / tileLength)))
        let maxY = min(resolution.edgeTileCount - 1, Int(floor((rect.maxY - 1) / tileLength)))

        guard minX <= maxX, minY <= maxY else { return [] }

        return (minY...maxY).flatMap { y in
            (minX...maxX).map { x in
                MapTile(id: MapTileID(level: resolution, x: x, y: y))
            }
        }
    }
}

// MARK: - Empty Overlay
extension TiledMapScrollView where Overlay == EmptyView {
    init(tileSet: TileSet) {
        self.init(tileSet: tileSet) {
            EmptyView()
        }
    }
}

// MARK: - Cache Functions
extension TiledMapScrollView {
    func cachedImage(for id: MapTileID) -> UIImage? {
        images[id]
    }

    /// Seeks a lower resolution version of the current tile as a placeholder
    func bestPlaceholder(for ids: [MapTileID]) -> (id: MapTileID, image: UIImage)? {
        ids.compactMap { id in self.images[id].map { (id, $0) } }.first
    }

    func loadBestAvailablePlaceholders(_ ids: [MapTileID]) async {
        for id in ids.reversed() {
            guard !Task.isCancelled else { return }
            await loadImage(for: id)
        }
    }

    func loadImage(for id: MapTileID) async {
        guard images[id] == nil, !loadingIDs.contains(id), !missingIDs.contains(id) else { return }

        loadingIDs.insert(id)
        defer { loadingIDs.remove(id) }

        guard let url = Bundle.main.url(
            forResource: id.resourceName,
            withExtension: "webp"
        ) else {
            missingIDs.insert(id)
            return
        }

        guard !Task.isCancelled, let image = UIImage(contentsOfFile: url.path) else { return }
        images[id] = image
    }
}

// MARK: - MapTileID
struct MapTileID: Hashable, Sendable {
    let level: TileResolutionLevel
    let x: Int
    let y: Int

    var resourceName: String {
        "\(level.rawValue)_\(x)_\(y)"
    }
}

enum Constants {
    static let tileSideLength: CGFloat = 1024
    static let tileSize = CGSize(width: tileSideLength, height: tileSideLength)
}

// MARK: - MapTile
struct MapTile: Identifiable, Hashable, Sendable {
    let id: MapTileID

    var frame: CGRect {
        return CGRect(
            x: CGFloat(id.x) * Constants.tileSideLength,
            y: CGFloat(id.y) * Constants.tileSideLength,
            width: Constants.tileSideLength,
            height: Constants.tileSideLength
        )
    }
}

extension UIEdgeInsets {
    init(all value: CGFloat) {
        self.init(top: value, left: value, bottom: value, right: value)
    }
}

extension View {
    func frame(size: CGSize, alignment: Alignment = .center) -> some View {
        self.frame(width: size.width, height: size.height, alignment: alignment)
    }
}
