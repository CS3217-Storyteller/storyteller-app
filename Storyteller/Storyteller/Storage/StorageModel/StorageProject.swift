//
//  StorageProject.swift
//  Storyteller
//
//  Created by TFang on 28/3/21.
//
import CoreGraphics

struct StorageProject: Codable {
    var scenes: [StorageScene]
    var label: ProjectLabel
    let canvasSize: CGSize
    let title: String

    init(_ project: Project) {
        self.scenes = project.scenes.map({ StorageScene($0) })
        self.label = project.label
        self.canvasSize = project.canvasSize
        self.title = project.title
    }
}

extension StorageProject {
    var project: Project {
        Project(scenes: scenes.map({ $0.scene }), label: label,
                canvasSize: canvasSize, title: title)
    }
}
