//
//  MapTile.swift
//  SilksongTracker
//
//  Created by Matt Gannon on 9/7/26.
//

import CoreGraphics
import Foundation

struct MapTile: Identifiable, Hashable, Sendable {
    typealias ID = String

    var id: ID { resourceName }
    var resourceName: String { "\(level.rawValue)_\(x)_\(y)" }

    let level: TileResolutionLevel
    let x: Int
    let y: Int

    func frame(with tileLength: CGFloat) -> CGRect {
        CGRect(
            x: CGFloat(x) * tileLength,
            y: CGFloat(y) * tileLength,
            width: tileLength,
            height: tileLength
        )
    }
}
