//
//  Requirement.swift
//  SilksongTracker
//
//  Created by Matt Gannon on 9/3/26.
//

import Foundation

enum Requirement: CHS {
    case technique(TechniqueKind)
    case upgrade
    case ability
}

// MARK: - TechniqueKind
enum TechniqueKind: String, CHS {
    case pogo
}
