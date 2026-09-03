//
//  GameObjectKind.swift
//  SilksongTracker
//
//  Created by Matt Gannon on 9/3/26.
//

import Foundation

enum GameObjectKind: CHS {
    case collectible(CollectibleKind)
    case boss
    case npc
    case bench
    case secret
    case quest(QuestID)
    case questStep
    case location
    case transition
}

// MARK: - Collectibles
enum CollectibleKind: String, CHS {
    case mossberry
    case shellShards
    case rosaries
    case tool
    case crest
    case flea
}
