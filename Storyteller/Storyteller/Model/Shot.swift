//
//  Shot.swift
//  Storyteller
//
//  Created by Marcus on 21/3/21.
//
import PencilKit

class Shot {
    var layers: [Layer] = [Layer]()
    var backgroundColor: Color
    let canvasSize: CGSize
    
    var thumbnail: Thumbnail
    
    init(canvasSize: CGSize,
         backgroundColor: Color,
         layers: [Layer] = [],
         thumbnail: Thumbnail = Thumbnail()) {
        self.canvasSize = canvasSize
        self.backgroundColor = backgroundColor
        self.layers = layers
        self.thumbnail = thumbnail
    }
    

    func generateThumbnails() {
        let defaultThumbnail = layers.reduce(
            UIImage.solidImage(ofColor: backgroundColor.uiColor,
                               ofSize: canvasSize), {
                                $0.mergeWith($1.defaultThumbnail)
                               })
        let redOnionSkin = layers
            .reduce(UIImage.solidImage(ofColor: .clear, ofSize: canvasSize), {
                                        $0.mergeWith($1.redOnionSkin) })
        let greenOnionSkin = layers
            .reduce(UIImage.solidImage(ofColor: .clear, ofSize: canvasSize), {
                                        $0.mergeWith($1.greenOnionSkin) })
        thumbnail = Thumbnail(defaultThumbnail: defaultThumbnail,
                              redOnionSkin: redOnionSkin, greenOnionSkin: greenOnionSkin)
    }
    
    // TODO: What if layer already exist? Just update?
    func addLayer(_ layer: Layer, at index: Int? = nil) {
        if let index = index {
            layers.insert(layer, at: index)
        } else {
            layers.append(layer)
        }
    }
    
    func removeLayers(_ removedLayers: [Layer]) {
        for layer in removedLayers {
            self.removeLayer(layer)
        }
    }

    func removeLayer(_ layer: Layer) {
        if let index = self.layers.firstIndex(where: { $0 === layer }) {
            self.layers.remove(at: index)
        }
    }

    func moveLayer(layer: Layer, to newIndex: Int) {
        guard let oldIndex = layers.firstIndex(where: { $0 === layer }) else {
            return
        }
        layers.remove(at: oldIndex)
        layers.insert(layer, at: newIndex)
    }

//    func updateLayer(layer: Layer, withDrawing drawing: PKDrawing) {
//        layers[layerId]?.setDrawing(to: drawing)
//    }
//

    func updateLayer(_ layer: Layer, with newLayer: Layer) {
        if let index = self.layers.firstIndex(where: { $0 === layer }) {
            self.layers[index] = newLayer
        }
    }
    
//    func generateThumbnail(of layerId: UUID) {
//        layers[layerId]?.generateThumbnail()
//    }
    
    func generateLayerThumbnails() {
        for layer in layers {
            layer.generateThumbnail()
        }
    }

    func duplicate(withId newShotId: UUID = UUID()) -> Shot {
        var list = [Layer]()
        for layer in layers.reversed() {
            list.append(layer.duplicate())
        }
        return Shot(canvasSize: canvasSize, backgroundColor: backgroundColor,
                    layers: list, thumbnail: thumbnail)
    }
    
    func setBackgroundColor(color: Color) {
        self.backgroundColor = color
    }
}

// MARK: - Thumbnailable
extension Shot: Thumbnailable {
}
