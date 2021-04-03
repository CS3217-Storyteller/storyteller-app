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

    mutating func update(layer: Layer, at index: Int) {
        layers[index] = layer
    }
    mutating func addLayer(_ layer: Layer, at index: Int?) {
        guard let index = index else {
            
            layers.append(layer)
            return
        }
        layers.insert(layer, at: index)
    }
    mutating func removeLayers(at indices: [Int]) {
        for index in indices.reversed() {
            layers.remove(at: index)
        }
    }
    mutating func removeLayer(at index: Int) -> Layer {
        layers.remove(at: index)
    }
    mutating func moveLayer(from oldIndex: Int, to newIndex: Int) {
        layers.insert(layers.remove(at: oldIndex), at: newIndex)
    }
}
