//
//  StorageScene.swift
//  Storyteller
//
//  Created by TFang on 28/3/21.
//

import CoreGraphics
import Foundation

struct StorageScene: Codable {
    let id: UUID
    var canvasSize: CGSize
    var shots: [UUID: StorageShot]
    var shotOrder: [UUID]
    
    init(_ scene: Scene) {
        self.id = scene.id
        self.canvasSize = scene.canvasSize
        self.shots = scene.shots.mapValues({ StorageShot($0) })
        self.shotOrder = scene.shotOrder
    }
}

extension StorageScene {
    var scene: Scene {
        Scene(
            id: self.id,
            canvasSize: self.canvasSize,
            shots: self.shots.mapValues({ $0.shot }),
            shotOrder: self.shotOrder
        )
    }
}
