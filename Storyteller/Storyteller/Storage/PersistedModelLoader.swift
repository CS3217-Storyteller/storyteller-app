//
//  PersistedModelLoader.swift
//  Storyteller
//
//  Created by mmarcus on 29/4/21.
//

import Foundation

class PersistedModelLoader {
    let manager = PersistenceManager()

    func loadPersistedProjects() -> [PersistedProject] {
        let data = manager.getAllDirectoryUrls()?.compactMap {
            manager.loadData("Project Metadata", atFolder: $0.lastPathComponent.description)
        }
        let decoder = JSONDecoder()
        return data?.compactMap { try? decoder.decode(PersistedProject.self, from: $0) } ?? [PersistedProject]()
    }

    func loadPersistedScenes(ofProject project: PersistedProject) -> [PersistedScene] {
        return []
    }

    func loadPersistedShots(ofScene scene: PersistedScene) -> [PersistedShot] {
        return []
    }

    func loadPersistedLayers(ofShot shot: PersistedShot) -> [PersistedLayer] {
        return []
    }



}
