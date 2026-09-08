//
//  SilksongTrackerTests.swift
//  SilksongTrackerTests
//
//  Created by Matt Gannon on 9/8/26.
//

import Testing
@testable import SilksongTracker

struct SilksongTrackerTests {

    /// Make sure that all categories are account for in a larger group, and that the values match up between the two enums
    @Test
    func swImportCategoryGroups() async throws {
        for category in MarkerCategory.allCases {
            #expect(category.group.categories.contains(category))
        }
    }

}
