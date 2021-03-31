//
//  CompositeComponent.swift
//  Storyteller
//
//  Created by TFang on 28/3/21.
//

import PencilKit

struct CompositeComponent {
    var transformInfo: TransformInfo
    var children: [LayerComponent]

    init(transformInfo: TransformInfo, children: [LayerComponent]) {
        self.transformInfo = transformInfo
        self.children = children
    }

}

extension CompositeComponent: LayerComponent {
    var canvasSize: CGSize {
        children.first?.canvasSize ?? .zero
    }

    var frame: CGRect {
        reduce(CGRect.zero, { $0.union($1.frame) })
    }
    func updateTransformInfo(info: TransformInfo) -> CompositeComponent {
        CompositeComponent(transformInfo: info, children: children)
    }

    var image: UIImage {
        reduce(UIImage.clearImage(ofSize: canvasSize), { $0.mergeWith($1.image) })
    }

    var containsDrawing: Bool {
        children.contains(where: { $0.containsDrawing })
    }
    func setDrawing(to drawing: PKDrawing) -> CompositeComponent {
        var newNode = self
        guard let index = children.lastIndex(where: { $0.containsDrawing }) else {
            return self
        }
        newNode.children[index] = children[index].setDrawing(to: drawing)
        return newNode
    }

    func merge<Result, Merger>(merger: Merger) -> Result where
        Result == Merger.T, Merger: LayerMerger {
        let childrenResult = children.map({ $0.merge(merger: merger) })
        return merger.merge(results: childrenResult, composite: self)
    }
    func reduce<Result>(_ initialResult: Result,
                        _ nextPartialResult: (Result, LayerComponent) throws -> Result) rethrows -> Result {
        try children.reduce(initialResult, nextPartialResult)
    }
}
