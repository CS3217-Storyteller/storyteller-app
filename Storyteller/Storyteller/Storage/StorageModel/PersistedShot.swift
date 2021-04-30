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
    let id: UUID

    init(_ shot: Shot) {
        self.layers = shot.layers.map({ $0.id })
        self.canvasSize = shot.canvasSize
        self.id = shot.id
    }
}
