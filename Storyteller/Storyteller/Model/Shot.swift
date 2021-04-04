//
//  Shot.swift
//  Storyteller
//
//  Created by Marcus on 21/3/21.
//
import PencilKit

struct Shot: Codable {
    var layers: [UUID: Layer] = [UUID: Layer]()
    var layerOrder: [UUID] = [UUID]()
    var id: UUID
    var label: ShotLabel
    var backgroundColor: Color
    let canvasSize: CGSize

    var orderedLayers: [Layer] {
        layerOrder
            .map { id in
                layers[id]
            }
            .compactMap { $0 }
    }

    mutating func updateLayer(_ layerLabel: LayerLabel, withDrawing drawing: PKDrawing) {
        let layerId = layerLabel.layerId
        layers[layerId]?.setDrawing(to: drawing)
    }

    // TODO: What if layer already exist? Just update?
    mutating func addLayer(_ layer: Layer) {
        let layerId = layer.id
        if layers[layerId] == nil {
            layerOrder.append(layerId)
        }
        layers[layerId] = layer
    }

    func duplicate(withId newShotId: UUID = UUID()) -> Self {
        let newLabel = label.withShotId(newShotId)
        var dict = [UUID: Layer]()
        var order = [UUID]()
        for (_, var layer) in layers {
            layer.label = layer.label.withShotId(newShotId)
            let newLayerId = UUID()
            dict[newLayerId] = layer.duplicate(withId: newLayerId)
            order.append(newLayerId)
        }
        return Self(layers: dict,
                    layerOrder: order,
                    id: newShotId,
                    label: newLabel,
                    backgroundColor: backgroundColor,
                    canvasSize: canvasSize)
    }
}
