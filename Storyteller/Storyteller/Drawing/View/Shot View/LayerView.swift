//
//  LayerView.swift
//  Storyteller
//
//  Created by TFang on 20/3/21.
//

import UIKit
import PencilKit

protocol LayerView: UIView {
    var toolPicker: PKToolPicker? { get set }
    var isLocked: Bool { get set }
    var isVisible: Bool { get set }
    var topCanvasView: PKCanvasView? { get }
    func updateTransform(anchorPoint: CGPoint, transform: CGAffineTransform)
}

extension LayerView {
    func updateTransform(anchorPoint: CGPoint, transform: CGAffineTransform) {
        setAnchorPoint(anchorPoint)
        self.transform = transform
    }
    func setUpPK(toolPicker: PKToolPicker, PKDelegate: PKCanvasViewDelegate) {
        self.toolPicker = toolPicker
        guard let canvasView = topCanvasView else {
            return
        }
        canvasView.delegate = PKDelegate
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
    }
}
