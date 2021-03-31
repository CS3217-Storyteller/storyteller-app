//
//  StorageLayer.swift
//  Storyteller
//
//  Created by TFang on 28/3/21.
//

import CoreGraphics

struct StorageLayer: Codable {
    var node: StorageComponentNode
    var canvasSize: CGSize

    init(_ layer: Layer) {
        self.node = StorageComponentNode(layer.node)
        self.canvasSize = layer.canvasSize
    }

}

extension StorageLayer {
    var layer: Layer {
        Layer(node: node.componentNode, canvasSize: canvasSize)
    }
}
