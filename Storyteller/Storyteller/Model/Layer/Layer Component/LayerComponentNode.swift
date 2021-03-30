//
//  LayerComponentNode.swift
//  Storyteller
//
//  Created by TFang on 28/3/21.
//

import PencilKit

struct LayerComponentNode: LayerComponent {

    var rotation = CGFloat.zero
    var scale = CGFloat.zero
    var xTranslation = CGFloat.zero
    var yTranslation = CGFloat.zero

    var type: NodeType

    enum NodeType {
        case composite([LayerComponentNode])
        case drawing(DrawingComponent)
    }

    var containsDrawing: Bool {
        switch type {
        case .composite(let children):
            return children.reduce(false, { $0 || $1.containsDrawing})
        case .drawing(_):
            return true
        }
    }
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

    func append(_ node: LayerComponentNode) -> LayerComponentNode {
        var newNode = self
        switch type {
        case .composite(var children):
            children.append(node)
            newNode.type = NodeType.composite(children)
        case .drawing(_):
            newNode.type = NodeType.composite([self, node])
        }
        return newNode
    }

    // may add remove() method if future features require

    func addToMerger(_ merger: LayerMerger) {
        switch type {
        case .composite(let children):
            return children.forEach({ $0.addToMerger(merger) })
        case .drawing(let drawingComponent):
            return drawingComponent.addToMerger(merger)
        }
    }
}
