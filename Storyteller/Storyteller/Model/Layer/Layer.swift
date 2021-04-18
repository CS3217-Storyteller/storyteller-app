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

    var thumbnail: UIImage

    init(component: LayerComponent, canvasSize: CGSize, name: String,
         isLocked: Bool, isVisible: Bool, label: LayerLabel,
         thumbnail: UIImage?) {
        self.component = component
        self.canvasSize = canvasSize
        self.name = name
        self.label = label
        self.id = label.layerId
        guard let thumbnail = thumbnail else {
            self.thumbnail = component.merge(merger: NormalImageMerger())
            return
        }
        self.thumbnail = thumbnail
    }

    init(withDrawing drawing: PKDrawing, canvasSize: CGSize,
         name: String = Constants.defaultDrawingLayerName, label: LayerLabel) {
        self.canvasSize = canvasSize
        self.component = DrawingComponent(canvasSize: canvasSize, drawing: drawing)
        self.name = name
        self.label = label
        self.id = label.layerId
        self.thumbnail = component.merge(merger: NormalImageMerger())
    }
    init(withImage image: UIImage, canvasSize: CGSize,
         name: String = Constants.defaultImageLayerName, label: LayerLabel) {
        self.canvasSize = canvasSize
        self.component = ImageComponent(
            canvasSize: canvasSize, imageData: image.scaleToFit(canvasSize).pngData()!)
        self.name = name
        self.label = label
        self.id = label.layerId
        self.thumbnail = component.merge(merger: NormalImageMerger())
    }

    @discardableResult
    func setDrawing(to drawing: PKDrawing) -> Layer {
        updateComponent(component.setDrawing(to: drawing))
    }

    func updateComponent(_ component: LayerComponent) -> Layer {
        var newLayer = self
        newLayer.component = component
//        newLayer.generateThumbnail()
        return newLayer
    }
    mutating func generateThumbnail() {
        thumbnail = component.merge(merger: NormalImageMerger())
    }
    mutating func updateThumbnail(using thumbnail: UIImage) {
        self.thumbnail = thumbnail
    }

    func duplicate(withId newId: UUID = UUID()) -> Layer {
        let newLabel = label.withLayerId(newId)
        return Layer(
            component: component,
            canvasSize: canvasSize,
            name: name,
            isLocked: isLocked,
            isVisible: isVisible, // TODO: verify these values
            label: newLabel,
            thumbnail: thumbnail
        )
    }
    func ungroup() -> [Layer] {
        guard let children = (component as? CompositeComponent)?.children else {
            return [self]
        }
        return children.map({ Layer(component: $0, canvasSize: canvasSize,
                                    name: Constants.defaultUngroupedLayerName,
                                    isLocked: isLocked,
                                    isVisible: isVisible,
                                    label: label.withLayerId(UUID()),
                                    thumbnail: nil)})
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
