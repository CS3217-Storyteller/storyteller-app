//
//  Project.swift
//  Storyteller
//
//  Created by Marcus on 21/3/21.
//

import PencilKit

struct Project: Codable {
    var scenes: [Scene]
    var label: ProjectLabel
    let canvasSize: CGSize

    mutating func updateShot(ofShot shotLabel: ShotLabel,
                            atLayer layer: Int,
                            withDrawing drawing: PKDrawing) {
        let sceneIndex = shotLabel.sceneIndex
        guard scenes.indices.contains(sceneIndex) else {
            return
        }
        scenes[sceneIndex].updateShot(ofShot: shotLabel,
                                      atLayer: layer,
                                      withDrawing: drawing)
    }

    mutating func addScene(_ scene: Scene) {
        scenes.append(scene)
    }

    mutating func addShot(_ shot: Shot, to sceneLabel: SceneLabel) {
        let sceneIndex = sceneLabel.sceneIndex
        scenes[sceneIndex].addShot(shot)
    }

    mutating func addLayer(_ layer: Layer, to shotLabel: ShotLabel) {
        let sceneIndex = shotLabel.sceneIndex
        scenes[sceneIndex].addLayer(layer, to: shotLabel)
    }
}
