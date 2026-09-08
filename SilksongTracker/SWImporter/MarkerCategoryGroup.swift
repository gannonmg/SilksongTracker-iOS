//
//  MarkerCategoryGroup.swift
//  SilksongTracker
//
//  Created by Matt Gannon on 9/8/26.
//

import Foundation

enum MarkerCategoryGroup: String, CaseIterable, Identifiable, Codable {
    var id: Self { self }

    case benchTransport
    case mapping
    case abilityItems = "abilityitems"
    case upgrades
    case currency
    case collectibles
    case npcWish
    case battles
    case permFlags

    var categories: [MarkerCategory] {
        switch self {
        case .benchTransport: [.benches, .bellway, .ventrica]
        case .mapping: [.maps, .mapItem, .shortcut]
        case .abilityItems: [.ability, .tool, .crest, .key]
        case .upgrades: [.mask, .spool, .locket, .heart, .kit, .pouch, .nailUpgrade, .craftMetal, .misc]
        case .currency: [.rosary, .rosaryItem, .shard, .shardItem]
        case .collectibles: [.flea, .tradable, .memento, .silkeater]
        case .npcWish: [.npc, .vendor, .wish, .wishItem]
        case .battles: [.boss, .arena]
        case .permFlags: [.info, .permFlags]
        }
    }

    var defaultIconName: String {
        switch self {
        case .benchTransport: "bench"
        case .mapping: "map"
        case .abilityItems: "needolin"
        case .upgrades: "mask"
        case .currency: "boss"
        case .collectibles: "collectibles"
        case .npcWish: "wish"
        case .battles: "rosarystring"
        case .permFlags: "break"
        }
    }
}

enum MarkerCategory: String, CaseIterable, Identifiable, Codable {
    var id: Self { self }

    // Bench & Transport
    case benches, bellway, ventrica
    // Mapping
    case maps, mapItem = "mapitem", shortcut
    // Ability items
    case ability, tool, crest, key
    // Upgrades
    case mask, spool, locket, heart, kit, pouch, nailUpgrade = "upgnail", craftMetal = "craftmetal", misc
    // Currency
    case rosary, rosaryItem = "rosaryitem", shard, shardItem = "sharditem"
    // Collectibles
    case flea, tradable, memento, silkeater
    // NPC / Wish
    case npc, vendor, wish, wishItem = "wishitem"
    // Battles
    case boss, arena
    // World flags (ie levers, breakable walls)
    case info, permFlags

    var group: MarkerCategoryGroup {
        switch self {
        case .benches, .bellway, .ventrica: .benchTransport
        case .maps, .mapItem, .shortcut: .mapping
        case .ability, .tool, .crest, .key: .abilityItems
        case .mask, .spool, .locket, .heart, .kit, .pouch, .nailUpgrade, .craftMetal, .misc: .upgrades
        case .rosary, .rosaryItem, .shard, .shardItem: .currency
        case .flea, .tradable, .memento, .silkeater: .collectibles
        case .npc, .vendor, .wish, .wishItem: .npcWish
        case .boss, .arena: .battles
        case .info, .permFlags: .permFlags
        }
    }
}
