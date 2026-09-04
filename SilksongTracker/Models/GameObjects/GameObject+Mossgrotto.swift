//
//  GameObject+Mossgrotto.swift
//  SilksongTracker
//
//  Created by Matt Gannon on 9/3/26.
//

// MARK: - Moss Grotto
extension GameObject {
    static let mossberry = GameObject(
        name: "Mossberry",
        detail: .collectible(.mossberry(instance: "bonegrave")),
        areaId: .mossGrotto,
        mapLocation: .init(mapId: .mossGrotto, x: -688.6, y: 153.01),
        relationships: [
            .contributesToQuest(.berryPicking)
        ],
        requirements: [
            .technique(.pogo)
        ],
        notes: "Requires pogoing on an enemy to cross gap"
    )
}
