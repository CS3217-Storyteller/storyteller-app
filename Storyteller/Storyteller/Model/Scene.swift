//
//  Scene.swift
//  Storyteller
//
//  Created by Marcus on 21/3/21.
//
import PencilKit

struct Scene {
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
    
    mutating func swapShots(_ index1: Int, _ index2: Int) {
        self.shotOrder.swapAt(index1, index2)
    }

    mutating func updateLayer(_ layerLabel: LayerLabel,
                              withDrawing drawing: PKDrawing) {
        let shotId = layerLabel.shotId
        shots[shotId]?.updateLayer(layerLabel, withDrawing: drawing)
    }

    mutating func updateLayer(_ layerLabel: LayerLabel,
                              withLayer newLayer: Layer) {
        let shotId = layerLabel.shotId
        shots[shotId]?.updateLayer(layerLabel, withLayer: newLayer)
    }

    mutating func addShot(_ shot: Shot) {
        let shotId = shot.id
        if shots[shotId] == nil {
            shotOrder.append(shotId)
        }
        shots[shotId] = shot
    }

    mutating func addLayer(_ layer: Layer, at index: Int?, to shotLabel: ShotLabel) {
        let shotId = shotLabel.shotId
        shots[shotId]?.addLayer(layer, at: index)
    }

    mutating func removeLayers(withIds ids: Set<UUID>, of shotLabel: ShotLabel) {
        shots[shotLabel.shotId]?.removeLayers(withIds: ids)
    }

    mutating func moveLayer(_ layerLabel: LayerLabel, to newIndex: Int) {
        let shotId = layerLabel.shotId
        shots[shotId]?.moveLayer(layerLabel, to: newIndex)
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
