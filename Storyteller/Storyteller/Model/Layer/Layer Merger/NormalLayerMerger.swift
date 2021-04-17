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
        DrawingLayerView(drawing: component.drawing, canvasSize: canvasSize)
    }
    func mergeImage(component: ImageComponent) -> LayerView {
        let imageLayerView = ImageLayerView(canvasSize: canvasSize,
                                            image: component.image)
        imageLayerView.transform = component.transform
        return imageLayerView
    }
    func merge(results: [LayerView], composite: CompositeComponent) -> LayerView {
        CompositeLayerView(canvasSize: canvasSize, children: results)
    }

}
