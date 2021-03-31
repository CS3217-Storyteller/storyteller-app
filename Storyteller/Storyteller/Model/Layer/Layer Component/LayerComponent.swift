//
//  LayerComponent.swift
//  Storyteller
//
//  Created by TFang on 28/3/21.
//

import PencilKit

protocol LayerComponent: Codable {
    var canvasSize: CGSize { get }
    var frame: CGRect { get }
    var anchorPoint: CGPoint { get }

    var transformInfo: TransformInfo { get set }

    func setDrawing(to drawing: PKDrawing) -> Self
    func addToMerger(_ merger: LayerMerger)
}

extension LayerComponent {
    var anchorPoint: CGPoint {
        CGPoint(x: frame.midX / frame.size.width, y: frame.midY / frame.size.height)
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
