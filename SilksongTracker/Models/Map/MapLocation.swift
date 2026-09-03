//
//  MapLocation.swift
//  SilksongTracker
//
//  Created by Matt Gannon on 9/3/26.
//

import Foundation

/// A map and an area are nearly 1:1, carrying just a slight semantic difference.
/// Semantically (for now), a map is a spacial description, while an area is a more meta game description of the location
/// (an area has quests, items, etc, and doesn't care where exactly they are)
struct Map: CHS {
    typealias ID = Area.ID
    let id: ID
}

struct MapLocation: CHS {
    let mapId: Map.ID
    let x: Double
    let y: Double
}
