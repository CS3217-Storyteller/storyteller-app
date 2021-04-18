//
//  StorageLayer.swift
//  Storyteller
//
//  Created by TFang on 28/3/21.
//

import Foundation
import CoreGraphics

struct StorageLayer: Codable {
    var storageComponent: StorageLayerComponent
    var canvasSize: CGSize
    var name: String
    var isLocked: Bool
    var isVisible: Bool
    let id: UUID

    init(_ layer: Layer) {
        self.storageComponent = StorageLayerComponent(layer.component)
        self.canvasSize = layer.canvasSize
        self.name = layer.name
        self.isLocked = layer.isLocked
        self.isVisible = layer.isVisible
        self.id = layer.id
    }

}

extension StorageLayer {
    var layer: Layer {
        Layer(
            id: self.id,
            name: self.name,
            canvasSize: self.canvasSize,
            isLocked: self.isLocked,
            isVisible: self.isVisible,
            component: self.storageComponent.component
        )
    }
}
