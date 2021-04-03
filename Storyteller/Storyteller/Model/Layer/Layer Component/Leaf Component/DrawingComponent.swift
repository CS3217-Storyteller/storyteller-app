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
    var originalFrame: CGRect {
        drawing.transformed(using: transform.inverted()).bounds
    }
    var transformedFrame: CGRect {
        // TODO: remove
//        drawing.bounds.intersection(CGRect(origin: .zero, size: canvasSize))
        drawing.bounds
    }
    func transformed(using transform: CGAffineTransform) -> DrawingComponent {
        let newDrawing = drawing.transformed(using: transform)
        return DrawingComponent(drawing: newDrawing, canvasSize: canvasSize,
                                transform: transform.concatenating(self.transform))
    }
    func resetTransform() -> DrawingComponent {
        DrawingComponent(drawing: drawing.transformed(using: transform.inverted()),
                         canvasSize: canvasSize, transform: .identity)
    }

    var image: UIImage {
        guard !(transformedFrame.isEmpty || transformedFrame.isInfinite) else {
            return UIImage.clearImage(ofSize: canvasSize)
        }
        return drawing.image(from: CGRect(origin: .zero, size: canvasSize), scale: 1)
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
