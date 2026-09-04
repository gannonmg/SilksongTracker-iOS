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
    enum Step: CHS {
        case completeObject(GameObject.ID)
        case objective(ObjectiveKind)
    }

    enum ObjectiveKind: CHS {
        case accept
        case turnIn

        enum CodingKeys: String, CodingKey {
            case accept = "accept"
            case turnIn = "turn-in"
        }
    }
}
