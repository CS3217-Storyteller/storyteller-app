//
//  Shot.swift
//  Storyteller
//
//  Created by Marcus on 21/3/21.
//

import PencilKit

struct Shot {
    var layers: [Layer]
    var label: ShotLabel
    var backgroundColor: UIColor

    mutating func updateLayer(_ layerIndex: Int, withDrawing drawing: PKDrawing) {
        layers[layerIndex].setDrawingTo(drawing)
    }

    mutating func addLayer(_ layer: Layer) {
        layers.append(layer)
    }
}
