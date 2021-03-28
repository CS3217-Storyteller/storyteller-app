//
//  LayerMerger.swift
//  Storyteller
//
//  Created by TFang on 27/3/21.
//

import UIKit
import PencilKit

protocol LayerMerger {
    func mergeDrawing(layer: DrawingLayer)
    func mergeDrawing(component: DrawingComponent)
}
