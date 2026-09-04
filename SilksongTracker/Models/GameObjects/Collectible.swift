//
//  Collectible.swift
//  SilksongTracker
//
//  Created by Matt Gannon on 9/3/26.
//

import Foundation

enum Collectible: Identifiable, CHS, SlugRepresentable {
    var id: String { slug }

    var slug: String {
        var strings: [String] = [stringValue]

        switch self {
        case .mossberry(let instance): strings.append(instance)
        default: break
        }

        return strings.slugged()
    }


    /// Includes instance specifier indicating exactly which item is being referenced (ex: "bonegrave")
    case mossberry(instance: String)
    case shellShards
    case rosaries
    case tool
    case crest
    case flea

    var stringValue: String {
        switch self {
        case .mossberry: "mossberry"
        case .shellShards: "shell-shards"
        case .rosaries: "rosaries"
        case .tool: "tool"
        case .crest: "crest"
        case .flea: "flea"
        }
    }
}
