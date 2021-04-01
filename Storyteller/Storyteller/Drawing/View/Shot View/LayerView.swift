//
//  LayerView.swift
//  Storyteller
//
//  Created by TFang on 20/3/21.
//

import UIKit
import PencilKit

protocol LayerView: UIView {
    var topCanvasView: PKCanvasView? { get }
    func updateTransform(anchorPoint: CGPoint, transform: CGAffineTransform)
}

extension LayerView {
    func updateTransform(anchorPoint: CGPoint, transform: CGAffineTransform) {
        setAnchorPoint(anchorPoint)
        self.transform = transform
    }
}
