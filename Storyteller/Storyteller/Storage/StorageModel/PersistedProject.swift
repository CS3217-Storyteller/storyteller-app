//
//  PersistedProject.swift
//  Storyteller
//
//  Created by mmarcus on 29/4/21.
//

import Foundation
import CoreGraphics

struct PersistedProject: Codable {
    var scenes: [UUID]
    let canvasSize: CGSize
    let title: String
    let id: UUID

    init(_ project: Project) {
        self.scenes = project.scenes.map({ $0.id })
        self.canvasSize = project.canvasSize
        self.title = project.name
        self.id = project.id
    }
}
