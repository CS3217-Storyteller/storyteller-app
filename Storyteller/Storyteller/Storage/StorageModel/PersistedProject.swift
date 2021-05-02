//
//  PersistedProject.swift
//  Storyteller
//
//  Created by mmarcus on 29/4/21.
//

import Foundation
import CoreGraphics

struct PersistedProject: Codable, PersistedDirectory {
    var description: String
    var dateAdded: Date
    var dateUpdated: Date
    var scenes: [UUID]
    let canvasSize: CGSize
    let name: String
    let id: UUID

    init(_ project: Project) {
        self.scenes = project.scenes.map({ $0.id })
        self.canvasSize = project.canvasSize
        self.name = project.name
        self.id = project.id
        self.dateAdded = project.dateAdded
        self.dateUpdated = project.dateUpdated
        self.description = project.description
    }
}
