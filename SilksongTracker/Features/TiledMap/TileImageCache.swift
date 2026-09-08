//
//  TileImageCache.swift
//  SilksongTracker
//
//  Created by Matt Gannon on 9/7/26.
//

import SwiftUI

@MainActor
@Observable
final class TileImageCache {
    private var images: [MapTileID: UIImage] = [:]
    private var loadingIDs: Set<MapTileID> = []
    private var missingIDs: Set<MapTileID> = []

    func cachedImage(for id: MapTileID) -> UIImage? {
        images[id]
    }

    /// Seeks a lower resolution version of the current tile as a placeholder
    func bestPlaceholder(for ids: [MapTileID]) -> (id: MapTileID, image: UIImage)? {
        ids.compactMap { id in self.images[id].map { (id, $0) } }.first
    }

    func loadBestAvailablePlaceholders(_ ids: [MapTileID]) async {
        for id in ids.reversed() {
            guard !Task.isCancelled else { return }
            await loadImage(for: id)
        }
    }

    func loadImage(for id: MapTileID) async {
        guard images[id] == nil, !loadingIDs.contains(id), !missingIDs.contains(id) else { return }

        loadingIDs.insert(id)
        defer { loadingIDs.remove(id) }

        guard let url = Bundle.main.url(
            forResource: id.resourceName,
            withExtension: "webp"
        ) else {
            missingIDs.insert(id)
            return
        }

        guard !Task.isCancelled, let image = UIImage(contentsOfFile: url.path) else { return }
        images[id] = image
    }
}
