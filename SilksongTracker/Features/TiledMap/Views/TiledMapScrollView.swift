//
//  TiledMapScrollView.swift
//  SilksongTracker
//
//  Created by Matt Gannon on 9/7/26.
//

import SwiftUI
import ZoomableScrollView

enum ZoomConfig {
    /// This is the interactive zoom amount for the ZoomableScrollView.
    /// Affects how much the ZoomableScrollView is able to zoom in/out before receiving a ZoomResetCommit.
    private static let liveZoomRange: ClosedRange<CGFloat> = 1...4
    /// This is the actual zoom range that the user experiences.
    /// Changes this to increase / decrease how far in or out they are able to zoom.
    static let effectiveZoomRange: ClosedRange<CGFloat> = 1...12
    /// This is the "standard" zoom amount for the ZoomableScrollView.
    ///
    /// SwiftUI Canvas has internal rendering issues below 0.5. By making 2 our default and 1 our minimum,
    /// we can allow zoom out while preventing the render issues / cropping.
    static let defaultZoomScale: CGFloat = 2
    /// The zoom scale at which we should bump up to the next resolution level.
    static let zoomInResetThreshold: CGFloat = 2.75
    /// The zoom scale at which we should bump down a resolution level.
    static let zoomOutResetThreshold: CGFloat = 1.25

    /// The actual, possible zoom allowed based on the above configuration.
    static func zoomRange(for effectiveContentScale: CGFloat) -> ClosedRange<CGFloat> {
        let remainingZoomIn = effectiveZoomRange.upperBound / effectiveContentScale
        let upperBound = min(liveZoomRange.upperBound, remainingZoomIn)
        return liveZoomRange.lowerBound...max(liveZoomRange.lowerBound, upperBound)
    }
}

struct TiledMapScrollView<Overlay: View>: View {

    @Environment(\.scrollViewport) private var scrollViewport

    @State private var zoomResetCommit: ZoomResetCommit?
    @State private var effectiveContentScale: CGFloat = 1
    @State private var currentResolution: TileResolutionLevel = .lowest

    // MARK: - Init
    let overlay: () -> Overlay

    init(@ContentBuilder overlay: @escaping () -> Overlay) {
        self.overlay = overlay
    }

    // MARK: - Body
    var body: some View {
        let zoomRange = ZoomConfig.zoomRange(for: effectiveContentScale)
        ZoomableScrollView(
            zoomRange: zoomRange,
            onZoomEvent: onZoomEvent(_:),
            zoomResetCommit: zoomResetCommit
        ) {
            TiledMapContent(
                currentResolution: currentResolution,
                effectiveContentScale: effectiveContentScale,
                overlay: overlay
            )
        }
    }

    // MARK: - Zoom
    private func onZoomEvent(_ event: ZoomEvent) {
        // Do not zoom in past our config's zoom range maximum.
        let rawTotalScale = effectiveContentScale * event.scale
        guard rawTotalScale <= ZoomConfig.effectiveZoomRange.upperBound else { return }

        // Decide which resolution to use based on our current scale.
        let desiredResolution = TileResolutionLevel.preferredResolution(for: rawTotalScale)
        let shouldCommitResolution = desiredResolution != currentResolution

        // Decide if we should commit out current zoom level. Allows users to zoom in/out within the effective zoom range
        // while the ZoomableScrollView enforces the zoomRange.
        // This allows us to continue zooming in more than 4x at the highest resolution.
        let beyondZoomInThreshold = ZoomConfig.zoomInResetThreshold <= event.scale
        let belowZoomOutThreshold = event.scale <= ZoomConfig.zoomOutResetThreshold
        let legalZoomOut = ZoomConfig.effectiveZoomRange.lowerBound < effectiveContentScale
        let shouldCommitScale = beyondZoomInThreshold || (legalZoomOut && belowZoomOutThreshold)

        // Only proceed if we have a new resolution to apply OR a new scale to commit
        guard shouldCommitResolution || shouldCommitScale else { return }

        let targetZoomScale = min(ZoomConfig.defaultZoomScale, max(1, rawTotalScale))
        effectiveContentScale = rawTotalScale / targetZoomScale
        currentResolution = desiredResolution

        zoomResetCommit = ZoomResetCommit(
            previousId: zoomResetCommit?.id,
            event: event,
            targetZoomScale: targetZoomScale
        )
    }
}

// MARK: - Empty Overlay
extension TiledMapScrollView where Overlay == EmptyView {
    init() {
        self.init() {
            EmptyView()
        }
    }
}

