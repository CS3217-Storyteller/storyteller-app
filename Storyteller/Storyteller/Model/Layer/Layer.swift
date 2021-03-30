//
//  Layer.swift
//  Storyteller
//
//  Created by TFang on 20/3/21.
//
import PencilKit

struct Layer {
    var component: LayerComponentNode
    var canvasSize: CGSize

    init(component: LayerComponentNode, canvasSize: CGSize) {
        self.component = component
        self.canvasSize = canvasSize
    }
    init(layerWithDrawing: PKDrawing, canvasSize: CGSize) {
        let drawingComponent = DrawingComponent(drawing: layerWithDrawing,
                                                canvasSize: canvasSize)
        self.component = LayerComponentNode(components: [drawingComponent])
        self.canvasSize = canvasSize
    }

    func addToMerger(_ merger: LayerMerger) {
        component.addToMerger(merger)
    }

    mutating func setDrawing(to drawing: PKDrawing) {
        component.setDrawing(to: drawing)
    }

}
