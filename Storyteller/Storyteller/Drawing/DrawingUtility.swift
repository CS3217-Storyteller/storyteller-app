//
//  DrawingUtility.swift
//  Storyteller
//
//  Created by TFang on 21/3/21.
//

import Foundation

class DrawingUtility {
    static func generateLayerView(for layer: Layer) -> LayerView {
        layer.component.merge(merger: NormalLayerMerger(canvasSize: layer.canvasSize))
    }
}
