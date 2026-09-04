//
//  GameObjectKind.swift
//  SilksongTracker
//
//  Created by Matt Gannon on 9/3/26.
//

import Foundation

protocol SlugRepresentable {
    var slug: String { get }
}

extension SlugRepresentable where Self: RawRepresentable, RawValue == String {
    var slug: String { rawValue }
}

extension Identifiable where Self: SlugRepresentable, ID == String {
    var id: String { slug }
}

extension GameObject {
    struct Detail: Identifiable, CHS {
        var id: String { [kind.rawValue, slug].slugged() }

        private init(kind: Kind, sluggable: some SlugRepresentable) {
            self.kind = kind
            self.slug = sluggable.slug
        }

        private init(kind: Kind, slugMembers: [String]) {
            self.kind = kind
            self.slug = slugMembers.slugged()
        }

        let kind: Kind
        let slug: String
    }
}

// MARK: - Collectibles
extension GameObject.Detail {
    static func collectible(_ collectible: Collectible) -> Self {
        return Self(kind: .collectible, sluggable: collectible)
    }

    static func boss(_ boss: Boss) -> Self {
        return Self(kind: .boss, sluggable: boss)
    }

    static func npc(_ npc: NPC) -> Self {
        return Self(kind: .npc, sluggable: npc)
    }

    static func bench(_ bench: Bench) -> Self {
        return Self(kind: .bench, sluggable: bench)
    }

    static func secret(_ secret: Secret) -> Self {
        return Self(kind: .secret, sluggable: secret)
    }

    static func questObjective(_ questId: Quest.ID, step: Quest.Objective) -> Self {
        return Self(kind: .quest, slugMembers: [questId.rawValue, step.slug])
    }

    static func location(_ location: Location) -> Self {
        return Self(kind: .location, sluggable: location)
    }

    static func transition(_ transition: Transition) -> Self {
        return Self(kind: .transition, sluggable: transition)
    }
}

// MARK: - Slug Types
enum Boss: Identifiable, CHS, SlugRepresentable {
    var slug: String { stringValue }

    case mossMother

    var stringValue: String {
        switch self {
        case .mossMother: "moss-mother"
        }
    }
}

enum NPC: Identifiable, CHS, SlugRepresentable {
    var slug: String { stringValue }

    case chapelMaid
    case mossDruid

    var stringValue: String {
        switch self {
        case .chapelMaid: "chapel-maid"
        case .mossDruid: "moss-druid"
        }
    }
}

enum Bench: Identifiable, CHS, SlugRepresentable {
    var slug: String {
        var strings: [String] = [stringValue]

        switch self {
        case .bench(let instance): strings.append(instance)
        }

        return strings.slugged()
    }

    case bench(instance: String)

    var stringValue: String {
        switch self {
        case .bench: "bench"
        }
    }
}

enum Secret: Identifiable, CHS, SlugRepresentable {
    var slug: String {
        var strings: [String] = [stringValue]

        switch self {
        case .breakableWall(let instance),
             .breakableVine(let instance):
            strings.append(instance)
        }

        return strings.slugged()
    }

    case breakableWall(instance: String)
    case breakableVine(instance: String)

    var stringValue: String {
        switch self {
        case .breakableWall: "breakable-wall"
        case .breakableVine: "breakable-vine"
        }
    }
}

enum Location: Identifiable, CHS, SlugRepresentable {
    var slug: String { stringValue }

    case ruinedChapel

    var stringValue: String {
        switch self {
        case .ruinedChapel: "ruined-chapel"
        }
    }
}

enum Transition: Identifiable, CHS, SlugRepresentable {
    var slug: String {
        var strings: [String] = [stringValue]

        switch self {
        case .oneWay(let direction, let instance):
            strings.append(direction.rawValue)
            strings.append(instance)
        }

        return strings.slugged()
    }

    case oneWay(direction: Direction, instance: String)

    var stringValue: String {
        switch self {
        case .oneWay: "one-way"
        }
    }

    enum Direction: String, Identifiable, CHS {
        var id: String { rawValue }

        case up
        case down
        case left
        case right
    }
}
