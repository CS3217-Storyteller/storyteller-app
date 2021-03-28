//
//  DrawingUtility.swift
//  Storyteller
//
//  Created by TFang on 21/3/21.
//

import Foundation

class DrawingUtility {
    static func generateLayerView(for layer: Layer) -> LayerView {
        let merger = NormalLayerMerger(canvasSize: layer.canvasSize)
        layer.addToMerger(merger)
        return merger.mergedLayer
    }
}
