//
//  Relationship.swift
//  SilksongTracker
//
//  Created by Matt Gannon on 9/3/26.
//

import Foundation

enum Relationship: CHS {
    case contributesToQuest(Quest.ID)
    case questGiver(GameObject.ID)
    case rewards(GameObject.ID)
}
