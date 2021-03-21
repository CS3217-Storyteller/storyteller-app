//
//  SceneLabel.swift
//  Storyteller
//
//  Created by TFang on 20/3/21.
//

import Foundation

struct SceneLabel {
    var projectLabel: ProjectLabel
    var sceneIndex: Int

    init(projectLabel: ProjectLabel, sceneIndex: Int) {
        self.projectLabel = projectLabel
        self.sceneIndex = sceneIndex
    }

    // TODO: Delete this after fully implement labelling
    init() {
        self.projectLabel = ProjectLabel()
        self.sceneIndex = 0
    }
}
