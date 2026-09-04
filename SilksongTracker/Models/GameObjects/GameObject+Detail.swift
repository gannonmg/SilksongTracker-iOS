//
//  GameObjectKind.swift
//  SilksongTracker
//
//  Created by Matt Gannon on 9/3/26.
//

import Foundation

extension GameObject {
    struct Detail: Identifiable, CHS {
        var id: String { [kind.rawValue, type].joined(separator: ".") }

        private init(kind: Kind, type: String) {
            self.kind = kind
            self.type = type
        }

        let kind: Kind
        let type: String
    }
}

// MARK: - Collectibles
extension GameObject.Detail {
    static func collectible(_ collectible: Collectible) -> Self {
        return Self(kind: .collectible, type: collectible.stringValue)
    }
}
