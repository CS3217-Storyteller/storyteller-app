//
//  DrawingLayerView.swift
//  Storyteller
//
//  Created by TFang on 1/4/21.
//

import UIKit
import PencilKit

class DrawingLayerView: UIView {
    private(set) var canvasView: PKCanvasView
    
    init(drawing: PKDrawing, canvasSize: CGSize) {
        let frame = CGRect(origin: .zero, size: canvasSize)
        canvasView = PKCanvasView(frame: frame)
        canvasView.drawing = drawing
        super.init(frame: frame)

        addSubview(canvasView)

    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DrawingLayerView: LayerView {
    var topCanvasView: PKCanvasView? {
        canvasView
    }
}
