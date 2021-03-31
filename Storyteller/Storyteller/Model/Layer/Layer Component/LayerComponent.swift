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

    var image: UIImage { get }

    var transformInfo: TransformInfo { get set }

    func updateTransformInfo(info: TransformInfo) -> Self
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
    func scaled(by scale: CGFloat) -> Self {
        let newInfo = transformInfo.scaled(by: scale)
        return updateTransformInfo(info: newInfo)
    }

    func rotated(by angle: CGFloat) -> Self {
        let newInfo = transformInfo.rotated(by: angle)
        return updateTransformInfo(info: newInfo)
    }

    func translatedBy(x: CGFloat, y: CGFloat) -> Self {
        let newInfo = transformInfo.translatedBy(x: x, y: y)
        return updateTransformInfo(info: newInfo)
    }
}
