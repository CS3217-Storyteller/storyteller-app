//
//  PersistedShot.swift
//  Storyteller
//
//  Created by mmarcus on 29/4/21.
//

import Foundation
import CoreGraphics

struct PersistedShot: Codable {
    var layers: [UUID]
    let canvasSize: CGSize

    init(_ shot: Shot) {
        self.layers = shot.layers.map({ $0.id })
        self.canvasSize = shot.canvasSize
    }
}
