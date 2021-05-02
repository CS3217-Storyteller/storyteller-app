//
//  Folder.swift
//  Storyteller
//
//  Created by TFang on 20/3/21.
//
import PencilKit

class Folder: Directory {
    var description: String = "DESCRIPTION" // Todo: Proper Init
    var name: String = "FOLDER UNNAMED" // Todo: Proper Init
    let id: UUID = UUID() // TODO: Proper init
    var dateAdded: Date = Date() // TODO: Proper date init
    var dateUpdated: Date = Date() // TODO: Proper date init

    private let persistenceManager = MainPersistenceManager()
    var observers = [FolderObserver]()

    var parent: Folder?

    var directories: [Directory]

    var projects: [Project] {
        directories.compactMap { $0 as? Project }
    }

    init() {
        let persistedModelTree = PersistedModelLoader().loadPersistedModels()
        self.directories = ModelFactory().loadProjectModel(from: persistedModelTree)
    }

    func loadProject(at index: Int) -> Project? {
        guard projects.indices.contains(index) else {
            return nil
        }
        let project = projects[index]
        project.setPersistenceManager(to: persistenceManager
                                        .getProjectPersistenceManager(of: project.persisted))
        return project
    }

    func addProject(_ project: Project) {
        project.setPersistenceManager(to: self.persistenceManager.getProjectPersistenceManager(of: project.persisted))
        self.directories.append(project)
        self.saveProject(project)
    }

    func removeProject(_ project: Project) {
        if let index = self.projects.firstIndex(where: { $0 === project }) {
            self.directories.remove(at: index)
            self.deleteProject(project)
        }
    }

    func renameProject(_ project: Project, to name: String) {
        self.removeProject(project)
        project.setTitle(to: name)
        self.addProject(project)
    }

    func saveProject(_ project: Project?) {
        guard let project = project else {
            return
        }
        self.persistenceManager.saveProject(project.persisted)
        notifyObservers()
    }

    func deleteProject(_ project: Project) {
        self.persistenceManager.deleteProject(project.persisted)
        notifyObservers()
    }

    func observedBy(_ observer: FolderObserver) {
        observers.append(observer)
    }

    func notifyObservers() {
        observers.forEach({ $0.modelDidChange() })
    }
}
