//
//  Project.swift
//  Storyteller
//
//  Created by Marcus on 21/3/21.
//
import PencilKit

struct Project: Codable {
    var id: UUID
    var label: ProjectLabel
    
    var title: String
    let canvasSize: CGSize
    
    var scenes: [UUID: Scene] = [UUID: Scene]()
    var sceneOrder: [UUID] = [UUID]()
    
    var orderedScenes: [Scene] {
        self.sceneOrder.map { id in scenes[id] }.compactMap { $0 }
    }

    mutating func updateLayer(_ layerLabel: LayerLabel, withDrawing drawing: PKDrawing) {
        let sceneId = layerLabel.sceneId
        self.scenes[sceneId]?.updateLayer(layerLabel, withDrawing: drawing)
    }

    // TODO: What if scene already exist? Just update?
    mutating func addScene(_ scene: Scene) {
        let id = scene.id
        if self.scenes[id] == nil {
            self.sceneOrder.append(id)
        }
        self.scenes[id] = scene
    }

    mutating func addShot(_ shot: Shot, to sceneLabel: SceneLabel) {
        let sceneId = sceneLabel.sceneId
        self.scenes[sceneId]?.addShot(shot)
    }

    mutating func addLayer(_ layer: Layer, to shotLabel: ShotLabel) {
        let sceneId = shotLabel.sceneId
        self.scenes[sceneId]?.addLayer(layer, to: shotLabel)
    }
    
    mutating func setTitle(to title: String) {
        self.title = title
    }

    func duplicate(withId newProjectId: UUID = UUID()) -> Self {
        let newLabel = ProjectLabel(projectId: newProjectId)
        var dict = [UUID: Scene]()
        var order = [UUID]()
        for (_, var scene) in self.scenes {
            scene.label = scene.label.withProjectId(newProjectId)
            let newSceneId = UUID()
            dict[newSceneId] = scene.duplicate(withId: newSceneId)
            order.append(newSceneId)
        }
        return Self(
            id: newProjectId,
            label: newLabel,
            title: self.title,
            canvasSize: self.canvasSize,
            scenes: dict,
            sceneOrder: order)
    }
}
