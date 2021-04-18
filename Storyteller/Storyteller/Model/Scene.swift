//
//  Scene.swift
//  Storyteller
//
//  Created by Marcus on 21/3/21.
//
import PencilKit

class Scene {
    var id: UUID
    let canvasSize: CGSize
    var shots: [UUID: Shot] = [UUID: Shot]()
    var shotOrder: [UUID] = [UUID]()
    
    var orderedShots: [Shot] {
        self.shotOrder.map { id in self.shots[id] }.compactMap { $0 }
    }
    
    init(id: UUID, canvasSize: CGSize, shots: [UUID: Shot] = [:], shotOrder: [UUID] = []) {
        self.id = id
        self.canvasSize = canvasSize
        self.shots = shots
        self.shotOrder = shotOrder
    }

    func addShot(with shot: Shot) {
        let shotId = shot.id
        if self.shots[shotId] == nil {
            self.shots[shotId] = shot
            self.shotOrder.append(shotId)
        }
    }
    
    func moveShot(withId shotId: UUID, to newIndex: Int) {
        guard let oldIndex = self.shotOrder.firstIndex(of: shotId) else {
            return
        }

        self.shotOrder.remove(at: oldIndex)
        self.shotOrder.insert(shotId, at: newIndex)
    }
    
    func swapShots(_ index1: Int, _ index2: Int) {
        self.shotOrder.swapAt(index1, index2)
    }
    
    func duplicate(withId newSceneId: UUID = UUID()) -> Scene {
        
        var newShots: [UUID: Shot] = [:]
        var newShotOrder: [UUID] = []
        
        for (_, shot) in self.shots {
            
            let newShot = shot.duplicate()
            newShots[newShot.id] = newShot
            newShotOrder.append(newShot.id)
        }
        
        let newScene = Scene(
            id: newSceneId,
            canvasSize: self.canvasSize,
            shots: newShots,
            shotOrder: newShotOrder
        )
        
        return newScene
    }

//    func updateLayer(_ layerLabel: LayerLabel,
//                              withDrawing drawing: PKDrawing) {
//        let shotId = layerLabel.shotId
//        shots[shotId]?.updateLayer(layerLabel, withDrawing: drawing)
//    }
//
//    func updateLayer(_ layerLabel: LayerLabel,
//                              withLayer newLayer: Layer) {
//        let shotId = layerLabel.shotId
//        shots[shotId]?.updateLayer(layerLabel, withLayer: newLayer)
//    }



//    func addLayer(_ layer: Layer, at index: Int?, to shotLabel: ShotLabel) {
//        let shotId = shotLabel.shotId
//        shots[shotId]?.addLayer(layer, at: index)
//    }
//
//    func removeLayers(withIds ids: Set<UUID>, of shotLabel: ShotLabel) {
//        shots[shotLabel.shotId]?.removeLayers(withIds: ids)
//    }
//
//    func moveLayer(_ layerLabel: LayerLabel, to newIndex: Int) {
//        let shotId = layerLabel.shotId
//        shots[shotId]?.moveLayer(layerLabel, to: newIndex)
//    }




}
