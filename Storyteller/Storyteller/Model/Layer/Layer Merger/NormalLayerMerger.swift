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

    func mergeDrawing(component: DrawingComponent) -> LayerView {
        let drawingLayerView = LayerView(canvasSize: canvasSize)

        let canvasView = PKCanvasView(frame: frame)
        canvasView.drawing = component.drawing
        drawingLayerView.addSubview(canvasView)

        transformLayer(layerView: drawingLayerView, component: component)
        return drawingLayerView
    }

    func merge(results: [LayerView], composite: CompositeComponent) -> LayerView {
        let mergedLayerView = LayerView(canvasSize: canvasSize)

        results.forEach({ mergedLayerView.addSubview($0) })

        transformLayer(layerView: mergedLayerView, component: composite)
        return mergedLayerView
    }

    private func transformLayer(layerView: LayerView, component: LayerComponent) {
        layerView.setAnchorPoint(component.anchorPoint)
        layerView.transform = getTransform(from: component.transformInfo)
    }
    private func getTransform(from info: TransformInfo) -> CGAffineTransform {
        CGAffineTransform(translationX: info.xTranslation, y: info.yTranslation)
            .rotated(by: info.rotation)
            .scaledBy(x: info.scale, y: info.scale)
    }
}
