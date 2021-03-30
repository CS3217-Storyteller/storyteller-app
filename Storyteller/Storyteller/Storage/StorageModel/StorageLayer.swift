//
//  StorageLayer.swift
//  Storyteller
//
//  Created by TFang on 28/3/21.
//

import CoreGraphics

struct StorageLayer: Codable {
    var node: LayerComponentNode
    var canvasSize: CGSize

    init(_ layer: Layer) {
        self.node = layer.node
        self.canvasSize = layer.canvasSize
    }

}

extension StorageLayer {
    var layer: Layer {
        Layer(node: node, canvasSize: canvasSize)
    }
}
