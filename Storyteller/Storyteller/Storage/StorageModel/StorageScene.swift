//
//  StorageScene.swift
//  Storyteller
//
//  Created by TFang on 28/3/21.
//

import CoreGraphics
import Foundation

struct StorageScene: Codable {
    var shots: [StorageShot]
    let canvasSize: CGSize

    init(_ scene: Scene) {
        self.shots = scene.shots.map({ StorageShot($0) })
        self.canvasSize = scene.canvasSize
    }
}

extension StorageScene {
    var scene: Scene {
        Scene(canvasSize: canvasSize,
              shots: shots.map({ $0.shot }))
    }
}
