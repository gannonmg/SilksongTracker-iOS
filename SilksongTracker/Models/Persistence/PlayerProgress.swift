//
//  PlayerProgress.swift
//  SilksongTracker
//
//  Created by Matt Gannon on 9/3/26.
//

import Foundation

struct PlayerProgress: Codable {
    var objects: [GameObject.ID: ProgressState]
}
