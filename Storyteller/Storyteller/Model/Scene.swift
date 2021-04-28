//
//  Scene.swift
//  Storyteller
//
//  Created by Marcus on 21/3/21.
//
import PencilKit

class Scene {
    let canvasSize: CGSize
    var shots: [Shot] = [Shot]()
    let id: UUID

    init(canvasSize: CGSize, shots: [Shot] = [], id: UUID = UUID()) {
        self.canvasSize = canvasSize
        self.shots = shots
        self.id = id
    }

    func swapShots(_ index1: Int, _ index2: Int) {
        self.shots.swapAt(index1, index2)
    }

    func updateShot(shot: Shot, with newShot: Shot) {
        if let index = self.shots.firstIndex(where: { $0 === shot }) {
            self.shots[index] = shot
        }
    }

    func addShot(_ shot: Shot) {
        self.shots.append(shot)
    }

    func addShot(_ shot: Shot, at index: Int) {
        self.shots.insert(shot, at: index)
    }

//    func updateLayer(withId layerId: UUID, withDrawing drawing: PKDrawing) {
//        let shotId = layerLabel.shotId
//        shots[shotId]?.updateLayer(layerLabel, withDrawing: drawing)
//    }
//
//    mutating func updateLayer(_ layerLabel: LayerLabel,
//                              withLayer newLayer: Layer) {
//        let shotId = layerLabel.shotId
//        shots[shotId]?.updateLayer(layerLabel, withLayer: newLayer)
//    }

//    mutating func addLayer(_ layer: Layer, at index: Int?, to shotLabel: ShotLabel) {
//        let shotId = shotLabel.shotId
//        shots[shotId]?.addLayer(layer, at: index)
//    }
//
//    mutating func removeLayers(withIds ids: Set<UUID>, of shotLabel: ShotLabel) {
//        shots[shotLabel.shotId]?.removeLayers(withIds: ids)
//    }
//
//    mutating func moveLayer(_ layerLabel: LayerLabel, to newIndex: Int) {
//        let shotId = layerLabel.shotId
//        shots[shotId]?.moveLayer(layerLabel, to: newIndex)
//    }

    func moveShot(shot: Shot, to newIndex: Int) {
        guard let oldIndex = self.shots.firstIndex(where: { $0 === shot }) else {
            return
        }
        self.shots.remove(at: oldIndex)
        self.shots.insert(shot, at: newIndex)
    }

    func duplicate() -> Scene {
        Scene(
            canvasSize: canvasSize,
            shots: shots.map({ $0.duplicate() })
        )
    }

    func getShot(_ index: Int, after shot: Shot) -> Shot? {
        guard let currentIndex = self.shots.firstIndex(where: { $0 === shot }),
              self.shots.indices.contains(currentIndex + index) else {
            return nil
        }
        return self.shots[currentIndex + index]
    }
}
