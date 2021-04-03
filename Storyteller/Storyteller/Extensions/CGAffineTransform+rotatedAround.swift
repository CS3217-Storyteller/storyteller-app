//
//  CGAffineTransform+rotatedAround.swift
//  Storyteller
//
//  Created by TFang on 3/4/21.
//

import CoreGraphics

extension CGAffineTransform {
    func rotatedAround(_ relativeAnchorPoint: CGPoint, by angle: CGFloat, boundsSize: CGSize) -> CGAffineTransform {
        let anchorPoint = CGPoint(x: boundsSize.width * (relativeAnchorPoint.x - 0.5),
                                  y: boundsSize.height * (relativeAnchorPoint.y - 0.5))
        return translatedBy(x: anchorPoint.x, y: anchorPoint.y)
            .rotated(by: angle)
            .translatedBy(x: -anchorPoint.x, y: -anchorPoint.y)
    }
    func scaledAround(_ relativeAnchorPoint: CGPoint, by scale: CGFloat, boundsSize: CGSize) -> CGAffineTransform {
        let anchorPoint = CGPoint(x: boundsSize.width * (relativeAnchorPoint.x - 0.5),
                                  y: boundsSize.height * (relativeAnchorPoint.y - 0.5))
        return translatedBy(x: anchorPoint.x, y: anchorPoint.y)
            .scaledBy(x: scale, y: scale)
            .translatedBy(x: -anchorPoint.x, y: -anchorPoint.y)
    }
}
