//
//  TiledMapContent.swift
//  SilksongTracker
//
//  Created by Matt Gannon on 9/7/26.
//

import SwiftUI
import ZoomableScrollView

struct TiledMapContent<Overlay: View>: View {

    @State private var imageCache = TileImageCache()

    let currentResolution: TileResolutionLevel
    let effectiveContentScale: CGFloat
    let overlay: () -> Overlay

    @Environment(\.scrollViewport) private var scrollViewport

    var body: some View {
        let contentSize = TileSet.contentSize(effectiveScale: effectiveContentScale)
        let tiles = TileSet.visibileTiles(
            in: scrollViewport,
            at: currentResolution,
            contentSize: contentSize
        )

        ZStack {
            ForEach(tiles) { tile in
                MapTileCanvas(tile: tile, contentSize: contentSize)
            }

            overlay()
        }
        .environment(imageCache)
        .frame(size: contentSize)
        .contentShape(.rect)
    }
}
