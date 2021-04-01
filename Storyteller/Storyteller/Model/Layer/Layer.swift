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

    var image: UIImage {
        component.image
    }

    init(component: LayerComponent, canvasSize: CGSize) {
        self.component = component
        self.canvasSize = canvasSize
    }

    init(layerWithDrawing: PKDrawing, canvasSize: CGSize) {
        self.canvasSize = canvasSize
        self.component = DrawingComponent(drawing: layerWithDrawing, canvasSize: canvasSize)
    }

    func setDrawing(to drawing: PKDrawing) -> Layer {
        Layer(component: component.setDrawing(to: drawing), canvasSize: canvasSize)
    }

}

extension Layer {
    func scaled(by scale: CGFloat) -> Layer {
        Layer(component: component.scaled(by: scale), canvasSize: canvasSize)
    }

    func rotated(by angle: CGFloat) -> Layer {
        Layer(component: component.rotated(by: angle), canvasSize: canvasSize)
    }

    func translatedBy(x: CGFloat, y: CGFloat) -> Layer {
        Layer(component: component.translatedBy(x: x, y: y), canvasSize: canvasSize)
    }

    func resetTransform() -> Layer {
        Layer(component: component.resetTransform(), canvasSize: canvasSize)
    }
}
