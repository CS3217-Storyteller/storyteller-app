//
//  ShotView.swift
//  Storyteller
//
//  Created by TFang on 20/3/21.
//
import UIKit
import PencilKit

class ShotView: UIView {
    var layerViews = [LayerView]()

    func indexOfLayer(containing canvasView: PKCanvasView) -> Int? {
        layerViews.firstIndex(where: { $0.canvasView === canvasView })
    }
    func setUpLayerViews(_ layerViews: [LayerView], toolPicker: PKToolPicker) {

        guard !layerViews.isEmpty else {
            let layerView = LayerView(canvasSize: frame.size)
            add(layerView: layerView, toolPicker: toolPicker)
            return
        }

        layerViews.forEach({ add(layerView: $0, toolPicker: toolPicker) })
    }

    func add(layerView: LayerView, toolPicker: PKToolPicker) {
        layerViews.append(layerView)
        addSubview(layerView)

        guard let canvasView = layerView.canvasView else {
            return
        }
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
    }

    func setUpBackgroundColor(color: UIColor) {
        self.backgroundColor = color
    }

    func setPKDelegate(delegate: PKCanvasViewDelegate) {
        layerViews.compactMap({ $0.canvasView }).forEach({ $0.delegate = delegate })
    }

    func updateZoomScale(scale: CGFloat) {
        layerViews.forEach { layerView in
            // TODO: Enable the following two lines after
            // implementing canvas rotation and zooming
//            layerView.minimumZoomScale = scale * Constants.minLayerZoomScale
//            layerView.maximumZoomScale = scale * Constants.maxLayerZoomScale
            layerView.canvasView?.minimumZoomScale = scale
            layerView.canvasView?.maximumZoomScale = scale
            layerView.canvasView?.zoomScale = scale
        }

    }
}
