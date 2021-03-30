//
//  LayerComponentNode.swift
//  Storyteller
//
//  Created by TFang on 28/3/21.
//

import PencilKit

struct LayerComponentNode: Codable {
    enum NodeType {
        case composite([LayerComponentNode])
        case drawing(DrawingComponent)
    }

    var transformInfo = TransformInfo()

    var type: NodeType

    init(layerWithDrawing: PKDrawing, canvasSize: CGSize) {
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

    enum CodingKeys: String, CodingKey {
        case children
        case drawing

        case transformInfo
    }

    enum CodableError: Error {
        case decoding(String)
        case encoding(String)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(transformInfo, forKey: .transformInfo)

        switch type {
        case .composite(let children):
            var childrenContainer = container.nestedUnkeyedContainer(forKey: .children)
            try childrenContainer.encode(contentsOf: children)
        case .drawing(let drawingComponent):
            try container.encode(drawingComponent, forKey: .drawing)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        transformInfo = try container.decode(TransformInfo.self, forKey: .transformInfo)

        if let children = try? container.decode([LayerComponentNode].self, forKey: .children) {
            self.type = .composite(children)
            return
        }

        if let drawingComponent = try? container.decode(DrawingComponent.self, forKey: .drawing) {
            self.type = .drawing(drawingComponent)
            return
        }

        throw CodableError.decoding("Error while decoding LayerComponentNode")
    }
}

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

}
