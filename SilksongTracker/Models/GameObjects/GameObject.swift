//
//  GameObject.swift
//  SilksongTracker
//
//  Created by Matt Gannon on 9/3/26.
//

import Foundation

struct GameObject: Identifiable, CHS {
    typealias ID = UUID

    let id: ID
    let name: String

    let kind: GameObjectKind
    let areaId: Area.ID
    let mapLocation: MapLocation?

    /*
    let relationships: [Relationship]
    let requirements: [Requirement]
    */
    let notes: String?
}
