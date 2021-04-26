//
//  PersistedModelManager.swift
//  Storyteller
//
//  Created by mmarcus on 25/4/21.
//

import Foundation

class PersistenceModelManager {
    init(storageManager: StorageManager, modelManager: ModelManager) {
        self.storageManager = storageManager
        self.modelManager = modelManager
        self.persistedProjects = [ProjectPersistenceManager]()
        self.persistedScenes = [ScenePersistenceManager]()
        self.persistedShots = [ShotPersistenceManager]()
        self.persistedLayers = [LayerPersistenceManager]()
    }

    var storageManager: StorageManager
    var modelManager: ModelManager
    var persistedProjects: [ProjectPersistenceManager]
    var persistedScenes: [ScenePersistenceManager]
    var persistedShots: [ShotPersistenceManager]
    var persistedLayers: [LayerPersistenceManager]
}

extension PersistenceModelManager: ModelManagerObserver {
    func modelDidChange() {
        storageManager.save(projects: modelManager.projects)
        print("PersistenceModelManager: ModelManager changed!")
    }
}
