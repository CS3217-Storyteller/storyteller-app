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
}

protocol SceneObserver: ModelObserver {
}

protocol ShotObserver: ModelObserver {
}

protocol LayerObserver: ModelObserver {
}
