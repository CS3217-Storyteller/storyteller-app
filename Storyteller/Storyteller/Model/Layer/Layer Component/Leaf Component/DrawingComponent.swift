//
//  DrawingComponent.swift
//  Storyteller
//
//  Created by TFang on 28/3/21.
//

import PencilKit

struct DrawingComponent: LayerComponent {
    var transformInfo = TransformInfo()

    private(set) var drawing: PKDrawing
    let canvasSize: CGSize
    var frame: CGRect {
        drawing.bounds.intersection(CGRect(origin: .zero, size: canvasSize))
    }

    var image: UIImage {
        guard !(frame.isEmpty || frame.isInfinite) else {
            return UIImage.clearImage(ofSize: canvasSize)
        }
        return drawing.image(from: CGRect(origin: .zero, size: canvasSize), scale: 1)
    }

    init(drawing: PKDrawing, canvasSize: CGSize) {
        self.drawing = drawing
        self.canvasSize = canvasSize
    }

    func setDrawing(to drawing: PKDrawing) -> DrawingComponent {
        var newComponent = self
        newComponent.drawing = drawing
        return newComponent
    }

    func addToMerger(_ merger: LayerMerger) {
        merger.mergeDrawing(component: self)
    }
}

extension DrawingComponent: Codable {

}
