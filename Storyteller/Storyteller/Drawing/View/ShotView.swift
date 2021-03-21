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

        toolPicker.setVisible(true, forFirstResponder: layerView)
        toolPicker.addObserver(layerView)
    }

    func setUpBackgroundColor(color: UIColor) {
        self.backgroundColor = color
    }

    func setPKDelegate(delegate: PKCanvasViewDelegate) {
        layerViews.forEach({ $0.delegate = delegate })
    }

    func updateZoomScale(scale: CGFloat) {
        layerViews.forEach { layerView in
            // TODO: Enable the following two lines after
            // implementing canvas rotation and zooming
//            layerView.minimumZoomScale = scale * Constants.minLayerZoomScale
//            layerView.maximumZoomScale = scale * Constants.maxLayerZoomScale
            layerView.minimumZoomScale = scale
            layerView.maximumZoomScale = scale
            layerView.zoomScale = scale
        }

    }
}
