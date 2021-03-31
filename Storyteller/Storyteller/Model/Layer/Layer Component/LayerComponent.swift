//
//  LayerComponent.swift
//  Storyteller
//
//  Created by TFang on 28/3/21.
//

import PencilKit

protocol LayerComponent {
    var canvasSize: CGSize { get }
    var frame: CGRect { get }
    var anchorPoint: CGPoint { get }

    var transformInfo: TransformInfo { get set }

    func setDrawing(to drawing: PKDrawing) -> Self
    func addToMerger(_ merger: LayerMerger)
}

extension LayerComponent {
    // TODO: the anchor point for Image Layer should be just the center point
    var anchorPoint: CGPoint {
        guard !(frame.isEmpty || frame.isInfinite) else {
            return CGPoint(x: 0.5, y: 0.5)
        }
        return CGPoint(x: frame.midX / canvasSize.width,
                       y: frame.midY / canvasSize.height)
    }
    mutating func setDrawing(to drawing: PKDrawing) {}
}

extension LayerComponent {
    mutating func scaled(by scale: CGFloat) {
        transformInfo.scaled(by: scale)
    }

    mutating func rotated(by angle: CGFloat) {
        transformInfo.rotated(by: angle)
    }

    mutating func translatedBy(x: CGFloat, y: CGFloat) {
        transformInfo.translatedBy(x: x, y: y)
    }
}
