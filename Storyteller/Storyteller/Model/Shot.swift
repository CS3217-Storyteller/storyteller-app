//
//  Shot.swift
//  Storyteller
//
//  Created by Marcus on 21/3/21.
//
import PencilKit

struct Shot {
    var layers: [UUID: Layer] = [UUID: Layer]()
    var layerOrder: [UUID] = [UUID]()
    var id: UUID
    var label: ShotLabel
    var backgroundColor: Color
    let canvasSize: CGSize

    var thumbnail: UIImage {
        orderedLayers.reduce(UIImage.clearImage(ofSize: canvasSize), { $0.mergeWith($1.thumbnail) })
//        DrawingUtility.generateShotThumbnail(for: self)
    }

    mutating func removeLayers(withIds ids: Set<UUID>) {
        layers = layers.filter { id, _ in
            !ids.contains(id)
        }
        layerOrder = layerOrder.filter { id in
            !ids.contains(id)
        }
    }

    mutating func removeLayer(withId id: UUID) { // }-> Layer {
        guard let index = layerOrder.firstIndex(of: id) else {
            return
        }
        layerOrder.remove(at: index)
        layers.removeValue(forKey: id)
    }

    mutating func moveLayer(_ layerLabel: LayerLabel, to newIndex: Int) {
        let layerId = layerLabel.layerId
        guard let oldIndex = layerOrder.firstIndex(of: layerId) else {
            return
        }

        layerOrder.remove(at: oldIndex)
        layerOrder.insert(layerId, at: newIndex)
    }

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

    mutating func updateLayer(_ layerLabel: LayerLabel, withLayer layer: Layer) {
        let layerId = layerLabel.layerId
        layers[layerId] = layer
    }

    // TODO: What if layer already exist? Just update?
    mutating func addLayer(_ layer: Layer, at index: Int? = nil) {
        let layerId = layer.id
        if let index = index, layers[layerId] == nil {
            layerOrder.insert(layerId, at: index)
        } else {
            layerOrder.append(layer.id)
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
