//
//  Layer.swift
//  Storyteller
//
//  Created by TFang on 20/3/21.
//

import PencilKit

struct Layer: Codable {
    var layerType: LayerType
    var drawing: PKDrawing
    let canvasSize: CGSize

    mutating func setDrawingTo(_ updatedDrawing: PKDrawing) {
        drawing = updatedDrawing
    }
}

