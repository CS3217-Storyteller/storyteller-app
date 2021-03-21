//
//  ProjectLabel.swift
//  Storyteller
//
//  Created by Marcus on 21/3/21.
//

import Foundation

struct ProjectLabel: Codable {
    var projectIndex: Int

    init(projectIndex: Int) {
        self.projectIndex = projectIndex
    }

    // TODO: Delete this after fully implement labelling
    init() {
        self.projectIndex = 0
    }
}
