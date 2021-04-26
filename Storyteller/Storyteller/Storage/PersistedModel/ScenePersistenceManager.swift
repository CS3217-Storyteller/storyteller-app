//
//  ScenePersistenceManager.swift
//  Storyteller
//
//  Created by mmarcus on 25/4/21.
//

import Foundation

struct ScenePersistenceManager: Identifiable {
    var scene: Scene
    var storageManager: StorageManager
    var id: UUID {
        scene.id
    }
}

// MARK: - SceneObserver
extension ScenePersistenceManager: SceneObserver {
    func modelDidChange() {
        print("ScenePersistenceManager: Scene changed!")
    }
}
