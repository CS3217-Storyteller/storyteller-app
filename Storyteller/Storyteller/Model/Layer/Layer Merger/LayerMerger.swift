//
//  LayerMerger.swift
//  Storyteller
//
//  Created by TFang on 27/3/21.
//

import UIKit
import PencilKit

protocol LayerMerger {
    associatedtype T
    func mergeDrawing(component: DrawingComponent) -> T

    func merge(results: [T], composite: CompositeComponent) -> T
}
