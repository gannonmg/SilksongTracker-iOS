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

    // MARK: - Zooming
    private let liveZoomRange: ClosedRange<CGFloat> = 1...4
    private let effectiveZoomRange: ClosedRange<CGFloat> = 1...12
    private let defaultZoomScale: CGFloat = 2
    private let zoomInResetThreshold: CGFloat = 2.75
    private let zoomOutResetThreshold: CGFloat = 1.25

    private var zoomRange: ClosedRange<CGFloat> {
        let remainingZoomIn = effectiveZoomRange.upperBound / effectiveContentScale
        let upperBound = min(liveZoomRange.upperBound, remainingZoomIn)
        return liveZoomRange.lowerBound...max(liveZoomRange.lowerBound, upperBound)
    }

    @State private var zoomResetCommit: ZoomResetCommit?
    @State private var effectiveContentScale: CGFloat = 1
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
            TiledMapContent(
                tileSet: tileSet,
                currentResolution: currentResolution,
                effectiveContentScale: effectiveContentScale,
                overlay: overlay
            )
        }
    }

    // MARK: Zoom
    private func onZoomEvent(_ event: ZoomEvent) {
        let rawTotalScale = effectiveContentScale * event.scale
        guard rawTotalScale <= effectiveZoomRange.upperBound else { return }

        let desiredResolution = TileResolutionLevel.preferredResolution(for: rawTotalScale)

        let beyondZoomInThreshold = zoomInResetThreshold <= event.scale
        let belowZoomOutThreshold = event.scale <= zoomOutResetThreshold

        let shouldCommitScale = beyondZoomInThreshold ||
        (effectiveZoomRange.lowerBound < effectiveContentScale && belowZoomOutThreshold)

        guard shouldCommitScale || desiredResolution != currentResolution else { return }

        let targetZoomScale = min(defaultZoomScale, max(1, rawTotalScale))
        effectiveContentScale = rawTotalScale / targetZoomScale
        currentResolution = desiredResolution

        zoomResetCommit = ZoomResetCommit(
            previousId: zoomResetCommit?.id,
            event: event,
            targetZoomScale: targetZoomScale
        )
    }
}

struct TiledMapContent<Overlay: View>: View {

    @State private var imageCache = TileImageCache()

    let tileSet: TileSet
    let currentResolution: TileResolutionLevel
    let effectiveContentScale: CGFloat
    let overlay: () -> Overlay

    @Environment(\.scrollViewport) private var scrollViewport

    var body: some View {
        let contentSize = tileSet.contentSize(effectiveScale: effectiveContentScale)
        let tiles = tileSet.visibileTiles(
            in: scrollViewport,
            at: currentResolution,
            contentSize: contentSize
        )

        ZStack {
            ForEach(tiles) { tile in
                canvas(for: tile, in: contentSize)
            }

            overlay()
        }
        .frame(size: contentSize)
        .contentShape(.rect)
    }


    @ContentBuilder
    private func canvas(for tile: MapTile, in contentSize: CGSize) -> some View {
        let frame = tile.frame(in: contentSize)

        Canvas { context, size in
            guard let image = imageCache.cachedImage(for: tile.id) else { return }
            let bounds = CGRect(origin: .zero, size: size)
            context.draw(Image(uiImage: image), in: bounds)
        }
        .frame(width: frame.width, height: frame.height)
        .position(x: frame.midX, y: frame.midY)
        .task(id: tile.id) {
            await imageCache.loadImage(for: tile.id)
        }
    }
}

struct TileSet: Hashable, Sendable {
    static let silksong = TileSet(id: "silksong", accessibilityLabel: "Silksong map")

    let id: String
    let accessibilityLabel: String

    func contentSize(effectiveScale: CGFloat) -> CGSize {
        let contentEdgeLength = Constants.tileSideLength * effectiveScale
        return CGSize(width: contentEdgeLength, height: contentEdgeLength)
    }

    private func bufferedVisibleRect(from viewport: CGRect, contentSize: CGSize) -> CGRect {
        let contentRect = CGRect(origin: .zero, size: contentSize)
        guard !viewport.isEmpty else { return contentRect }

        let bufferInset = UIEdgeInsets(all: -128)
        return viewport
            .inset(by: bufferInset)
            .intersection(contentRect)
    }

    func visibileTiles(
        in viewport: CGRect,
        at resolution: TileResolutionLevel,
        contentSize: CGSize
    ) -> [MapTile] {
        let tileLength = contentSize.width / CGFloat(resolution.edgeTileCount)
        let rect = bufferedVisibleRect(from: viewport, contentSize: contentSize)

        guard !rect.isNull else { return [] }

        let minX = max(0, Int(floor(rect.minX / tileLength)))
        let maxX = min(resolution.edgeTileCount - 1, Int(floor((rect.maxX - 1) / tileLength)))
        let minY = max(0, Int(floor(rect.minY / tileLength)))
        let maxY = min(resolution.edgeTileCount - 1, Int(floor((rect.maxY - 1) / tileLength)))

        guard minX <= maxX, minY <= maxY else { return [] }

        let tiles = (minY...maxY).flatMap { y in
            (minX...maxX).map { x in
                MapTile(id: MapTileID(level: resolution, x: x, y: y))
            }
        }
        print("\(tiles.count) visible tiles")
        return tiles
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

    // TiledMapScrollView.swift, line 194, replacing `var frame`
    func frame(in contentSize: CGSize) -> CGRect {
        let tileSideLength = contentSize.width / CGFloat(id.level.edgeTileCount)

        return CGRect(
            x: CGFloat(id.x) * tileSideLength,
            y: CGFloat(id.y) * tileSideLength,
            width: tileSideLength,
            height: tileSideLength
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
