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
        let contentSize = TileSet.contentSize(
            effectiveScale: effectiveContentScale
        )
        let tileLength =
        contentSize.width / CGFloat(currentResolution.edgeTileCount)

        let tiles = TileSet.visibileTiles(
            in: scrollViewport,
            at: currentResolution,
            contentSize: contentSize
        )

        let clusters = viewModel.visibleClusters(
            in: scrollViewport,
            contentSize: contentSize
        )

        let symbolIDs = Set(
            clusters.map {
                MarkerSymbolID(
                    iconName: $0.representative.iconName,
                    count: $0.members.count
                )
            }
        )
            .sorted {
                if $0.iconName == $1.iconName {
                    return $0.count < $1.count
                }

                return $0.iconName < $1.iconName
            }

        Canvas(renderer: { context, size in
            let start = CFAbsoluteTimeGetCurrent()
            defer {
                let elapsed =
                (CFAbsoluteTimeGetCurrent() - start) * 1_000
                print(
                    String(
                        format: "draw %.2f ms, \(clusters.count) clusters, size \(size.alignedDebugString())",
                        elapsed
                    )
                )
            }

            for tile in tiles {
                guard let image = imageCache.cachedImage(for: tile.id) else {
                    continue
                }

                context.draw(
                    Image(uiImage: image),
                    in: tile.frame(with: tileLength)
                )
            }

            for cluster in clusters {
                let symbolID = MarkerSymbolID(
                    iconName: cluster.representative.iconName,
                    count: cluster.members.count
                )

                guard let symbol = context.resolveSymbol(id: symbolID) else {
                    continue
                }

                context.draw(
                    symbol,
                    at: cluster.location * contentSize.width
                )
            }
        }, symbols: {
            ForEach(symbolIDs, id: \.self) { symbolID in
                MarkerClusterIcon(
                    iconName: symbolID.iconName,
                    count: symbolID.count
                )
                .tag(symbolID)
            }
        })
        .frame(size: contentSize)
        .contentShape(.rect)
        .task {
            let lowestTile = MapTile(level: .lowest, x: 0, y: 0)
            await imageCache.loadImage(for: lowestTile.id)
            await imageCache.loadHigherResolutions()
        }
    }
}

private struct MarkerSymbolID: Hashable {
    let iconName: String
    let count: Int
}
