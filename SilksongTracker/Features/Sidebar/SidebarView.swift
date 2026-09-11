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
        .padding(.horizontal)
    }

    @ContentBuilder
    private func groupSection(group: MarkerCategoryGroup) -> some View {
        let categorizedItems = viewModel.spoilerFilteredItems()
        let categories = group.categories.filter({ categorizedItems[$0] != nil })
        Section {
            DisclosureGroup {
                ForEach(categories) { category in
                    let markers = categorizedItems[category, default: []]
                    DisclosureGroup {
                        ForEach(markers) { marker in
                            Text("\(marker.name)")
                        }
                    } label: {
                        Text("\(category.rawValue.capitalized) (\(markers.count))")
                    }
                }
            } label: {
                Text("\(group.label) (\(group.categories.count))")
                    .padding(.leading)
            }
        }
    }
}

#Preview {
    MapDataStagingView {
        SidebarView()
    }
}
