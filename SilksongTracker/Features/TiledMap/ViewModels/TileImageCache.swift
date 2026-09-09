//
//  TileImageCache.swift
//  SilksongTracker
//
//  Created by Matt Gannon on 9/7/26.
//

import ImageIO
import Observation
import UIKit

private actor TileImageDecoder {
    func decodeImage(at url: URL) -> CGImage? {
        guard !Task.isCancelled,
              let source = CGImageSourceCreateWithURL(url as CFURL, nil)
                else {
            return nil
        }

        let options = [
            kCGImageSourceShouldCache: true,
            kCGImageSourceShouldCacheImmediately: true
        ] as CFDictionary

        return CGImageSourceCreateImageAtIndex(source, 0, options)
    }
}

@MainActor
@Observable
final class TileImageCache {
    private var images: [MapTile.ID: UIImage] = [:]
    private var loadingIDs: Set<MapTile.ID> = []
    private var missingIDs: Set<MapTile.ID> = []
    private let decoder = TileImageDecoder()

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
        guard images[id] == nil,
              !loadingIDs.contains(id),
              !missingIDs.contains(id)
                else {
            return
        }

        loadingIDs.insert(id)
        defer { loadingIDs.remove(id) }

        guard let url = Bundle.main.url(forResource: id, withExtension: "webp") else {
            missingIDs.insert(id)
            return
        }

        guard !Task.isCancelled,
              let cgImage = await decoder.decodeImage(at: url),
              !Task.isCancelled
                else {
            return
        }

        images[id] = UIImage(cgImage: cgImage)
    }

    func loadHigherResolutions() async {
        for resolution in [TileResolutionLevel.low, .high, .highest] {
            for x in 0..<resolution.edgeTileCount {
                for y in 0..<resolution.edgeTileCount {
                    guard !Task.isCancelled else { return }

                    let tile = MapTile(level: resolution, x: x, y: y)
                    await loadImage(for: tile.id)
                }
            }
        }
    }
}
