//
//  Layer.swift
//  Storyteller
//
//  Created by TFang on 20/3/21.
//
import PencilKit

class Layer {
    var component: LayerComponent
    var name: String
    var canvasSize: CGSize
    var isLocked: Bool = false
    var isVisible = true {
        didSet {
            generateThumbnail()
        }
    }

    var thumbnail: Thumbnail

    init(component: LayerComponent, canvasSize: CGSize, name: String,
         isLocked: Bool, isVisible: Bool, thumbnail: Thumbnail?) {
        self.component = component
        self.canvasSize = canvasSize
        self.name = name
        guard let thumbnail = thumbnail else {
            self.thumbnail = Thumbnail()
            return
        }
        self.thumbnail = thumbnail
    }

    init(withDrawing drawing: PKDrawing, canvasSize: CGSize,
         name: String = Constants.defaultDrawingLayerName) {
        self.canvasSize = canvasSize
        self.component = DrawingComponent(canvasSize: canvasSize, drawing: drawing)
        self.name = name
        self.thumbnail = component.merge(merger: ThumbnailMerger())
    }

    init(withImage image: UIImage, canvasSize: CGSize,
         name: String = Constants.defaultImageLayerName) {
        self.canvasSize = canvasSize
        self.component = ImageComponent(
            canvasSize: canvasSize, imageData: image.pngData()!)
        self.name = name
        self.thumbnail = component.merge(merger: ThumbnailMerger())
    }

    @discardableResult
    func setDrawing(to drawing: PKDrawing) -> Layer {
        updateComponent(component.setDrawing(to: drawing))
    }

    func updateComponent(_ component: LayerComponent) -> Layer {
        let newLayer = self
        newLayer.component = component
        newLayer.generateThumbnail()
        return newLayer
    }

    func generateThumbnail() {
        guard isVisible else {
            thumbnail = Thumbnail()
            return
        }
        thumbnail = component.merge(merger: ThumbnailMerger())
    }

    func duplicate(withId newId: UUID = UUID()) -> Layer {
        Layer(
            component: component,
            canvasSize: canvasSize,
            name: name,
            isLocked: isLocked,
            isVisible: isVisible, // TODO: verify these values
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
                                    thumbnail: nil)})
    }
}

// MARK: - Transformable
extension Layer {
    func transformed(using transform: CGAffineTransform) -> Layer {
        updateComponent(component.transformed(using: transform))
    }

    var canTransform: Bool {
        !isLocked && isVisible
    }
}

// MARK: - Thumbnailable
extension Layer: Thumbnailable {
}
