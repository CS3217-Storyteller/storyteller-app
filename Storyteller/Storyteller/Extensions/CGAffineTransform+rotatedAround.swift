//
//  CGAffineTransform+rotatedAround.swift
//  Storyteller
//
//  Created by TFang on 3/4/21.
//

import CoreGraphics

extension CGAffineTransform {
    static func rotatedAround(_ pointRelativeToAnchor: CGPoint, by angle: CGFloat,
                              boundsSize: CGSize) -> CGAffineTransform {
        CGAffineTransform.identity
            .translatedBy(x: pointRelativeToAnchor.x, y: pointRelativeToAnchor.y)
            .rotated(by: angle)
            .translatedBy(x: -pointRelativeToAnchor.x, y: -pointRelativeToAnchor.y)
    }
    static func scaledAround(_ pointRelativeToAnchor: CGPoint, by scale: CGFloat) -> CGAffineTransform {
        CGAffineTransform.identity
            .translatedBy(x: pointRelativeToAnchor.x, y: pointRelativeToAnchor.y)
            .scaledBy(x: scale, y: scale)
            .translatedBy(x: -pointRelativeToAnchor.x, y: -pointRelativeToAnchor.y)
    }
}
