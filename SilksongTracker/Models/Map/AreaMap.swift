//
//  AreaMap.swift
//  SilksongTracker
//
//  Created by Matt Gannon on 9/4/26.
//

import CoreGraphics
import Foundation

struct AreaMap: CHS {
    let areaID: Area.ID
    let mapImage: AreaMapImage
    let visibleWorldRect: CGRect
    let accessibilityLabel: String
    let objects: [GameObject]

    init(
        areaId: Area.ID,
        visibleWorldRect: CGRect,
        objects: [GameObject]
    ) {
        self.areaID = areaId
        self.mapImage = AreaMapImage(areaId: areaId)
        self.visibleWorldRect = visibleWorldRect
        self.accessibilityLabel = areaId.mapResource.replacing("-", with: " ") + " map"
        self.objects = objects
    }
}

extension AreaMap {
    func imagePoint(for location: MapLocation) -> CGPoint {
        let normalizedX = (location.x - visibleWorldRect.minX) / visibleWorldRect.width
        let normalizedY = (visibleWorldRect.maxY - location.y) / visibleWorldRect.height

        return CGPoint(
            x: normalizedX * mapImage.pixelSize.width,
            y: normalizedY * mapImage.pixelSize.height
        )
    }
}
