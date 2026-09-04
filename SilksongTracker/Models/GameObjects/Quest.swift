//
//  Quest.swift
//  SilksongTracker
//
//  Created by Matt Gannon on 9/3/26.
//

import Foundation

struct Quest: CHS {
    let id: ID
}

// MARK: - Quest.ID
extension Quest {
    enum ID: String, CHS {
        case berryPicking

        enum CodingKeys: String, CodingKey {
            case berryPicking = "berry-picking"
        }
    }
}

// MARK: - Quest.Step
extension Quest {
    struct Objective: CHS, SlugRepresentable {
        let kind: Kind
        let objectId: GameObject.ID?

        private init(kind: Kind, objectId: GameObject.ID? = nil) {
            self.kind = kind
            self.objectId = objectId
        }
    }
}

extension Quest.Objective {
    static func accept() -> Self { .init(kind: .accept) }
    static func turnIn() -> Self { .init(kind: .turnIn) }
    static func gather(_ objectId: GameObject.ID) -> Self { .init(kind: .gather, objectId: objectId) }
}

extension Quest.Objective {
    enum Kind: String, CHS {
        case accept
        case gather
        case turnIn
    }

    var slug: String {
        if let objectId {
            [kind.rawValue, objectId].slugged()
        } else {
            [kind.rawValue].slugged()
        }
    }
}
