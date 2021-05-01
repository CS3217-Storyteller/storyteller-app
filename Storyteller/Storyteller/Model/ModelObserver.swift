//
//  ModelObserver.swift
//  Storyteller
//
//  Created by mmarcus on 1/5/21.
//

import Foundation

protocol ModelObserver {
    func modelDidChange()
}

protocol ModelManagerObserver: ModelObserver {
    var modelManager: ModelManager { get set }
}

protocol ProjectObserver: ModelObserver {
    var project: Project? { get set }
}

protocol SceneObserver: ModelObserver {
    var scene: Scene! { get set }
}

protocol ShotObserver: ModelObserver {
    var shot: Shot! { get set }
}

protocol LayerObserver: ModelObserver {
    var layer: Layer! { get set }
}
