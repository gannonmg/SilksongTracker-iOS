//
//  UIImage+Extension.swift
//  SilksongTracker
//
//  Created by Matt Gannon on 9/4/26.
//

import UIKit

extension UIImage {
    var pixelSize: CGSize {
        guard let cgImage else { return size }
        return CGSize(width: cgImage.width, height: cgImage.height)
    }
}
