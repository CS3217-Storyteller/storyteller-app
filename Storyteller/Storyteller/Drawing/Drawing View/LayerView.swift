//
//  LayerView.swift
//  Storyteller
//
//  Created by TFang on 20/3/21.
//

import UIKit
import PencilKit

class LayerView: PKCanvasView {

    init(canvasSize: CGSize) {
        let frame = CGRect(origin: .zero, size: canvasSize)
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
