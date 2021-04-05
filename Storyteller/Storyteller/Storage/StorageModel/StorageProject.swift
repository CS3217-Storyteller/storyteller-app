//
//  StorageProject.swift
//  Storyteller
//
//  Created by TFang on 28/3/21.
//
import Foundation
import CoreGraphics

struct StorageProject: Codable {
    var scenes: [UUID: StorageScene]
    var sceneOrder: [UUID]
    var label: ProjectLabel
    let canvasSize: CGSize
    let title: String

    init(_ project: Project) {
        self.scenes = project.scenes.mapValues({ StorageScene($0) })
        self.sceneOrder = project.sceneOrder
        self.label = project.label
        self.canvasSize = project.canvasSize
        self.title = project.title
    }
}

extension StorageProject {
    var project: Project {
        Project(id: label.projectId, label: label, title: title,
                canvasSize: canvasSize, scenes: scenes.mapValues({ $0.scene }), sceneOrder: sceneOrder)
    }
}
