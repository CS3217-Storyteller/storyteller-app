//
//  DrawingUtility.swift
//  Storyteller
//
//  Created by TFang on 21/3/21.
//

import Foundation

class DrawingUtility {
    static func generateLayerView(for layer: Layer) -> LayerView {
        let layerView = layer.component.merge(merger: NormalLayerMerger(canvasSize: layer.canvasSize))
        layerView.isLocked = layer.isLocked
        layerView.isVisible = layer.isVisible
        return layerView
    }
}
