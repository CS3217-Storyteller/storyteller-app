//
//  DrawingUtility.swift
//  Storyteller
//
//  Created by TFang on 21/3/21.
//

class DrawingUtility {
    static func generateLayerView(for layer: Layer) -> LayerView {
        let layerView = layer.component.merge(merger: NormalLayerMerger(canvasSize: layer.canvasSize))
        layerView.isLocked = layer.isLocked
        layerView.isVisible = layer.isVisible
        return layerView
    }
    static func generateLayerViews(for shot: Shot) -> [LayerView] {
        shot.orderedLayers.map({ generateLayerView(for: $0) })
    }
}
