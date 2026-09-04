//
//  GameObject+Mossgrotto.swift
//  SilksongTracker
//
//  Created by Matt Gannon on 9/3/26.
//

// MARK: - Moss Grotto
extension GameObject {
    static let mossGrottoObjects: [GameObject] = [
        .mossberryBonegrave,
        .mossberryTutorialVineWall
    ]

    static let mossberryBonegrave = GameObject(
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

    static let mossberryTutorialVineWall = GameObject(
        name: "Mossberry",
        detail: .collectible(.mossberry(instance: "tutorial-vine-wall")),
        areaId: .mossGrotto,
        mapLocation: .init(mapId: .mossGrotto, x: -730.59, y: 229.61),
        relationships: [
            .contributesToQuest(.berryPicking)
        ],
        requirements: []
    )
}
