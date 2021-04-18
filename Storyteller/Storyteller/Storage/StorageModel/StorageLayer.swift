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
    var label: LayerLabel

    var thumbnail: Data

    init(_ layer: Layer) {
        self.storageComponent = StorageLayerComponent(layer.component)
        self.canvasSize = layer.canvasSize
        self.name = layer.name
        self.isLocked = layer.isLocked
        self.isVisible = layer.isVisible
        self.label = layer.label
        self.thumbnail = layer.thumbnail.pngData()!
    }

}

extension StorageLayer {
    var layer: Layer {
        Layer(component: storageComponent.component, canvasSize: canvasSize,
              name: name, isLocked: isLocked, isVisible: isVisible, label: label,
              thumbnail: UIImage(data: thumbnail))
    }
}
