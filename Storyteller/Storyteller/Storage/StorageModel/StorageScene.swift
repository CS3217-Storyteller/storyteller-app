//
//  StorageScene.swift
//  Storyteller
//
//  Created by TFang on 28/3/21.
//

import CoreGraphics

struct StorageScene: Codable {
    var shots: [StorageShot]
    var label: SceneLabel
    let canvasSize: CGSize

    init(_ scene: Scene) {
        self.shots = scene.shots.map({ StorageShot($0) })
        self.label = scene.label
        self.canvasSize = scene.canvasSize
    }
}

extension StorageScene {
    var scene: Scene {
        Scene(shots: shots.map({ $0.shot }), label: label, canvasSize: canvasSize)
    }
}
