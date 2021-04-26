//
//  PersistedScene.swift
//  Storyteller
//
//  Created by mmarcus on 26/4/21.
//

import CoreGraphics
import Foundation

struct PersistedScene: Codable {
    var shots: [UUID]
    let canvasSize: CGSize
    let id: UUID

    init(_ scene: Scene) {
        self.shots = scene.shots.map({ $0.id })
        self.canvasSize = scene.canvasSize
        self.id = scene.id
    }
}
