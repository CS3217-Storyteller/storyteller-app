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
    var canvasView: PKCanvasView?

    init(canvasSize: CGSize) {
        self.canvasSize = canvasSize
        self.mergedLayer = LayerView(canvasSize: canvasSize)
    }

    func mergeDrawing(component: DrawingComponent) {
        let canvasView = PKCanvasView()
        canvasView.drawing = component.drawing

        mergedLayer.addSubview(canvasView)
        self.canvasView = canvasView
    }

}
