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
    private var images: [MapTile.ID: UIImage] = [:]
    private var loadingIDs: Set<MapTile.ID> = []
    private var missingIDs: Set<MapTile.ID> = []

    func cachedImage(for id: MapTile.ID) -> UIImage? {
        images[id]
    }

    /// Seeks a lower resolution version of the current tile as a placeholder
    func bestPlaceholder(for ids: [MapTile.ID]) -> (id: MapTile.ID, image: UIImage)? {
        ids.compactMap { id in self.images[id].map { (id, $0) } }.first
    }

    func loadBestAvailablePlaceholders(_ ids: [MapTile.ID]) async {
        for id in ids.reversed() {
            guard !Task.isCancelled else { return }
            await loadImage(for: id)
        }
    }

    func loadImage(for id: MapTile.ID) async {
        guard images[id] == nil, !loadingIDs.contains(id), !missingIDs.contains(id) else { return }

        loadingIDs.insert(id)
        defer { loadingIDs.remove(id) }

        guard let url = Bundle.main.url(forResource: id, withExtension: "webp") else {
            missingIDs.insert(id)
            return
        }

        guard !Task.isCancelled, let image = UIImage(contentsOfFile: url.path) else { return }
        images[id] = image
    }
}
