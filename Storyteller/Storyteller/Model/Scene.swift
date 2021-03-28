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

    mutating func addShot(_ shot: Shot) {
        shots.append(shot)
    }

    mutating func addLayer(_ layer: Layer, to shotLabel: ShotLabel) {
        let shotIndex = shotLabel.shotIndex
        guard shots.indices.contains(shotIndex) else {
            return
        }
        shots[shotIndex].addLayer(layer)
    }
}
