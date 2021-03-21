//
//  ShotLabel.swift
//  Storyteller
//
//  Created by TFang on 20/3/21.
//

struct ShotLabel {
    var sceneLabel: SceneLabel
    var shotIndex: Int

    init(sceneLabel: SceneLabel, shotIndex: Int) {
        self.sceneLabel = sceneLabel
        self.shotIndex = shotIndex
    }

    // TODO: Delete this after fully implement labelling
    init() {
        self.sceneLabel = SceneLabel(sceneIndex: 0)
        self.shotIndex = 0
    }
}
