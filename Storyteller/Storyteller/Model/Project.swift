//
//  Project.swift
//  Storyteller
//
//  Created by Marcus on 21/3/21.
//
import PencilKit

class Project {
    var title: String
    let canvasSize: CGSize

    var scenes: [Scene] = []
    var id = UUID()

    init(title: String, canvasSize: CGSize, scenes: [Scene] = []) {
        self.title = title
        self.canvasSize = canvasSize
        self.scenes = scenes
    }

    func addScene(_ scene: Scene) {
        self.scenes.append(scene)
    }

    func deleteScene(at index: Int) {
        self.scenes.remove(at: index)
    }

    func setTitle(to title: String) {
        self.title = title
    }

    func duplicate() -> Project {
        Project(
            title: self.title,
            canvasSize: self.canvasSize,
            scenes: scenes.map({ $0.duplicate() })
        )
    }
}
