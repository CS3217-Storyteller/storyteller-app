//
//  DrawingComponent.swift
//  Storyteller
//
//  Created by TFang on 28/3/21.
//

import PencilKit

struct DrawingComponent: LeafComponent {
    private(set) var leafType = LeafType.drawing

    private(set) var drawing: PKDrawing
    let canvasSize: CGSize
    var frame: CGRect {
        drawing.bounds
    }

    init(drawing: PKDrawing, canvasSize: CGSize) {
        self.drawing = drawing
        self.canvasSize = canvasSize
    }

    mutating func setDrawing(to drawing: PKDrawing) {
        self.drawing = drawing
    }

    func addToMerger(_ merger: LayerMerger) {
        merger.mergeDrawing(component: self)
    }
}

extension DrawingComponent: Codable {

}
