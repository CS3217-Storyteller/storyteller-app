//
//  DrawingComponent.swift
//  Storyteller
//
//  Created by TFang on 28/3/21.
//

import PencilKit

struct DrawingComponent {
    let canvasSize: CGSize
    var transform: CGAffineTransform
    private(set) var drawing: PKDrawing

    init(drawing: PKDrawing, canvasSize: CGSize,
         transform: CGAffineTransform = .identity) {
        self.transform = transform
        self.drawing = drawing
        self.canvasSize = canvasSize
    }
}

extension DrawingComponent: LayerComponent {
    // MARK: - Transformable
    var anchor: CGPoint {
        CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
    }
    func scaled(by scale: CGFloat) -> DrawingComponent {
        DrawingComponent(drawing: drawing.transformed(using: CGAffineTransform.scaledAround(anchor, by: scale)),
                         canvasSize: canvasSize,
                         transform: transform.scaledBy(x: scale, y: scale))
    }
    func rotated(by rotation: CGFloat) -> DrawingComponent {
        DrawingComponent(drawing: drawing.transformed(using: CGAffineTransform.rotatedAround(anchor, by: rotation)),
                         canvasSize: canvasSize,
                         transform: transform.rotated(by: rotation))
    }
    func translatedBy(x: CGFloat, y: CGFloat) -> DrawingComponent {
        DrawingComponent(drawing: drawing.transformed(using: CGAffineTransform(translationX: x, y: y)),
                         canvasSize: canvasSize,
                         transform: transform
                            .concatenating(CGAffineTransform(translationX: x, y: y)))
    }

    // MARK: - LayerComponent
    var image: UIImage {
        guard !(drawing.bounds.isEmpty || drawing.bounds.isInfinite) else {
            return UIImage.clearImage(ofSize: canvasSize)
        }
        return drawing.image(from: CGRect(origin: .zero, size: canvasSize), scale: 0.5)
    }

    var containsDrawing: Bool {
        true
    }
    func setDrawing(to drawing: PKDrawing) -> DrawingComponent {
        var newComponent = self
        newComponent.drawing = drawing
        return newComponent
    }

    func merge<Result, Merger>(merger: Merger) -> Result where
        Result == Merger.T, Merger: LayerMerger {
        merger.mergeDrawing(component: self)
    }
    func reduce<Result>(_ initialResult: Result,
                        _ nextPartialResult: (Result, LayerComponent) throws -> Result) rethrows -> Result {
        try nextPartialResult(initialResult, self)
    }
}

extension DrawingComponent: Codable {
}
