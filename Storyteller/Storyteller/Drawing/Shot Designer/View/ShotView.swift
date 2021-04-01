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
    var toolPicker: PKToolPicker?

    var isInDrawingMode: Bool = false {
        didSet {
            updateEffectForSelectedLayer()
        }
    }

    private func updateEffectForSelectedLayer() {
        guard let canvasView = selectedLayerView.topCanvasView,
              !selectedLayerView.isLocked, selectedLayerView.isVisible else {
            return
        }
        isInDrawingMode ? selectedLayerView.castShadow()
            : selectedLayerView.disableShadow()
        toolPicker?.setVisible(isInDrawingMode, forFirstResponder: canvasView)
    }

    var selectedLayerIndex = 0 {
        didSet {
            unselectLayer(at: oldValue)
            selectLayer(at: selectedLayerIndex)
        }
    }
    var selectedLayerView: LayerView {
        layerViews[selectedLayerIndex]
    }
    var currentCanvasView: PKCanvasView? {
        selectedLayerView.topCanvasView
    }

    func selectLayer(at index: Int) {
        guard layerViews.indices.contains(index) else {
            return
        }
        layerViews[index].topCanvasView?.becomeFirstResponder()
        updateEffectForSelectedLayer()
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
        self.toolPicker = toolPicker
        layerViews.forEach({ add(layerView: $0, toolPicker: toolPicker,
                                 PKDelegate: PKDelegate) })
        selectedLayerIndex = layerViews.count - 1

        clipsToBounds = true
    }

    private func add(layerView: LayerView, toolPicker: PKToolPicker,
                     PKDelegate: PKCanvasViewDelegate) {
        layerViews.append(layerView)
        addSubview(layerView)

        layerView.setUpPK(toolPicker: toolPicker, PKDelegate: PKDelegate)
    }

    func setUpBackgroundColor(color: UIColor) {
        self.backgroundColor = color
    }

    func reset() {
        layerViews = []
        subviews.forEach({ $0.removeFromSuperview() })
    }
}

// MARK: - Update Layer View
extension ShotView {
    func updateLayerTransform(_ newLayerView: LayerView) {
        selectedLayerView.updateTransform(anchorPoint: newLayerView.layer.anchorPoint,
                                          transform: newLayerView.transform)
    }

    func toggleLayerLock() {
        selectedLayerView.isLocked.toggle()
        updateEffectForSelectedLayer()
    }
    func toggleLayerVisibility() {
        selectedLayerView.isVisible.toggle()
        updateEffectForSelectedLayer()
    }
}
