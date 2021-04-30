//
//  ProjectPersistenceManager.swift
//  Storyteller
//
//  Created by mmarcus on 29/4/21.
//

import Foundation

class ProjectPersistenceManager {
    private let manager: PersistenceManager

    var url: URL {
        manager.url
    }

    init(at url: URL) {
        self.manager = PersistenceManager(url: url)
    }

    func saveScene(_ scene: PersistedScene) {
        guard let data = manager.encodeToJSON(scene) else {
            return
        }
        let folderName = scene.id.uuidString
        manager.createFolder(named: folderName)
        manager.saveData(data, toFile: "Scene Metadata", atFolder: folderName)
    }

    func deleteScene(_ scene: PersistedScene) {
        let folderName = scene.id.uuidString
        manager.deleteFolder(named: folderName)
    }

    func loadPersistedScene(id: UUID) -> PersistedScene? {
        let folderName = id.uuidString
        guard let data = manager.loadData("Scene Metadata", atFolder: folderName) else {
            return nil
        }
        return try? JSONDecoder().decode(PersistedScene.self, from: data)
    }

    func getScenePersistenceManager(of scene: PersistedScene) -> ScenePersistenceManager {
        let folderName = scene.id.uuidString
        return ScenePersistenceManager(at: url.appendingPathComponent(folderName))
    }
}
