//
//  MapView.swift
//  SilksongTracker
//
//  Created by Matt Gannon on 9/4/26.
//

import SwiftUI

struct MapView: View {
    let map: AreaMapImage

    var body: some View {
        Image(uiImage: map.uiImage)
            .resizable()
            .scaledToFit()
            .frame(width: map.pixelSize.width, height: map.pixelSize.height)
            .contentShape(.rect)
            .accessibilityLabel(map.accessibilityLabel)
    }
}
