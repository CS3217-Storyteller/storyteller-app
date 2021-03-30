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
    var rotation: CGFloat { get set }
    var scale: CGFloat { get set }
    var xTranslation: CGFloat { get set }
    var yTranslation: CGFloat { get set }
    func setDrawing(to drawing: PKDrawing) -> Self
    func addToMerger(_ merger: LayerMerger)
}

extension LayerComponent {
    mutating func setDrawing(to drawing: PKDrawing) {}
}

extension LayerComponent {
    mutating func scaled(by scale: CGFloat) {
        guard scale >= 0 else {
            return
        }
        self.scale *= scale
    }

    mutating func rotated(by angle: CGFloat) {
        self.rotation += angle
    }

    mutating func translatedBy(x: CGFloat, y: CGFloat) {
        self.xTranslation += x
        self.yTranslation += y
    }
}
