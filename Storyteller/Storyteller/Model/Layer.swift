//
//  Layer.swift
//  Storyteller
//
//  Created by TFang on 20/3/21.
//
import PencilKit

struct Layer: Codable, Identifiable {
    var layerType: LayerType
    var drawing: PKDrawing
    let canvasSize: CGSize
    var label: LayerLabel
    var id: UUID

    mutating func setDrawingTo(_ updatedDrawing: PKDrawing) {
        drawing = updatedDrawing
    }

    func duplicate(withId newId: UUID = UUID()) -> Self {
        let newLabel = label.withLayerId(newId)
        return Self(layerType: layerType,
                    drawing: drawing,
                    canvasSize: canvasSize,
                    label: newLabel,
                    id: newId)
    }
}
