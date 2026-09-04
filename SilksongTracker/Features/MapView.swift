//
//  MapView.swift
//  SilksongTracker
//
//  Created by Matt Gannon on 9/4/26.
//

import SwiftUI

struct MapView: View {
    let map: AreaMap

    var body: some View {
        let image = map.mapImage

        ZStack(alignment: .topLeading) {
            Image(uiImage: image.uiImage)
                .resizable()
                .scaledToFit()

            ForEach(map.objects) { object in
                if let location = object.mapLocation {
                    MapObjectMarker(object: object)
                        .position(map.imagePoint(for: location))
                        .onAppear {
                            print("Location: \(location)")
                        }
                }
            }
        }
        .frame(width: image.pixelSize.width, height: image.pixelSize.height)
        .border(.red)
        .contentShape(.rect)
        .accessibilityLabel(map.accessibilityLabel)
    }
}
