//
//  DrawingLayerView.swift
//  Storyteller
//
//  Created by TFang on 1/4/21.
//

import PencilKit

class DrawingLayerView: UIView {
    var toolPicker: PKToolPicker?

    var isLocked: Bool {
        didSet {
            updateLockEffect()
        }
    }

    var isVisible: Bool {
        didSet {
            isHidden = !isVisible
        }
    }
    private(set) var canvasView: PKCanvasView

    init(drawing: PKDrawing, canvasSize: CGSize,
         isLocked: Bool = false, isVisible: Bool = true) {
        let frame = CGRect(origin: .zero, size: canvasSize)
        canvasView = PKCanvasView(frame: frame)
        canvasView.drawing = drawing
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false

        self.isLocked = isLocked
        self.isVisible = isVisible
        super.init(frame: frame)

        addSubview(canvasView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DrawingLayerView: LayerView {
    func transform(using transform: CGAffineTransform) {
        canvasView.drawing.transform(using: transform)
    }
    var topCanvasView: PKCanvasView? {
        canvasView
    }
}
extension DrawingLayerView {
    override var canBecomeFirstResponder: Bool {
        true
    }
}
