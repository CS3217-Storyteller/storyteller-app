//
//  DrawingUtility.swift
//  Storyteller
//
//  Created by TFang on 21/3/21.
//

import Foundation

class DrawingUtility {
    static func generateLayerView(for layer: Layer) -> LayerView {
        let layerView = LayerView(canvasSize: layer.canvasSize)
        
        switch layer.layerType {
        case .drawing:
            layerView.drawing = layer.drawing
        default: break
        }

        return layerView
    }
}
