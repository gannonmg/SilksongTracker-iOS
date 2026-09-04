//
//  GameObject.swift
//  SilksongTracker
//
//  Created by Matt Gannon on 9/3/26.
//

import Foundation

struct GameObject: Identifiable, CHS {
    typealias ID = String
    var id: ID { "\(areaId.rawValue).\(detail.id)" }

    let name: String
    let detail: Detail

    let areaId: Area.ID
    let mapLocation: MapLocation?
    let relationships: [Relationship]
    let requirements: [Requirement]
    var notes: String? = nil
}
