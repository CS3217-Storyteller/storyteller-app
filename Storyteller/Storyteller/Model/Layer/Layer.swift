//
//  Layer.swift
//  Storyteller
//
//  Created by TFang on 20/3/21.
//
import PencilKit

class Layer {
    var id: UUID
    var name: String
    var canvasSize: CGSize
    var isLocked: Bool
    var isVisible: Bool
    var component: LayerComponent
    
    var thumbnail: UIImage {
        component.image
    }

    init(
        id: UUID,
        name: String,
        canvasSize: CGSize,
        isLocked: Bool,
        isVisible: Bool,
        component: LayerComponent
    ) {
        self.id = id
        self.name = name
        self.canvasSize = canvasSize
        self.component = component
        self.isLocked = false
        self.isVisible = true
    }

    init(
        id: UUID,
        name: String = Constants.defaultLayerName,
        canvasSize: CGSize,
        layerWithDrawing: PKDrawing
    ) {
        self.id = id
        self.name = name
        self.canvasSize = canvasSize
        self.component = DrawingComponent(drawing: layerWithDrawing, canvasSize: canvasSize)
        self.isLocked = false
        self.isVisible = true
    }

    @discardableResult
    func setDrawing(to drawing: PKDrawing) -> Layer {
        self.updateComponent(self.component.setDrawing(to: drawing))
    }

    func updateComponent(_ component: LayerComponent) -> Layer {
        let newLayer = self
        newLayer.component = component
        return newLayer
    }

    func duplicate(withId newLayerId: UUID = UUID()) -> Layer {

        let newLayer = Layer(
            id: newLayerId,
            name: self.name,
            canvasSize: self.canvasSize,
            isLocked: self.isLocked,
            isVisible: self.isVisible,
            component: self.component
        )
        
        return newLayer
    }
}

extension Layer {
    static func getEmptyLayer(canvasSize: CGSize, name: String, shotId: UUID) -> Layer {
        Layer(
            id: shotId,
            name: name,
            canvasSize: canvasSize,
            layerWithDrawing: PKDrawing()
        )
    }
}

extension Layer: Transformable {
    var transform: CGAffineTransform {
        self.component.transform
    }
    
    func updateTransform(_ transform: CGAffineTransform) -> Self {
        guard let layer = self.updateComponent(component.updateTransform(transform)) as? Self else {
            return self
        }
        return layer
    }
}
