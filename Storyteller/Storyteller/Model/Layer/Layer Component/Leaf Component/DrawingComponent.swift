//
//  DrawingComponent.swift
//  Storyteller
//
//  Created by TFang on 28/3/21.
//

import PencilKit

struct DrawingComponent {
    var transformInfo: TransformInfo
    let canvasSize: CGSize

    private(set) var drawing: PKDrawing

    init(drawing: PKDrawing, canvasSize: CGSize,
         transformInfo: TransformInfo = TransformInfo()) {
        self.transformInfo = transformInfo
        self.drawing = drawing
        self.canvasSize = canvasSize
    }
}

extension DrawingComponent: LayerComponent {
    var frame: CGRect {
        drawing.bounds.intersection(CGRect(origin: .zero, size: canvasSize))
    }
    func updateTransformInfo(info: TransformInfo) -> DrawingComponent {
        DrawingComponent(drawing: drawing, canvasSize: canvasSize, transformInfo: info)
    }

    var image: UIImage {
        guard !(frame.isEmpty || frame.isInfinite) else {
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
