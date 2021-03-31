//
//  Layer.swift
//  Storyteller
//
//  Created by TFang on 20/3/21.
//
import PencilKit

struct Layer {
    var canvasSize: CGSize
    var node: LayerComponentNode

    var image: UIImage {
        node.image
    }

    init(node: LayerComponentNode, canvasSize: CGSize) {
        self.node = node
        self.canvasSize = canvasSize
    }

    init(layerWithDrawing: PKDrawing, canvasSize: CGSize) {
        self.canvasSize = canvasSize
        self.node = LayerComponentNode(layerWithDrawing: layerWithDrawing,
                                       canvasSize: canvasSize)
    }

    func addToMerger(_ merger: LayerMerger) {
        node.addToMerger(merger)
    }

    mutating func setDrawing(to drawing: PKDrawing) {
        self.node = node.setDrawing(to: drawing)
    }

}
