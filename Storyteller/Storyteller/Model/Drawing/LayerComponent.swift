//
//  LayerComponent.swift
//  Storyteller
//
//  Created by TFang on 28/3/21.
//

import PencilKit

protocol LayerComponent {
    var frame: CGRect { get }
    mutating func setDrawing(to drawing: PKDrawing)
    func addToMerger(_ merger: LayerMerger)
}

extension LayerComponent {
    mutating func setDrawing(to drawing: PKDrawing){}
}
