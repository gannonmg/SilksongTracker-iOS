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
            .frame(
                width: MarkerDisplayConfiguration.iconLength,
                height: MarkerDisplayConfiguration.iconLength
            )
    }
}

struct MarkerClusterIcon: View {
    let iconName: String
    let count: Int

    var body: some View {
        MarkerIcon(iconName: iconName)
            .overlay(alignment: .topTrailing) {
                if count > 1 {
                    Text(count, format: .number)
                        .font(.caption2.bold())
                        .foregroundStyle(.white)
                        .frame(minWidth: 16, minHeight: 16)
                        .padding(1)
                        .background(.black.opacity(0.8), in: .circle)
                        .offset(x: 6, y: -6)
                }
            }
    }
}
