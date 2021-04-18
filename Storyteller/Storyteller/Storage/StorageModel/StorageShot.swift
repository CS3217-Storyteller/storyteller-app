//
//  StorageShot.swift
//  Storyteller
//
//  Created by TFang on 28/3/21.
//

import Foundation
import CoreGraphics

struct StorageShot: Codable {
    let id: UUID
    let canvasSize: CGSize
    var backgroundColor: Color
    var layers: [UUID: StorageLayer]
    var layerOrder: [UUID]
    
    init(_ shot: Shot) {
        self.id = shot.id
        self.canvasSize = shot.canvasSize
        self.backgroundColor = shot.backgroundColor
        self.layers = shot.layers.mapValues({ StorageLayer($0) })
        self.layerOrder = shot.layerOrder
    }
}

extension StorageShot {
    var shot: Shot {
        Shot(
            id: self.id,
            canvasSize: self.canvasSize,
            backgroundColor: self.backgroundColor,
            layers: self.layers.mapValues({ $0.layer }),
            layerOrder: layerOrder
        )
    }
}
