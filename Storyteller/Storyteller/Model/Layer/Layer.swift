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
//        DrawingUtility.generateLayerView(for: self).asImage()
    }

    init(component: LayerComponent, canvasSize: CGSize, name: String, isLocked: Bool, isVisible: Bool) {
        self.component = component
        self.canvasSize = canvasSize
        self.name = name
    }

    init(layerWithDrawing: PKDrawing, canvasSize: CGSize, name: String = Constants.defaultLayerName) {
        self.canvasSize = canvasSize
        self.component = DrawingComponent(drawing: layerWithDrawing, canvasSize: canvasSize)
        self.name = name
    }

    func setDrawing(to drawing: PKDrawing) -> Layer {
        updateComponent(component.setDrawing(to: drawing))
    }

}

extension Layer {
    static func getEmptyLayer(canvasSize: CGSize, name: String) -> Layer {
        Layer(layerWithDrawing: PKDrawing(), canvasSize: canvasSize, name: name)
    }
}

extension Layer {
    func updateComponent(_ component: LayerComponent) -> Layer {
        var newLayer = self
        newLayer.component = component
        return newLayer
    }

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

    func transformed(using transform: CGAffineTransform) -> Layer {
        component.transformed(using: transform)
    }

    var anchorPoint: CGPoint {
        CGPoint(x: component.transformedFrame.midX / canvasSize.width,
                y: component.transformedFrame.midY / canvasSize.height)
    }
}
