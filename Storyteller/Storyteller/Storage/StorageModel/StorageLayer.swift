//
//  StorageLayer.swift
//  Storyteller
//
//  Created by TFang on 28/3/21.
//

import CoreGraphics

struct StorageLayer: Codable {
    var storageComponent: StorageLayerComponent
    var canvasSize: CGSize

    init(_ layer: Layer) {
        self.storageComponent = StorageLayerComponent(layer.component)
        self.canvasSize = layer.canvasSize
    }

}

extension StorageLayer {
    var layer: Layer {
        Layer(component: storageComponent.component, canvasSize: canvasSize)
    }
}
