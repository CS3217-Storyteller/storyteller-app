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

    func setDrawing(to drawing: PKDrawing) -> Layer {
        Layer(node: node.setDrawing(to: drawing), canvasSize: canvasSize)
    }

}

extension Layer {
    func scaled(by scale: CGFloat) -> Layer {
        Layer(node: node.scaled(by: scale), canvasSize: canvasSize)
    }

    func rotated(by angle: CGFloat) -> Layer {
        Layer(node: node.rotated(by: angle), canvasSize: canvasSize)
    }

    func translatedBy(x: CGFloat, y: CGFloat) -> Layer {
        Layer(node: node.translatedBy(x: x, y: y), canvasSize: canvasSize)
    }
}
