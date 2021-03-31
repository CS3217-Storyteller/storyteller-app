//
//  NormalLayerMerger.swift
//  Storyteller
//
//  Created by TFang on 27/3/21.
//

import PencilKit

class NormalLayerMerger: LayerMerger {

    let canvasSize: CGSize
    var mergedLayer: LayerView

    init(canvasSize: CGSize) {
        self.canvasSize = canvasSize
        self.mergedLayer = LayerView(canvasSize: canvasSize)
    }

    var frame: CGRect {
        CGRect(origin: .zero, size: canvasSize)
    }
    func mergeDrawing(component: DrawingComponent) {
        let canvasView = PKCanvasView(frame: frame)
        canvasView.drawing = component.drawing

        canvasView.setAnchorPoint(component.anchorPoint)
        mergedLayer.addSubview(canvasView)
    }
}
