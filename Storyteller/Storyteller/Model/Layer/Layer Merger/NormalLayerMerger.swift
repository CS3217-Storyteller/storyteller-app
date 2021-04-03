//
//  NormalLayerMerger.swift
//  Storyteller
//
//  Created by TFang on 27/3/21.
//

import PencilKit

class NormalLayerMerger: LayerMerger {

    let canvasSize: CGSize

    init(canvasSize: CGSize) {
        self.canvasSize = canvasSize
    }

    var frame: CGRect {
        CGRect(origin: .zero, size: canvasSize)
    }

    func mergeDrawing(component: DrawingComponent) -> LayerView {
        let drawingLayerView = DrawingLayerView(drawing: component.drawing,
                                                canvasSize: canvasSize)
        drawingLayerView.transform = component.transform

        return drawingLayerView
    }

    func merge(results: [LayerView], composite: CompositeComponent) -> LayerView {
        let mergedLayerView = CompositeLayerView(canvasSize: canvasSize, children: results)

        mergedLayerView.transform = composite.transform
        return mergedLayerView
    }
}
