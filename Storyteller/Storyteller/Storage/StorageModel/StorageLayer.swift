//
//  StorageLayer.swift
//  Storyteller
//
//  Created by TFang on 28/3/21.
//

import UIKit

struct StorageLayer: Codable {
    var storageComponent: StorageLayerComponent
    var canvasSize: CGSize
    var name: String
    var isLocked: Bool
    var isVisible: Bool

    var thumbnail: Thumbnail

    init(_ layer: Layer) {
        self.storageComponent = StorageLayerComponent(layer.component)
        self.canvasSize = layer.canvasSize
        self.name = layer.name
        self.isLocked = layer.isLocked
        print("during init: \(layer.isVisible)")
        self.isVisible = layer.isVisible
        self.thumbnail = layer.thumbnail
    }

}

extension StorageLayer {
    var layer: Layer {
        let layer = Layer(component: storageComponent.component, canvasSize: canvasSize,
              name: name, isLocked: isLocked, isVisible: isVisible, thumbnail: thumbnail)
        print(layer.isVisible)
        return layer
    }
}
