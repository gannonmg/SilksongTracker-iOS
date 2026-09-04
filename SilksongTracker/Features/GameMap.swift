//
//  GameMap.swift
//  SilksongTracker
//
//  Created by Matt Gannon on 9/4/26.
//

import Foundation
import SwiftUI
import UIKit

struct AreaMapImage: Sendable {

    let uiImage: UIImage
    let pixelSize: CGSize
    let accessibilityLabel: String

    init(area: Area.ID) {
        let image = Self.uiImage(for: area.mapResource)
        self.uiImage = image
        self.pixelSize = image.pixelSize
        self.accessibilityLabel = area.mapResource.replacing("-", with: " ") + " map"
    }

    // MARK: - Unpack image
    static func uiImage(for resourceName: String) -> UIImage {
        let url = Bundle.main.url(forResource: resourceName, withExtension: Self.fileExtension)
        guard let url, let image = UIImage(contentsOfFile: url.path) else {
            preconditionFailure("No image found for map \(resourceName)")
        }

        return image
    }

    // MARK: - Storage Defaults
    private static let fileExtension = "webp"
}

private extension UIImage {
    var pixelSize: CGSize {
        guard let cgImage else { return size }
        return CGSize(width: cgImage.width, height: cgImage.height)
    }
}

// MARK: - Constants
extension AreaMapImage {
    static let mossGrotto = AreaMapImage(area: .mossGrotto)
}
