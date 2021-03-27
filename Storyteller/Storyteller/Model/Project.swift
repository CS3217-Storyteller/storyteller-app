//
//  Project.swift
//  Storyteller
//
//  Created by Marcus on 21/3/21.
//
import PencilKit

struct Project: Codable {
    var label: ProjectLabel
    let canvasSize: CGSize
    var title: String
    var id: UUID
    var scenes: [UUID: Scene] = [UUID: Scene]()
    var sceneOrder: [UUID] = [UUID]()

    var orderedScenes: [Scene] {
        sceneOrder
            .map { id in
                scenes[id]
            }
            .compactMap { $0 }
    }

    mutating func updateLayer(_ layerLabel: LayerLabel,
                              withDrawing drawing: PKDrawing) {
        let sceneId = layerLabel.sceneId
        scenes[sceneId]?.updateLayer(layerLabel, withDrawing: drawing)
    }

    // TODO: What if scene already exist? Just update?
    mutating func addScene(_ scene: Scene) {
        let id = scene.id
        if scenes[id] == nil {
            sceneOrder.append(id)
        }
        scenes[id] = scene
    }

    mutating func addShot(_ shot: Shot, to sceneLabel: SceneLabel) {
        let sceneId = sceneLabel.sceneId
        scenes[sceneId]?.addShot(shot)
    }

    mutating func addLayer(_ layer: Layer, to shotLabel: ShotLabel) {
        let sceneId = shotLabel.sceneId
        scenes[sceneId]?.addLayer(layer, to: shotLabel)
    }

    func duplicate(withId newProjectId: UUID = UUID()) -> Self {
        let newLabel = ProjectLabel(projectId: newProjectId)
        var dict = [UUID: Scene]()
        var order = [UUID]()
        for (_, var scene) in scenes {
            scene.label = scene.label.withProjectId(newProjectId)
            let newSceneId = UUID()
            dict[newSceneId] = scene.duplicate(withId: newSceneId)
            order.append(newSceneId)
        }
        return Self(label: newLabel,
                    canvasSize: canvasSize,
                    title: title,
                    id: newProjectId,
                    scenes: dict,
                    sceneOrder: order)
    }
}
