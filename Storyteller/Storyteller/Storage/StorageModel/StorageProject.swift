//
//  StorageProject.swift
//  Storyteller
//
//  Created by TFang on 28/3/21.
//
import Foundation
import CoreGraphics

struct StorageProject: Codable {
    let id: UUID
    var title: String
    var canvasSize: CGSize
    var scenes: [UUID: StorageScene]
    var sceneOrder: [UUID]
    
    init(_ project: Project) {
        self.id = project.id
        self.title = project.title
        self.canvasSize = project.canvasSize
        self.scenes = project.scenes.mapValues({ StorageScene($0) })
        self.sceneOrder = project.sceneOrder
    }
}

extension StorageProject {
    var project: Project {
        Project(
            id: self.id,
            title: self.title,
            canvasSize: self.canvasSize,
            scenes: self.scenes.mapValues({ $0.scene }),
            sceneOrder: self.sceneOrder
        )
    }
}
