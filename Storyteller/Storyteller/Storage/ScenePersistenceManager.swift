//
//  ShotPersistenceManager.swift
//  Storyteller
//
//  Created by mmarcus on 29/4/21.
//

import Foundation

class ScenePersistenceManager {
    private let manager: PersistenceManager

    var url: URL {
        manager.url
    }

    init(at url: URL) {
        self.manager = PersistenceManager(url: url)
    }

    func saveShot(_ shot: PersistedShot) {
        guard let data = manager.encodeToJSON(shot) else {
            return
        }
        let folderName = shot.id.uuidString
        manager.createFolder(named: folderName)
        manager.saveData(data, toFile: "Shot Metadata", atFolder: folderName)
    }

    func deleteShot(_ shot: PersistedShot) {
        let folderName = shot.id.uuidString
        manager.deleteFolder(named: folderName)
    }

    func loadPersistedShot(id: UUID) -> PersistedShot? {
        let folderName = id.uuidString
        guard let data = manager.loadData("Shot Metadata", atFolder: folderName) else {
            return nil
        }
        return try? JSONDecoder().decode(PersistedShot.self, from: data)
    }

    func getShotPersistenceManager(of shot: PersistedShot) -> ShotPersistenceManager {
        let folderName = shot.id.uuidString
        return ShotPersistenceManager(at: url.appendingPathComponent(folderName))
    }
}
