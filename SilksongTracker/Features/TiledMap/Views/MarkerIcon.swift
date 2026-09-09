//
//  MarkerIcon.swift
//  SilksongTracker
//
//  Created by Matt Gannon on 9/8/26.
//

import SwiftUI

struct MarkerIcon: View {

    let iconName: String

    var body: some View {
        Image(iconName)
            .resizable()
            .frame(width: 24, height: 24)
            .tag(iconName)
//            .accessibilityLabel(marker.name)
//            .id(marker.id)
//            .overlay(alignment: .top) {
//                Text("\(marker.name)-\(marker.id)")
//                    .font(.caption2.bold())
//                    .foregroundStyle(.white)
//                    .padding(2)
//                    .background(.gray.opacity(0.5))
//                    .fixedSize()
//                    .offset(y: -24)
//                    .zIndex(10)
//                    .opacity(showName ? 1 : 0)
//            }
    }
}
