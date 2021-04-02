//
//  Scene.swift
//  Storyteller
//
//  Created by Marcus on 21/3/21.
//
import PencilKit

struct Scene {
    var shots: [Shot]
    var label: SceneLabel
    let canvasSize: CGSize

    mutating func updateShot(ofShot shotLabel: ShotLabel,
                             atLayer layer: Int,
                             withDrawing drawing: PKDrawing) {
        let shotIndex = shotLabel.shotIndex
        guard shots.indices.contains(shotIndex) else {
            return
        }
        shots[shotIndex].updateLayer(layer, withDrawing: drawing)
    }
    mutating func update(layer: Layer, at layerIndex: Int,
                         ofShot shotLabel: ShotLabel) {
        let shotIndex = shotLabel.shotIndex
        guard shots.indices.contains(shotIndex) else {
            return
        }
        shots[shotIndex].update(layer: layer, at: layerIndex)
    }
    mutating func addShot(_ shot: Shot) {
        shots.append(shot)
    }

    mutating func addLayer(_ layer: Layer, at index: Int?, to shotLabel: ShotLabel) {
        let shotIndex = shotLabel.shotIndex
        guard shots.indices.contains(shotIndex) else {
            return
        }
        shots[shotIndex].addLayer(layer, at: index)
    }
    mutating func removeLayers(at indices: [Int], of shotLabel: ShotLabel) {
        let shotIndex = shotLabel.shotIndex
        guard shots.indices.contains(shotIndex) else {
            return
        }
        shots[shotIndex].removeLayers(at: indices)
    }
    mutating func moveLayer(from oldIndex: Int, to newIndex: Int, of shotLabel: ShotLabel) {
        let shotIndex = shotLabel.shotIndex
        guard shots.indices.contains(shotIndex) else {
            return
        }
        shots[shotIndex].moveLayer(from: oldIndex, to: newIndex)
    }
}
