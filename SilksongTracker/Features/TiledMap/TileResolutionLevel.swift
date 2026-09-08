//
//  TileResolutionLevel.swift
//  SilksongTracker
//
//  Created by Matt Gannon on 9/7/26.
//

import Foundation

enum TileResolutionLevel: Int, CaseIterable, Hashable, Sendable {
    case lowest = 4
    case low = 3
    case high = 2
    case highest = 1

    var edgeTileCount: Int {
        let power: Int = max(0, abs(rawValue-4))
        return 2.pow(power)
    }

    static func preferredResolution(for zoomScale: CGFloat) -> TileResolutionLevel {
        switch zoomScale {
        case ..<2: .lowest
        case ..<3: .low
        case ..<4: .high
        default: .highest
        }
    }
}

extension Int {
    func pow(_ exponent: Int) -> Int {
        guard exponent >= 0 else { return 0 }
        var base = self
        var exp = exponent
        var result = 1

        while exp > 0 {
            if exp % 2 == 1 {
                result *= base
            }
            base *= base
            exp /= 2
        }

        return result
    }
}
