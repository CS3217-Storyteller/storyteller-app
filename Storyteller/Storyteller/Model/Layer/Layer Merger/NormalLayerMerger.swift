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
    func getTransform(from info: TransformInfo) -> CGAffineTransform {
        print(info)
        return CGAffineTransform(translationX: info.xTranslation, y: info.yTranslation)
            .rotated(by: info.rotation)
            .scaledBy(x: info.scale, y: info.scale)
    }
    func mergeDrawing(component: DrawingComponent) {
        let drawingLayerView = LayerView(canvasSize: canvasSize)

        let canvasView = PKCanvasView(frame: frame)
        canvasView.drawing = component.drawing

        drawingLayerView.setAnchorPoint(component.anchorPoint)
        drawingLayerView.transform = getTransform(from: component.transformInfo)
        drawingLayerView.addSubview(canvasView)

        mergedLayer.addSubview(drawingLayerView)
    }
}
