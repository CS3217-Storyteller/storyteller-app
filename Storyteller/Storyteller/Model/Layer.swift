//
//  Layer.swift
//  Storyteller
//
//  Created by TFang on 20/3/21.
//
import PencilKit

struct Layer {
    var component: CompositeComponent
    var canvasSize: CGSize

    func addToMerger(_ merger: LayerMerger) {
        component.addToMerger(merger)
    }

    mutating func setDrawing(to updatedDrawing: PKDrawing) {

    }
}

