//
//  MainPersistenceManager.swift
//  Storyteller
//
//  Created by mmarcus on 29/4/21.
//

import Foundation

class MainPersistenceManager {
    private let manager: PersistenceManager

    var url: URL {
        manager.url
    }

    init() {
        self.manager = PersistenceManager()
    }

    func saveProject(_ project: PersistedProject) {
        guard let data = manager.encodeToJSON(project) else {
            return
        }
        let folderName = project.id.uuidString
        manager.createFolder(named: folderName)
        manager.saveData(data, toFile: "Project Metadata", atFolder: folderName)
    }

    func deleteProject(_ project: PersistedProject) {
        let folderName = project.id.uuidString
        manager.deleteFolder(named: folderName)
    }

    func loadPersistedProject(id: UUID) -> PersistedProject? {
        let folderName = id.uuidString
        guard let data = manager.loadData("Project Metadata", atFolder: folderName) else {
            return nil
        }
        return try? JSONDecoder().decode(PersistedProject.self, from: data)
    }

    func getProjectPersistenceManager(of project: PersistedProject) -> ProjectPersistenceManager {
        let folderName = project.id.uuidString
        return ProjectPersistenceManager(at: url.appendingPathComponent(folderName))
    }
}
