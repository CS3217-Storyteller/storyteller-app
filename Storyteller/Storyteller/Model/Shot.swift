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
    var backgroundColor: Color
    let canvasSize: CGSize

    var thumbnail: UIImage {
        layers.reduce(UIImage.clearImage(ofSize: canvasSize), { $0.mergeWith($1.thumbnail) })
    }

    mutating func updateLayer(_ layerIndex: Int, withDrawing drawing: PKDrawing) {
        guard layers.indices.contains(layerIndex) else {
            return
        }
        layers[layerIndex].setDrawing(to: drawing)
    }

    mutating func update(layer: Layer, at layerIndex: Int) {
        guard layers.indices.contains(layerIndex) else {
            return
        }
        layers[layerIndex] = layer
    }
    mutating func addLayer(_ layer: Layer) {
        layers.append(layer)
    }
}
