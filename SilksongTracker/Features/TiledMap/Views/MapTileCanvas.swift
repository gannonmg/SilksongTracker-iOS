//
//  MapTileCanvas.swift
//  SilksongTracker
//
//  Created by Matt Gannon on 9/8/26.
//

import SwiftUI

struct MapTileCanvas: View {
    @Environment(TileImageCache.self) var imageCache

    let tile: MapTile
    let contentSize: CGSize

    var body: some View {
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
