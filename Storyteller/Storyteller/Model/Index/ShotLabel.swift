//
//  ShotLabel.swift
//  Storyteller
//
//  Created by TFang on 20/3/21.
//
import Foundation

struct ShotLabel: Codable {
    var sceneLabel: SceneLabel
    var shotIndex: Int

    init(sceneLabel: SceneLabel, shotIndex: Int) {
        self.sceneLabel = sceneLabel
        self.shotIndex = shotIndex
    }

    // TODO: Delete this after fully implement labelling
    init() {
        self.sceneLabel = SceneLabel()
        self.shotIndex = 0
    }

    var projectIndex: Int {
        sceneLabel.projectIndex
    }

    var sceneIndex: Int {
        sceneLabel.sceneIndex
    }
}
