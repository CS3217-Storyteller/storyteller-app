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
        component.thumbnail
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

    init(withDrawing drawing: PKDrawing, canvasSize: CGSize,
         name: String = Constants.defaultDrawingLayerName, label: LayerLabel) {
        self.canvasSize = canvasSize
        self.component = DrawingComponent(canvasSize: canvasSize, drawing: drawing)
        self.name = name
        self.label = label
        self.id = label.layerId
    }
    init(withImage image: UIImage, canvasSize: CGSize,
         name: String = Constants.defaultImageLayerName, label: LayerLabel) {
        self.canvasSize = canvasSize
        self.component = ImageComponent(canvasSize: canvasSize,
                                        imageData: image.pngData()!)
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

extension Layer: Transformable {
    func transformed(using transform: CGAffineTransform) -> Layer {
        updateComponent(component.transformed(using: transform))
    }

    var canTransform: Bool {
        !isLocked && isVisible
    }
}
