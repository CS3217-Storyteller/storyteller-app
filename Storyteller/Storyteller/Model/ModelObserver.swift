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

protocol FolderObserver: ModelObserver {
    var folder: Folder { get set }
}

protocol ProjectObserver: ModelObserver {
}

protocol SceneObserver: ModelObserver {
}

protocol ShotObserver: ModelObserver {
}

protocol LayerObserver: ModelObserver {
}
