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

    func duplicate() -> Shot {
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

    // MARK: - Layer Related Methods
    func addLayer(_ layer: Layer, at index: Int? = nil) {
        if let index = index {
            layers.insert(layer, at: index)
        } else {
            layers.append(layer)
        }
    }

    func duplicateLayers(at indices: [Int]) {
        for index in indices.reversed() {
            duplicateLayer(at: index)
        }
    }
    func duplicateLayer(at index: Int) {
        let duplicatedlayer = layers[index].duplicate()
        layers.insert(duplicatedlayer, at: index + 1)
    }
    func removeLayers(at indices: [Int]) {
        for index in indices.reversed() {
            layers.remove(at: index)
        }
    }

    func moveLayer(from oldIndex: Int, to newIndex: Int) {
        layers.insert(layers.remove(at: oldIndex), at: newIndex)
    }

    func updateLayer(_ layer: Layer, with newLayer: Layer) {
        if let index = self.layers.firstIndex(where: { $0 === layer }) {
            self.layers[index] = newLayer
        }
    }

    func groupLayers(at indices: [Int]) {
        guard let lastIndex = indices.last else {
            return
        }
        let newIndex = lastIndex - (indices.count - 1)

        let children = indices.map({ layers[$0].component })
        let component = CompositeComponent(children: children)
        let groupedLayer = Layer(component: component, canvasSize: canvasSize, name: Constants.defaultGroupedLayerName)
        removeLayers(at: indices)
        addLayer(groupedLayer, at: newIndex)
    }
    func ungroupLayer(at index: Int) {
        let layerToBeUngrouped = layers.remove(at: index)
        layerToBeUngrouped.ungroup().reversed().forEach({ addLayer($0, at: index) })
    }
}

// MARK: - Thumbnailable
extension Shot: Thumbnailable {
}
