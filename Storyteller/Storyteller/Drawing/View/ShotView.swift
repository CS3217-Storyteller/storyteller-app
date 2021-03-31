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
        }
    }

    var currentCanvasView: PKCanvasView? {
        layerViews[selectedLayerIndex].canvasView
    }

    func selectLayer(at index: Int) {
        guard layerViews.indices.contains(index) else {
            return
        }
        layerViews[index].canvasView?.becomeFirstResponder()
    }

    // TODO: remove this
    func indexOfLayer(containing canvasView: PKCanvasView) -> Int? {
        layerViews.firstIndex(where: { $0.canvasView === canvasView })
    }
    func setUpLayerViews(_ layerViews: [LayerView], toolPicker: PKToolPicker,
                         PKDelegate: PKCanvasViewDelegate) {
        let oldViews = self.layerViews
        guard !layerViews.isEmpty else {
            return
        }

        layerViews.forEach({ add(layerView: $0, toolPicker: toolPicker) })
        layerViews.compactMap({ $0.canvasView }).forEach({ $0.delegate = PKDelegate })

        self.layerViews.removeFirst(oldViews.count)
        oldViews.forEach({ $0.removeFromSuperview() })
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

    func reset() {
        layerViews = []
        subviews.forEach({ $0.removeFromSuperview() })
    }
}
