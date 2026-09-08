//
//  MarkerIcon.swift
//  SilksongTracker
//
//  Created by Matt Gannon on 9/8/26.
//

import SwiftUI

struct MarkerIcon: View {
    @Environment(TileImageCache.self) private var imageCache

    let marker: MarkerItem
    let showName: Bool

    var body: some View {
        Image(marker.iconName)
            .frame(width: 14, height: 14)
            .accessibilityLabel(marker.name)
            .id(marker.id)
            .overlay(alignment: .top) {
                Text("\(marker.name)-\(marker.id)")
                    .font(.caption2.bold())
                    .foregroundStyle(.white)
                    .padding(2)
                    .background(.gray.opacity(0.5))
                    .fixedSize()
                    .offset(y: -24)
                    .zIndex(10)
                    .opacity(showName ? 1 : 0)
            }
    }
}
