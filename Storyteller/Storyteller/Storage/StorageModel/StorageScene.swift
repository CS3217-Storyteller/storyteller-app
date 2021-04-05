//
//  StorageScene.swift
//  Storyteller
//
//  Created by TFang on 28/3/21.
//

import CoreGraphics
import Foundation

struct StorageScene: Codable {
    var shots: [UUID: StorageShot]
    var shotOrder: [UUID]
    var label: SceneLabel
    let canvasSize: CGSize

    init(_ scene: Scene) {
        self.shots = scene.shots.mapValues({ StorageShot($0) })
        self.shotOrder = scene.shotOrder
        self.label = scene.label
        self.canvasSize = scene.canvasSize
    }
}

extension StorageScene {
    var scene: Scene {
        Scene(label: label,
              canvasSize: canvasSize,
              id: label.sceneId,
              shots: shots.mapValues({ $0.shot }),
              shotOrder: shotOrder)
    }
}
