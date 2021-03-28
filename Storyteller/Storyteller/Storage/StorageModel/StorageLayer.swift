//
//  StorageLayer.swift
//  Storyteller
//
//  Created by TFang on 28/3/21.
//

import CoreGraphics

struct StorageLayer: Codable {
    var component: StorageCompositeComponent
    var canvasSize: CGSize

    init(_ layer: Layer) {
        self.component = StorageCompositeComponent(layer.component)
        self.canvasSize = layer.canvasSize
    }

}

extension StorageLayer {
    var layer: Layer {
        Layer(component: component.compositeComponent, canvasSize: canvasSize)
    }
}
