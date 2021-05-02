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
    let id: UUID // TODO: Proper init
    var dateAdded: Date = Date() // TODO: Proper date init
    var dateUpdated: Date = Date() // TODO: Proper date init

    private let persistenceManager = MainPersistenceManager()
    var observers = [FolderObserver]()

    var parent: Folder?

    var children: [Directory]

    var projects: [Project] {
        children.compactMap { $0 as? Project }
    }

    var persisted: PersistedFolder {
        PersistedFolder(self)
    }

    init(name: String, description: String, id: UUID = UUID(), dateAdded: Date = Date(), dateUpdated: Date = Date()) {
        let persistedModelTree = PersistedModelLoader().loadPersistedModels()
        self.children = ModelFactory().loadProjectModel(from: persistedModelTree)
        self.description = description
        self.id = id
        self.name = name
        self.dateAdded = dateAdded
        self.dateUpdated = dateUpdated
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

    private func saveDirectory(_ directory: Directory) {
        if let folder = directory as? Folder {
            self.persistenceManager.saveFolder(folder.persisted)
        } else if let project = directory as? Project {
            self.persistenceManager.saveProject(project.persisted)
        }
        self.persistenceManager.saveFolder(self.persisted)
        self.notifyObservers()
    }

    private func deleteDirectory(_ directory: Directory) {
        if let folder = directory as? Folder {
            self.persistenceManager.deleteFolder(folder.persisted)
        } else if let project = directory as? Project {
            self.persistenceManager.deleteProject(project.persisted)
        }
        self.persistenceManager.saveFolder(self.persisted)
        self.notifyObservers()
    }

    func addDirectory(_ directory: Directory) {
        if let project = directory as? Project {
            project
                .setPersistenceManager(to: self.persistenceManager.getProjectPersistenceManager(of: project.persisted))
        }
        self.children.append(directory)
        self.saveDirectory(directory)
    }

    func loadDirectory(at index: Int) -> Directory? {
        guard self.children.indices.contains(index) else {
            return nil
        }
        return self.children[index]
    }

    func removeDirectory(_ directory: Directory) {
        self.children = self.children.filter {
            $0 as? Project !== directory as? Project &&
            $0 as? Folder !== directory as? Folder
        }
        self.deleteDirectory(directory)
    }

    func renameDirectory(_ directory: Directory, to name: String) {
        if var folder = directory as? Folder {
            folder.rename(to: name)
        } else if var project = directory as? Project {
            project.rename(to: name)
        }
        saveDirectory(directory)
    }

    func updateDescription(_ directory: Directory, to description: String) {
        if var folder = directory as? Folder {
            folder.updateDescription(to: description)
        } else if var project = directory as? Project {
            project.updateDescription(to: description)
        }
        saveDirectory(directory)
    }
/*
    // remove
    func addProject(_ project: Project) {
        project.setPersistenceManager(to: self.persistenceManager.getProjectPersistenceManager(of: project.persisted))
        self.children.append(project)
        self.saveProject(project)
    }

    // remove
    func removeProject(_ project: Project) {
        if let index = self.projects.firstIndex(where: { $0 === project }) {
            self.children.remove(at: index)
            self.deleteProject(project)
        }
    }

    // remove
    func renameProject(_ project: Project, to name: String) {
        self.removeProject(project)
        project.name = name
        // project.setTitle(to: name)
        self.addProject(project)
    }

    // remove
    private func saveProject(_ project: Project?) {
        guard let project = project else {
            return
        }
        self.persistenceManager.saveProject(project.persisted)
        notifyObservers()
    }

    // remove
    func deleteProject(_ project: Project) {
        self.persistenceManager.deleteProject(project.persisted)
        notifyObservers()
    }
*/

    func observedBy(_ observer: FolderObserver) {
        observers.append(observer)
    }

    private func notifyObservers() {
        observers.forEach({ $0.modelDidChange() })
    }

    func addChildren(_ newChildren: [Directory]) {
        self.children.append(contentsOf: newChildren)
        newChildren.forEach { saveDirectory($0) }
        self.saveDirectory(self)
    }

    func moveChildren(indices selectedIndices: [Int], to folder: Folder) {
        let sortedIndices = selectedIndices.sorted(by: { $1 < $0 })
        let movedChildren: [Directory] = sortedIndices.compactMap {
            children.indices.contains($0) ? children[$0] : nil
        }
        folder.addChildren(movedChildren)
        sortedIndices.forEach { self.children.remove(at: $0) }
        self.saveDirectory(folder)
        self.saveDirectory(self)
    }

    func deleteChildren(at selectedIndices: [Int]) {
        let sortedIndices = selectedIndices.sorted(by: { $1 < $0 })
        sortedIndices.forEach { self.children.remove(at: $0) }
        self.saveDirectory(self)
    }
}
