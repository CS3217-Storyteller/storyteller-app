//
//  StorageProject.swift
//  Storyteller
//
//  Created by TFang on 28/3/21.
//
import Foundation
import CoreGraphics

struct StorageProject: Codable {
    var scenes: [StorageScene]
    let canvasSize: CGSize
    let title: String

    init(_ project: Project) {
        self.scenes = project.scenes.map({ StorageScene($0) })
        self.canvasSize = project.canvasSize
        self.title = project.title
    }
}

extension StorageProject {
    var project: Project {
        Project(title: title, canvasSize: canvasSize,
                scenes: scenes.map({ $0.scene }))
    }
}
