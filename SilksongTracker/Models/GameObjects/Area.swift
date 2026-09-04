//
//  Area.swift
//  SilksongTracker
//
//  Created by Matt Gannon on 9/3/26.
//

import Foundation

struct Area: CHS {
    let id: ID
    let name: String
    let mapID: Map.ID // This is exactly the same as Area.ID for the time being.
}

// MARK: - Area.ID
extension Area {
    enum ID: String, CaseIterable, CHS {
        case mossGrotto = "moss-grotto"

        var mapResource: String { rawValue }
        var accessibleName: String {
            switch self {
            case .mossGrotto: "Moss Grotto Map"
            }
        }
    }
}
