//
//  String+Extension.swift
//  SilksongTracker
//
//  Created by Matt Gannon on 9/3/26.
//

import Foundation

extension [String] {
    func slugged() -> String { joined(separator: ".") }
}
