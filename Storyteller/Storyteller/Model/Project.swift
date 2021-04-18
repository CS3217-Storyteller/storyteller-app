//
//  Project.swift
//  Storyteller
//
//  Created by Marcus on 21/3/21.
//
import PencilKit

class Project {
    
    var id: UUID
    
    var title: String
    let canvasSize: CGSize

    var scenes: [UUID: Scene] = [:]
    var sceneOrder: [UUID] = []

    var orderedScenes: [Scene] {
        self.sceneOrder.map { id in self.scenes[id] }.compactMap { $0 }
    }
    
    init(id: UUID, title: String, canvasSize: CGSize, scenes: [UUID: Scene] = [:], sceneOrder: [UUID] = []) {
        self.id = id
        self.title = title
        self.canvasSize = canvasSize
        self.scenes = scenes
        self.sceneOrder = sceneOrder
    }
    
    func setTitle(to title: String) {
        self.title = title
    }

    func addScene(with scene: Scene) {
        let id = scene.id
        if self.scenes[id] == nil {
            self.scenes[id] = scene
            self.sceneOrder.append(id)
        }
    }
    
    func duplicate(withId newProjectId: UUID = UUID()) -> Project {
        
        var newScenes = [UUID: Scene]()
        var newSceneOrder = [UUID]()
        
        for (_, scene) in self.scenes {
            let newScene = scene.duplicate()
            newScenes[newScene.id] = newScene
            newSceneOrder.append(newScene.id)
        }
        
        let newProject = Project(
            id: newProjectId,
            title: self.title,
            canvasSize: self.canvasSize,
            scenes: newScenes,
            sceneOrder: newSceneOrder
        )
        
        return newProject
    }
}
//    mutating func updateLayer(_ layerLabel: LayerLabel, withDrawing drawing: PKDrawing) {
//        let sceneId = layerLabel.sceneId
//        self.scenes[sceneId]?.updateLayer(layerLabel, withDrawing: drawing)
//    }
//
//    mutating func updateLayer(_ layerLabel: LayerLabel, withLayer newLayer: Layer) {
//        let sceneId = layerLabel.sceneId
//        self.scenes[sceneId]?.updateLayer(layerLabel, withLayer: newLayer)
//    }


//    func addShot(_ shot: Shot, to sceneLabel: SceneLabel) {
//        let sceneId = sceneLabel.sceneId
//        self.scenes[sceneId]?.addShot(shot)
//    }

//    mutating func moveLayer(_ layerLabel: LayerLabel, to newIndex: Int) {
//        let sceneId = layerLabel.sceneId
//        scenes[sceneId]?.moveLayer(layerLabel, to: newIndex)
//    }
//
//    mutating func addLayer(_ layer: Layer, at index: Int?, to shotLabel: ShotLabel) {
//        let sceneId = shotLabel.sceneId
//        self.scenes[sceneId]?.addLayer(layer, at: index, to: shotLabel)
//    }

//    mutating func removeLayers(withIds ids: Set<UUID>, of shotLabel: ShotLabel) {
//        let sceneId = shotLabel.sceneId
//        scenes[sceneId]?.removeLayers(withIds: ids, of: shotLabel)
//    }



//    mutating func moveShot(_ shotLabel: ShotLabel, to newIndex: Int) {
//        let sceneId = shotLabel.sceneId
//        scenes[sceneId]?.moveShot(shotLabel, to: newIndex)
//    }
// }
