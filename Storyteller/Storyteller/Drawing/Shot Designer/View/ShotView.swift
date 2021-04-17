//
//  ShotView.swift
//  Storyteller
//
//  Created by TFang on 20/3/21.
//
import PencilKit

class ShotView: UIView {
    var layerViews = [LayerView]()
    var toolPicker: PKToolPicker?

    var isInDrawingMode: Bool = false {
        didSet {
            updateEffectForSelectedLayer()
        }
    }
    var selectedLayerIndex = 0 {
        didSet {
            updateEffectForSelectedLayer()
        }
    }
    var selectedLayerView: LayerView {
        layerViews[selectedLayerIndex]
    }
    var currentCanvasView: PKCanvasView? {
        selectedLayerView.topCanvasView
    }

    private func updateEffectForSelectedLayer() {
        guard let canvasView = currentCanvasView,
              !selectedLayerView.isLocked, selectedLayerView.isVisible else {
            selectedLayerView.becomeFirstResponder()
            return
        }
        layerViews.forEach({ $0.isUserInteractionEnabled = false })
        selectedLayerView.isUserInteractionEnabled = true

        canvasView.becomeFirstResponder()
        toolPicker?.setVisible(isInDrawingMode, forFirstResponder: canvasView)
    }

    func setUpLayerViews(_ layerViews: [LayerView], toolPicker: PKToolPicker,
                         PKDelegate: PKCanvasViewDelegate) {
        let originalLayerCount = layerViews.count
        reset()
        guard !layerViews.isEmpty else {
            return
        }
        self.toolPicker = toolPicker
        layerViews.forEach({ add(layerView: $0, toolPicker: toolPicker,
                                 PKDelegate: PKDelegate) })

        guard layerViews.count == originalLayerCount else {
            selectedLayerIndex = layerViews.count - 1
            return
        }
        let selected = selectedLayerIndex
        selectedLayerIndex = selected
    }

    func add(layerView: LayerView, toolPicker: PKToolPicker,
             PKDelegate: PKCanvasViewDelegate) {
        layerViews.append(layerView)
        addSubview(layerView)
        layerView.setUpPK(toolPicker: toolPicker, PKDelegate: PKDelegate)
    }
    func remove(at index: Int) {
        let layer = layerViews.remove(at: index)
        layer.removeFromSuperview()

        selectedLayerIndex = max(0, index - 1)
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
    func transformedSelectedLayer(using transform: CGAffineTransform) {
        selectedLayerView.transform = selectedLayerView.transform
            .concatenating(transform)
    }

    func updateLayerViews(newLayerViews: [LayerView]) {
        for i in newLayerViews.indices {
            layerViews[i].isLocked = newLayerViews[i].isLocked
            layerViews[i].isVisible = newLayerViews[i].isVisible

            updateEffectForSelectedLayer()
        }
    }

    func removeLayers(at indices: [Int]) {
        for index in indices.reversed() {
            remove(at: index)
        }
    }
    func moveLayer(from oldIndex: Int, to newIndex: Int) {
        layerViews.insert(layerViews.remove(at: oldIndex), at: newIndex)
    }
}
