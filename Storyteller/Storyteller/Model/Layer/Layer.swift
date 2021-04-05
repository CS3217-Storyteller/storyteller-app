//
//  Layer.swift
//  Storyteller
//
//  Created by TFang on 20/3/21.
//
import PencilKit

struct Layer {
    var component: LayerComponent
    var canvasSize: CGSize
    var name: String
    var label: LayerLabel
    var id: UUID
    var isLocked = false
    var isVisible = true

    var thumbnail: UIImage {
        component.image
//        DrawingUtility.generateLayerView(for: self).asImage()
    }

    init(component: LayerComponent, canvasSize: CGSize, name: String,
         isLocked: Bool, isVisible: Bool, label: LayerLabel) {
        self.component = component
        self.canvasSize = canvasSize
        self.name = name
        self.label = label
        self.id = label.layerId
    }

    init(layerWithDrawing: PKDrawing, canvasSize: CGSize,
         name: String = Constants.defaultLayerName, label: LayerLabel) {
        self.canvasSize = canvasSize
        self.component = DrawingComponent(drawing: layerWithDrawing, canvasSize: canvasSize)
        self.name = name
        self.label = label
        self.id = label.layerId
    }

    @discardableResult
    func setDrawing(to drawing: PKDrawing) -> Layer {
        updateComponent(component.setDrawing(to: drawing))
    }

    func updateComponent(_ component: LayerComponent) -> Layer {
        var newLayer = self
        newLayer.component = component
        return newLayer
    }

    func duplicate(withId newId: UUID = UUID()) -> Self {
        let newLabel = self.label.withLayerId(newId)
        return Self(
            component: self.component,
            canvasSize: self.canvasSize,
            name: self.name,
            isLocked: false,
            isVisible: true, // TODO: verify these values
            label: newLabel
        )
    }
}

extension Layer {
    static func getEmptyLayer(canvasSize: CGSize, name: String, forShot shotLabel: ShotLabel) -> Layer {
        Layer(layerWithDrawing: PKDrawing(),
              canvasSize: canvasSize,
              name: name,
              label: shotLabel.generateLayerLabel(withId: UUID())
        )
    }
}

extension Layer: Transformable {
    var transform: CGAffineTransform {
        component.transform
    }
    func updateTransform(_ transform: CGAffineTransform) -> Layer {
        updateComponent(component.updateTransform(transform))
    }
}
