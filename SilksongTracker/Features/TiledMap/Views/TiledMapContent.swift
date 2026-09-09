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

        Canvas(renderer: { context, size in
            for tile in tiles {
                guard let image = imageCache.cachedImage(for: tile.id) else {
                    Task.detached { await imageCache.loadImage(for: tile.id) }
                    continue
                }
                
                let tileFrame = tile.frame(with: tileLength)
                context.draw(Image(uiImage: image), in: tileFrame)

                for marker in markers {
                    if let symbol = context.resolveSymbol(id: marker.iconName) {
                        let point = marker.location * contentSize.width
                        context.draw(symbol, at: point)
                    }
                }
            }
        }, symbols: {
            let imageIcons = Array(Set(markers.map(\.iconName)))
            ForEach(imageIcons, id: \.self) { MarkerIcon(iconName: $0) }
        })
        .frame(size: contentSize)
        .contentShape(.rect)
        .onAppear(perform: imageCache.loadHigherResolutions)
    }
}
