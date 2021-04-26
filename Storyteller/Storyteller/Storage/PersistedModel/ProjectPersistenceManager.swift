//
//  ProjectPersistenceManager.swift
//  Storyteller
//
//  Created by mmarcus on 25/4/21.
//

import Foundation

struct ProjectPersistenceManager: Identifiable {
    var project: Project
    var storageManager: StorageManager
    var id: UUID {
        project.id
    }
}

// MARK: - ProjectObserver
extension ProjectPersistenceManager: ProjectObserver {
    func modelDidChange() {
        storageManager.save(project: project)
        print("ProjectPersistenceManager: Project changed!")
    }
}
