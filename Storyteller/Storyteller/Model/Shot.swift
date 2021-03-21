//
//  Shot.swift
//  Storyteller
//
//  Created by Marcus on 21/3/21.
//
import PencilKit

struct Shot: Codable {
    var layers: [Layer]
    var label: ShotLabel
    var backgroundColor: Color
    let canvasSize: CGSize

    mutating func updateLayer(_ layerIndex: Int, withDrawing drawing: PKDrawing) {
        guard layers.indices.contains(layerIndex) else {
            print("Project update")
            print(layers.count)
            return
        }
        layers[layerIndex].setDrawingTo(drawing)
    }

    mutating func addLayer(_ layer: Layer) {
        layers.append(layer)
    }
}
