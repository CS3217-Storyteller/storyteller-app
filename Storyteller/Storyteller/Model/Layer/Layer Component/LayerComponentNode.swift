//
//  LayerComponentNode.swift
//  Storyteller
//
//  Created by TFang on 28/3/21.
//

import PencilKit

struct LayerComponentNode {
    enum NodeType {
        case composite([LayerComponentNode])
        case drawing(DrawingComponent)
    }

    var transformInfo: TransformInfo
    var type: NodeType

    init(transformInfo: TransformInfo, type: NodeType) {
        self.transformInfo = transformInfo
        self.type = type
    }
    init(layerWithDrawing: PKDrawing, canvasSize: CGSize,
         transformInfo: TransformInfo = TransformInfo()) {
        self.transformInfo = transformInfo

        let drawingComponent = DrawingComponent(drawing: layerWithDrawing,
                                                canvasSize: canvasSize)
        self.type = NodeType.drawing(drawingComponent)
    }

    var containsDrawing: Bool {
        switch type {
        case .composite(let children):
            return children.contains(where: { $0.containsDrawing })
        case .drawing:
            return true
        }
    }

    func append(_ node: LayerComponentNode) -> LayerComponentNode {
        var newNode = self
        switch type {
        case .composite(var children):
            children.append(node)
            newNode.type = NodeType.composite(children)
        case .drawing:
            newNode.type = NodeType.composite([self, node])
        }
        return newNode
    }
}

// MARK: - LayerComponent
extension LayerComponentNode: LayerComponent {
    var canvasSize: CGSize {
        switch type {
        case .composite(let children):
            return children.first?.canvasSize ?? .zero
        case .drawing(let drawingComponent):
            return drawingComponent.canvasSize
        }
    }

    var frame: CGRect {
        switch type {
        case .composite(let children):
            return children.map({ $0.frame }).reduce(CGRect.zero, { $0.union($1) })
        case .drawing(let drawingComponent):
            return drawingComponent.frame
        }
    }

    var image: UIImage {
        switch type {
        case .composite(let children):
            return children.reduce(UIImage.clearImage(ofSize: canvasSize), { $0.mergeWith($1.image) })
        case .drawing(let drawingComponent):
            return drawingComponent.image
        }
    }

    func updateTransformInfo(info: TransformInfo) -> LayerComponentNode {
        LayerComponentNode(transformInfo: info, type: type)
    }

    func setDrawing(to drawing: PKDrawing) -> LayerComponentNode {
        var newNode = self
        switch type {
        case .composite(var children):
            guard let index = children.lastIndex(where: { $0.containsDrawing }) else {
                return self
            }
            children[index] = children[index].setDrawing(to: drawing)
            newNode.type = NodeType.composite(children)
        case .drawing(let drawingComponent):
            newNode.type = NodeType.drawing(drawingComponent.setDrawing(to: drawing))
        }
        return newNode
    }

    func addToMerger(_ merger: LayerMerger) {
        switch type {
        case .composite(let children):
            return children.forEach({ $0.addToMerger(merger) })
        case .drawing(let drawingComponent):
            return drawingComponent.addToMerger(merger)
        }
    }
    func reduce<Result>(_ initialResult: Result, _ nextPartialResult: (Result, LayerComponent) throws -> Result) rethrows -> Result {
    }
}
