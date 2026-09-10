//
//  SidebarView.swift
//  SilksongTracker
//
//  Created by Matt Gannon on 9/9/26.
//

import SwiftUI

struct SidebarView: View {
    @Environment(MapDataViewModel.self) var viewModel

    var body: some View {
        List {
            ForEach(MarkerCategoryGroup.allCases) {
                groupSection(group: $0)
            }
        }
        .listStyle(.sidebar)
        .padding(.horizontal)
    }

    @ContentBuilder
    private func groupSection(group: MarkerCategoryGroup) -> some View {
        Section {
            DisclosureGroup {
                ForEach(group.categories) { categorySection(category: $0) }
            } label: {
                Text("\(group.rawValue.capitalized) (\(group.categories.count))")
                    .padding(.leading)
            }
        }
    }

    @ContentBuilder
    private func categorySection(category: MarkerCategory) -> some View {
        let markers = viewModel.mapData.markers[category, default: []]
        DisclosureGroup {
            ForEach(markers) {
                Text($0.name)
            }
        } label: {
            Text("\(category.rawValue.capitalized) (\(markers.count))")
        }
    }
}

#Preview {
    MapDataStagingView {
        SidebarView()
    }
}
