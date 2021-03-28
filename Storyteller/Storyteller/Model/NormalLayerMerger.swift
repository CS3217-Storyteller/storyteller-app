//
//  NormalLayerMerger.swift
//  Storyteller
//
//  Created by TFang on 27/3/21.
//

import PencilKit

class NormalLayerMerger: LayerMerger {

    var mergedLayer: UIView?
    var canvasView: PKCanvasView?

    func mergeDrawing(component: DrawingComponent) {
        // TODO
    }

    func merge(layer1: MergableLayer, layer2: MergableLayer) -> MergableLayer {
        layer2.view.addSubview(layer1.view)
        layer2.view.bringSubviewToFront(layer1.view)
        return layer2
    }
}
