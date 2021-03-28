//
//  LayerView.swift
//  Storyteller
//
//  Created by TFang on 20/3/21.
//

import UIKit
import PencilKit

class LayerView: UIView {

    var canvasView: PKCanvasView? {
        subviews.compactMap({ $0 as? PKCanvasView }).last
    }

    init(canvasSize: CGSize) {
        let frame = CGRect(origin: .zero, size: canvasSize)
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
