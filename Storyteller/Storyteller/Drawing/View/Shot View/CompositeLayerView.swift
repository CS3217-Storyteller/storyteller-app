//
//  CompositeLayerView.swift
//  Storyteller
//
//  Created by TFang on 1/4/21.
//
import UIKit
import PencilKit
class CompositeLayerView: UIView {
    private(set) var children: [LayerView]

    init(canvasSize: CGSize, children: [LayerView] = []) {
        let frame = CGRect(origin: .zero, size: canvasSize)
        self.children = children
        super.init(frame: frame)

        children.forEach({ addSubview($0) })
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CompositeLayerView: LayerView {
    var topCanvasView: PKCanvasView? {
        children.compactMap({ $0.topCanvasView }).last
    }
}
