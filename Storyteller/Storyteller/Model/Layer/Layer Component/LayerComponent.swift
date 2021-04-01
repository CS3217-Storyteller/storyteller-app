//
//  LayerComponent.swift
//  Storyteller
//
//  Created by TFang on 28/3/21.
//

import PencilKit

protocol LayerComponent: Transformable {
    var canvasSize: CGSize { get }

    var image: UIImage { get }

    var containsDrawing: Bool { get }
    func setDrawing(to drawing: PKDrawing) -> Self

    func reduce<Result>(_ initialResult: Result,
                        _ nextPartialResult: (Result, LayerComponent) throws -> Result) rethrows -> Result
    func merge<Result, Merger>(merger: Merger) -> Result where Merger.T == Result, Merger: LayerMerger
}

extension LayerComponent {
    // TODO: the anchor point for Image Layer should be just the center point
    var anchorPoint: CGPoint {
        guard !(frame.isEmpty || frame.isInfinite) else {
            return CGPoint(x: 0.5, y: 0.5)
        }
        return CGPoint(x: frame.midX / canvasSize.width,
                       y: frame.midY / canvasSize.height)
    }
}
