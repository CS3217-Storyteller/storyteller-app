//
//  CompositeComponent.swift
//  Storyteller
//
//  Created by TFang on 28/3/21.
//

import PencilKit

struct CompositeComponent: LayerComponent {
    var components: [LeafComponent]

    var canvasSize: CGSize {
        components.first?.canvasSize ?? .zero
    }

    var frame: CGRect {
        components.map({ $0.frame }).reduce(CGRect.zero, { $0.union($1) })
    }

    mutating func setDrawing(to drawing: PKDrawing) {
        guard let index = components.lastIndex(where: { $0.leafType != .drawing }) else {
            return
        }
        components[index].setDrawing(to: drawing)
    }

    mutating func append(_ composite: CompositeComponent) {
        components.append(contentsOf: composite.components)
    }

    mutating func append(_ leaf: LeafComponent) {
        components.append(leaf)
    }

    // may add remove() method if future features require

    func addToMerger(_ merger: LayerMerger) {
        components.forEach({ $0.addToMerger(merger) })
    }
}
