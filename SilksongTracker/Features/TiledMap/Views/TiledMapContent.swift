//
//  TiledMapContent.swift
//  SilksongTracker
//
//  Created by Matt Gannon on 9/7/26.
//

import SwiftUI
import ZoomableScrollView

struct TiledMapContent: View {

    @State private var imageCache = TileImageCache()

    let currentResolution: TileResolutionLevel
    let effectiveContentScale: CGFloat

    @Environment(\.scrollViewport) private var scrollViewport
    @Environment(MapDataViewModel.self) private var viewModel

    var body: some View {
        let contentSize = TileSet.contentSize(effectiveScale: effectiveContentScale)
        let tileLength = contentSize.width / CGFloat(currentResolution.edgeTileCount)

        let tiles = TileSet.visibileTiles(
            in: scrollViewport,
            at: currentResolution,
            contentSize: contentSize
        )

        let markers = viewModel.visibleItems(
            in: scrollViewport,
            at: currentResolution,
            contentSize: contentSize
        )

        ZStack {
            ForEach(tiles) { tile in
                MapTileCanvas(tile: tile, tileLength: tileLength)
            }

            ForEach(markers) { marker in
                MarkerIcon(marker: marker, showName: false)
                    .position(CGPoint(x: marker.location.x * contentSize.width,
                                      y: marker.location.y * contentSize.height))
            }
        }
        .environment(imageCache)
        .frame(size: contentSize)
        .contentShape(.rect)
        .onAppear {
            print("Display \(markers.count) markers")
        }
    }
}


