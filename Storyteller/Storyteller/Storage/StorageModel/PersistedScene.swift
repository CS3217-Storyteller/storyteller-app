//
//  PersistedScene.swift
//  Storyteller
//
//  Created by mmarcus on 29/4/21.
//

import Foundation
import CoreGraphics

struct PersistedScene: Codable {
    var shots: [UUID]
    let canvasSize: CGSize

    init(_ scene: Scene) {
        self.shots = scene.shots.map({ $0.id })
        self.canvasSize = scene.canvasSize
    }
}
