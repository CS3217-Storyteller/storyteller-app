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
    var isLocked = false
    var isVisible = true {
        didSet {
            generateThumbnail()
        }
    }
    var id = UUID()

    var thumbnail: Thumbnail

    init(component: LayerComponent, canvasSize: CGSize, name: String,
         isLocked: Bool = false, isVisible: Bool = true, thumbnail: Thumbnail? = nil) {
        self.component = component
        self.canvasSize = canvasSize
        self.name = name
        self.isLocked = isLocked
        self.isVisible = isVisible
        guard let thumbnail = thumbnail else {
            self.thumbnail = Thumbnail()
            generateThumbnail()
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

    func setDrawing(to drawing: PKDrawing) {
        updateComponent(component.setDrawing(to: drawing))
    }

    func updateComponent(_ component: LayerComponent) {
        self.component = component
        generateThumbnail()
    }

    func generateThumbnail() {
        guard isVisible else {
            thumbnail = Thumbnail()
            return
        }
        thumbnail = component.merge(merger: ThumbnailMerger())
    }

    func ungroup() -> [Layer] {
        guard let children = (component as? CompositeComponent)?.children else {
            return [self]
        }
        return children.map({ Layer(component: $0, canvasSize: canvasSize,
                                    name: Constants.defaultUngroupedLayerName,
                                    isLocked: isLocked,
                                    isVisible: isVisible)})
    }
    func duplicate() -> Layer {
        Layer(component: component,
              canvasSize: canvasSize,
              name: name,
              isLocked: isLocked,
              isVisible: isVisible,
              thumbnail: thumbnail)
    }
}

// MARK: - Transformable
extension Layer {
    func transform(using transform: CGAffineTransform) {
        updateComponent(component.transformed(using: transform))
    }

    var canTransform: Bool {
        !isLocked && isVisible
    }
}

// MARK: - Thumbnailable
extension Layer: Thumbnailable {
}
