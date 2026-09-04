//
//  MapObjectMarker.swift
//  SilksongTracker
//
//  Created by Matt Gannon on 9/4/26.
//

import SwiftUI

struct MapObjectMarker: View {
    let object: GameObject

    var body: some View {
        Circle()
            .fill(.yellow)
            .stroke(.black, lineWidth: 2)
            .frame(width: 18, height: 18)
            .accessibilityLabel(object.name)
    }
}
