//
//  TileSet.swift
//  SilksongTracker
//
//  Created by Matt Gannon on 9/7/26.
//

import UIKit

struct TileSet: Hashable, Sendable {
    static func contentSize(effectiveScale: CGFloat) -> CGSize {
        let contentEdgeLength = Constants.tileSideLength * effectiveScale
        return CGSize(width: contentEdgeLength, height: contentEdgeLength)
    }

    static func visibileTiles(
        in viewport: CGRect,
        at resolution: TileResolutionLevel,
        contentSize: CGSize
    ) -> [MapTile] {
        let rect = bufferedVisibleRect(from: viewport, contentSize: contentSize)

        guard !rect.isNull else { return [] }

        let tileLength = contentSize.width / CGFloat(resolution.edgeTileCount)
        let xRange = tileCoordinateRange(in: rect.minX...rect.maxX, tileCount: resolution.edgeTileCount, tileLength: tileLength)
        let yRange = tileCoordinateRange(in: rect.minY...rect.maxY, tileCount: resolution.edgeTileCount, tileLength: tileLength)

        let tiles = yRange.flatMap { y in
            xRange.map { x in
                MapTile(level: resolution, x: x, y: y)
            }
        }

        return tiles
    }

    static func bufferedVisibleRect(from viewport: CGRect, contentSize: CGSize) -> CGRect {
        let contentRect = CGRect(origin: .zero, size: contentSize)
        guard !viewport.isEmpty else { return contentRect }

        let bufferInset = UIEdgeInsets(all: -128)
        return viewport
            .inset(by: bufferInset)
            .intersection(contentRect)
    }

    /// Returns the lowest/highest visible tile coordinate in the buffered visible rect.
    private static func tileCoordinateRange(in range: ClosedRange<CGFloat>, tileCount: Int, tileLength: CGFloat) -> ClosedRange<Int> {
        let lower = max(0, Int(floor(range.lowerBound / tileLength)))
        let upper = min(tileCount - 1, Int(floor((range.upperBound - 1) / tileLength)))
        return lower...upper
    }
}

// MARK: - UIEdgeInsets convenience
private extension UIEdgeInsets {
    init(all value: CGFloat) {
        self.init(top: value, left: value, bottom: value, right: value)
    }
}
