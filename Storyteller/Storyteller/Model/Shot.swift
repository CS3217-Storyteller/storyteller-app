//
//  Shot.swift
//  Storyteller
//
//  Created by Marcus on 21/3/21.
//
import PencilKit

class Shot {
    
    var id: UUID
    let canvasSize: CGSize
    var backgroundColor: Color
    
    var layers: [UUID: Layer] = [UUID: Layer]()
    var layerOrder: [UUID] = [UUID]()
    
    var orderedLayers: [Layer] {
        self.layerOrder.map { id in self.layers[id] }.compactMap { $0 }
    }
    
    init(id: UUID, canvasSize: CGSize, backgroundColor: Color, layers: [UUID: Layer] = [:], layerOrder: [UUID] = []) {
        self.id = id
        self.canvasSize = canvasSize
        self.backgroundColor = backgroundColor
        self.layers = layers
        self.layerOrder = layerOrder
    }
    
    func getThumbnail() -> UIImage {
        self.orderedLayers.reduce(
            UIImage.clearImage(ofSize: canvasSize),
            { $0.mergeWith($1.thumbnail) }
        )
    }
    
    func removeLayers(withIds ids: Set<UUID>) {
        self.layers = self.layers.filter { id, _ in !ids.contains(id) }
        self.layerOrder = layerOrder.filter { id in !ids.contains(id) }
    }
    
    func removeLayer(withId id: UUID) {
        guard let index = self.layerOrder.firstIndex(of: id) else {
            return
        }
        self.layers.removeValue(forKey: id)
        self.layerOrder.remove(at: index)
    }
    
    func moveLayer(withId layerId: UUID, to newIndex: Int) {
        guard let oldIndex = layerOrder.firstIndex(of: layerId) else {
            return
        }
        self.layerOrder.remove(at: oldIndex)
        self.layerOrder.insert(layerId, at: newIndex)
    }
    
    func updateLayer(withId layerId: UUID, withDrawing drawing: PKDrawing) {
        guard let layer = self.layers[layerId] else {
            return
        }
        layer.setDrawing(to: drawing)
    }
    
    func updateLayer(withId layerId: UUID, withLayer layer: Layer) {
        self.layers[layerId] = layer
    }
    
    func addLayer(with layer: Layer, at index: Int? = nil) {
        let layerId = layer.id
        if let index = index, layers[layerId] == nil {
            self.layerOrder.insert(layerId, at: index)
        } else {
            self.layerOrder.append(layer.id)
        }
        self.layers[layerId] = layer
    }

    func duplicate(withId newShotId: UUID = UUID()) -> Shot {
        
        var newLayers: [UUID: Layer] = [:]
        var newLayerOrder: [UUID] = []
        
        for (_, layer) in layers {
            let newLayer = layer.duplicate()
            newLayers[newLayer.id] = newLayer
            newLayerOrder.append(newLayer.id)
        }
        
        let newShot = Shot(
            id: newShotId,
            canvasSize: self.canvasSize,
            backgroundColor: self.backgroundColor,
            layers: newLayers,
            layerOrder: newLayerOrder
        )
        
        return newShot
    }
    
}


//struct Shot {
//    var layers: [UUID: Layer] = [UUID: Layer]()
//    var layerOrder: [UUID] = [UUID]()
//    var id: UUID
//    var label: ShotLabel
//    var backgroundColor: Color
//    let canvasSize: CGSize
//
//    var thumbnail: UIImage {
//        orderedLayers.reduce(UIImage.clearImage(ofSize: canvasSize), { $0.mergeWith($1.thumbnail) })
//    }
//
//    mutating func removeLayers(withIds ids: Set<UUID>) {
//        layers = layers.filter { id, _ in
//            !ids.contains(id)
//        }
//        layerOrder = layerOrder.filter { id in
//            !ids.contains(id)
//        }
//    }
//
//    mutating func removeLayer(withId id: UUID) { // }-> Layer {
//        guard let index = layerOrder.firstIndex(of: id) else {
//            return
//        }
//        layerOrder.remove(at: index)
//        layers.removeValue(forKey: id)
//    }
//
//    mutating func moveLayer(_ layerLabel: LayerLabel, to newIndex: Int) {
//        let layerId = layerLabel.layerId
//        guard let oldIndex = layerOrder.firstIndex(of: layerId) else {
//            return
//        }
//
//        layerOrder.remove(at: oldIndex)
//        layerOrder.insert(layerId, at: newIndex)
//    }
//
//    var orderedLayers: [Layer] {
//        layerOrder
//            .map { id in
//                layers[id]
//            }
//            .compactMap { $0 }
//    }
//
//    mutating func updateLayer(_ layerLabel: LayerLabel, withDrawing drawing: PKDrawing) {
//        let layerId = layerLabel.layerId
//        layers[layerId]?.setDrawing(to: drawing)
//    }
//
//    mutating func updateLayer(_ layerLabel: LayerLabel, withLayer layer: Layer) {
//        let layerId = layerLabel.layerId
//        layers[layerId] = layer
//    }
//
//    // TODO: What if layer already exist? Just update?
//    mutating func addLayer(_ layer: Layer, at index: Int? = nil) {
//        let layerId = layer.id
//        if let index = index, layers[layerId] == nil {
//            layerOrder.insert(layerId, at: index)
//        } else {
//            layerOrder.append(layer.id)
//        }
//        layers[layerId] = layer
//    }
//
//    func duplicate(withId newShotId: UUID = UUID()) -> Self {
//        let newLabel = label.withShotId(newShotId)
//        var dict = [UUID: Layer]()
//        var order = [UUID]()
//        for (_, var layer) in layers {
//            layer.label = layer.label.withShotId(newShotId)
//            let newLayerId = UUID()
//            dict[newLayerId] = layer.duplicate(withId: newLayerId)
//            order.append(newLayerId)
//        }
//        return Self(layers: dict,
//                    layerOrder: order,
//                    id: newShotId,
//                    label: newLabel,
//                    backgroundColor: backgroundColor,
//                    canvasSize: canvasSize)
//    }
//}
