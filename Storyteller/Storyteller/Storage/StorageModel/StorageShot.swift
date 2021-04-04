//
//  StorageShot.swift
//  Storyteller
//
//  Created by TFang on 28/3/21.
//

import Foundation
import CoreGraphics

struct StorageShot: Codable {
    var layers: [UUID: StorageLayer]
    var layerOrder: [UUID]
    var label: ShotLabel
    var backgroundColor: Color
    let canvasSize: CGSize

    init(_ shot: Shot) {
        self.layers = shot.layers.mapValues({ StorageLayer($0) })
        self.layerOrder = shot.layerOrder
        self.label = shot.label
        self.backgroundColor = shot.backgroundColor
        self.canvasSize = shot.canvasSize
    }
}

extension StorageShot {
    var shot: Shot {
        Shot(layers: layers.mapValues({ $0.layer }),
             layerOrder: layerOrder,
             id: label.shotId,
             label: label,
             backgroundColor: backgroundColor,
             canvasSize: canvasSize)
    }
}
