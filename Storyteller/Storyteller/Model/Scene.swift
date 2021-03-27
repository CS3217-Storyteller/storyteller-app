//
//  Scene.swift
//  Storyteller
//
//  Created by Marcus on 21/3/21.
//
import PencilKit

struct Scene: Codable {
    var label: SceneLabel
    let canvasSize: CGSize
    var id: UUID
    var shots: [UUID: Shot] = [UUID: Shot]()
    var shotOrder: [UUID] = [UUID]()

    var orderedShots: [Shot] {
        shotOrder
            .map { id in
                shots[id]
            }
            .compactMap { $0 }
    }

    mutating func updateLayer(_ layerLabel: LayerLabel,
                              withDrawing drawing: PKDrawing) {
        let shotId = layerLabel.shotId
        shots[shotId]?.updateLayer(layerLabel, withDrawing: drawing)
    }

    mutating func addShot(_ shot: Shot) {
        let shotId = shot.id
        if shots[shotId] == nil {
            shotOrder.append(shotId)
        }
        shots[shotId] = shot
    }

    mutating func addLayer(_ layer: Layer, to shotLabel: ShotLabel) {
        let shotId = shotLabel.shotId
        shots[shotId]?.addLayer(layer)
    }

    func duplicate(withId newSceneId: UUID = UUID()) -> Self {
        let newLabel = SceneLabel(projectId: label.projectId,
                                  sceneId: newSceneId)
        var dict = [UUID: Shot]()
        var order = [UUID]()
        for (_, var shot) in shots {
            shot.label = shot.label.withSceneId(newSceneId)
            let newShotId = UUID()
            dict[newShotId] = shot.duplicate(withId: newShotId)
            order.append(newShotId)
        }
        return Self(label: newLabel,
                    canvasSize: canvasSize,
                    id: newSceneId,
                    shots: dict,
                    shotOrder: order)
    }
}
