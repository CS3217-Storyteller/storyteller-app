//
//  Project.swift
//  Storyteller
//
//  Created by Marcus on 21/3/21.
//
import PencilKit

struct Project {
    var scenes: [Scene]
    var label: ProjectLabel
    let canvasSize: CGSize
    let title: String

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
    mutating func update(layer: Layer, at layerIndex: Int,
                         ofShot shotLabel: ShotLabel) {
        let sceneIndex = shotLabel.sceneIndex
        guard scenes.indices.contains(sceneIndex) else {
            return
        }
        scenes[sceneIndex].update(layer: layer, at: layerIndex, ofShot: shotLabel)
    }
    mutating func addScene(_ scene: Scene) {
        scenes.append(scene)
    }

    mutating func addShot(_ shot: Shot, to sceneLabel: SceneLabel) {
        let sceneIndex = sceneLabel.sceneIndex
        guard scenes.indices.contains(sceneIndex) else {
            return
        }
        scenes[sceneIndex].addShot(shot)
    }

    mutating func addLayer(_ layer: Layer, at index: Int?, to shotLabel: ShotLabel) {
        let sceneIndex = shotLabel.sceneIndex
        guard scenes.indices.contains(sceneIndex) else {
            return
        }
        scenes[sceneIndex].addLayer(layer, at: index, to: shotLabel)
    }
    mutating func removeLayers(at indices: [Int], of shotLabel: ShotLabel) {
        let sceneIndex = shotLabel.sceneIndex
        guard scenes.indices.contains(sceneIndex) else {
            return
        }
        scenes[sceneIndex].removeLayers(at: indices, of: shotLabel)
    }
    mutating func moveLayer(from oldIndex: Int, to newIndex: Int, of shotLabel: ShotLabel) {
        let sceneIndex = shotLabel.sceneIndex
        guard scenes.indices.contains(sceneIndex) else {
            return
        }
        scenes[sceneIndex].moveLayer(from: oldIndex, to: newIndex, of: shotLabel)
    }
}
