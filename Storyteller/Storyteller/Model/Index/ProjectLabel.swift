//
//  ProjectLabel.swift
//  Storyteller
//
//  Created by Marcus on 21/3/21.
//

import Foundation

struct ProjectLabel: Codable {
    var projectIndex: Int
    var projectTitle: String

    init(title: String, projectIndex: Int) {
        self.projectIndex = projectIndex
        self.projectTitle = title
    }

    // TODO: Delete this after fully implement labelling
    init() {
        self.projectIndex = 0
        self.projectTitle = "Sample"
    }
}
