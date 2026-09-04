//
//  AreaMapImage.swift
//  SilksongTracker
//
//  Created by Matt Gannon on 9/4/26.
//

import Foundation
import SwiftUI
import UIKit

struct AreaMapImage {
    // MARK: - Storage Defaults
    private static let fileExtension = "webp"

    // MARK: Values
    private let resourceName: String
    let uiImage: UIImage
    let pixelSize: CGSize

    // MARK: Init
    init(areaId: Area.ID) {
        self.init(resourceName: areaId.mapResource)
    }

    // MARK: Unpack image
    static func uiImage(for resourceName: String) -> UIImage {
        let url = Bundle.main.url(forResource: resourceName, withExtension: Self.fileExtension)
        guard let url, let image = UIImage(contentsOfFile: url.path) else {
            preconditionFailure("No image found for map \(resourceName)")
        }

        return image
    }
}

// MARK: - Constants
extension AreaMapImage {
    static let mossGrotto = AreaMapImage(areaId: .mossGrotto)
}

// MARK: - CHS Conformane
// Use just resourceName for encoding / decoding / hashing - honestly could be dealt with in AreaMap,
// but this is better than writing a custom AreaMap decoder right now.
extension AreaMapImage: CHS {
    // MARK: Codable
    private enum CodingKeys: String, CodingKey {
        case resourceName
    }

    private init(resourceName: String) {
        self.resourceName = resourceName
        let image = Self.uiImage(for: resourceName)
        self.uiImage = image
        self.pixelSize = image.pixelSize
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let resourceName = try container.decode(String.self, forKey: .resourceName)
        self.init(resourceName: resourceName)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(resourceName, forKey: .resourceName)
    }

    // MARK: Hashable / Equatable
    static func == (lhs: AreaMapImage, rhs: AreaMapImage) -> Bool {
        lhs.resourceName == rhs.resourceName
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(resourceName)
    }
}
