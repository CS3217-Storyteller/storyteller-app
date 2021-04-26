//
//  ModelObserver.swift
//  Storyteller
//
//  Created by mmarcus on 25/4/21.
//

import Foundation

protocol ModelObserver {
    func modelDidChange()
}

protocol ModelManagerObserver: ModelObserver {
}

protocol ProjectObserver: ModelObserver {
}

protocol SceneObserver: ModelObserver {
}

protocol ShotObserver: ModelObserver {
}

protocol LayerObserver: ModelObserver {
}
