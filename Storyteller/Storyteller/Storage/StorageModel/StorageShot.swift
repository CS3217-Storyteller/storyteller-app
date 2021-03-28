//
//  StorageShot.swift
//  Storyteller
//
//  Created by TFang on 28/3/21.
//

import CoreGraphics

struct StorageShot: Codable {
    var layers: [StorageLayer]
    var label: ShotLabel
    var backgroundColor: Color
    let canvasSize: CGSize

    init(_ shot: Shot) {
        self.layers = shot.layers.map({ StorageLayer($0) })
        self.label = shot.label
        self.backgroundColor = shot.backgroundColor
        self.canvasSize = shot.canvasSize
    }
}

extension StorageShot {
    var shot: Shot {
        Shot(layers: layers.map({ $0.layer }),
             label: label, backgroundColor: backgroundColor, canvasSize: canvasSize)
    }
}
