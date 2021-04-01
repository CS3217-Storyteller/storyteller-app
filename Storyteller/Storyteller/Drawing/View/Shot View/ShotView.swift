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

    var selectedLayerIndex = 0 {
        didSet {
            selectLayer(at: selectedLayerIndex)
            unselectLayer(at: oldValue)
        }
    }

    var currentCanvasView: PKCanvasView? {
        layerViews[selectedLayerIndex].topCanvasView
    }

    func selectLayer(at index: Int) {
        guard layerViews.indices.contains(index) else {
            return
        }
        layerViews[index].topCanvasView?.becomeFirstResponder()
        layerViews[index].castShadow()
    }
    func unselectLayer(at index: Int) {
        guard layerViews.indices.contains(index) else {
            return
        }
        layerViews[index].disableShadow()
    }

    func setUpLayerViews(_ layerViews: [LayerView], toolPicker: PKToolPicker,
                         PKDelegate: PKCanvasViewDelegate) {
        reset()
        guard !layerViews.isEmpty else {
            return
        }

        layerViews.forEach({ add(layerView: $0, toolPicker: toolPicker,
                                 PKDelegate: PKDelegate) })
        selectedLayerIndex = layerViews.count - 1

        clipsToBounds = true
    }

    func updateLayerTransform(_ newLayerView: LayerView) {
        layerViews[selectedLayerIndex]
            .updateTransform(anchorPoint: newLayerView.layer.anchorPoint,
                             transform: newLayerView.transform)
    }

    private func add(layerView: LayerView, toolPicker: PKToolPicker,
                     PKDelegate: PKCanvasViewDelegate) {
        layerViews.append(layerView)
        addSubview(layerView)

        guard let canvasView = layerView.topCanvasView else {
            return
        }
        canvasView.delegate = PKDelegate
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
    }

    func setUpBackgroundColor(color: UIColor) {
        self.backgroundColor = color
    }

    func reset() {
        layerViews = []
        subviews.forEach({ $0.removeFromSuperview() })
    }
}

extension ShotView {

}
