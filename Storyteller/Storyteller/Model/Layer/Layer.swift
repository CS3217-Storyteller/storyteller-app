//
//  Layer.swift
//  Storyteller
//
//  Created by TFang on 20/3/21.
//
import PencilKit

struct Layer {
    var canvasSize: CGSize
    var component: LayerComponent
    var name: String
    var isLocked = false
    var isVisible = true

    var thumbnail: UIImage {
        component.image
    }

    init(component: LayerComponent, canvasSize: CGSize, name: String, isLocked: Bool, isVisible: Bool) {
        self.component = component
        self.canvasSize = canvasSize
        self.name = name
    }

    init(layerWithDrawing: PKDrawing, canvasSize: CGSize, name: String = "New Layer") {
        self.canvasSize = canvasSize
        self.component = DrawingComponent(drawing: layerWithDrawing, canvasSize: canvasSize)
        self.name = name
    }

    func updateComponent(_ component: LayerComponent) -> Layer {
        var newLayer = self
        newLayer.component = component
        return newLayer
    }

    func setDrawing(to drawing: PKDrawing) -> Layer {
        updateComponent(component.setDrawing(to: drawing))
    }

}

extension Layer {
    func scaled(by scale: CGFloat) -> Layer {
        updateComponent(component.scaled(by: scale))
    }

    func rotated(by angle: CGFloat) -> Layer {
        updateComponent(component.rotated(by: angle))
    }

    func translatedBy(x: CGFloat, y: CGFloat) -> Layer {
        updateComponent(component.translatedBy(x: x, y: y))
    }

    func resetTransform() -> Layer {
        updateComponent(component.resetTransform())
    }
}

extension Layer {
    static func getEmptyLayer(canvasSize: CGSize, name: String) -> Layer {
        Layer(layerWithDrawing: PKDrawing(), canvasSize: canvasSize, name: name)
    }
}
