//
//  Kind.swift
//  SilksongTracker
//
//  Created by Matt Gannon on 9/3/26.
//

import Foundation

extension GameObject {
    enum Kind: String, Identifiable, CHS {
        var id: String { rawValue }

        case collectible
        case boss
        case npc
        case bench
        case secret
        case quest
        case location
        case transition
    }
}
