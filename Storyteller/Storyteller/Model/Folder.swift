//
//  Folder.swift
//  Storyteller
//
//  Created by TFang on 20/3/21.
//
import PencilKit

class Folder: Directory {
    var description: String
    var name: String
    let id: UUID
    var dateAdded: Date
    var dateUpdated: Date

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

    private func retrieveDirectoriesFromStorage() -> [Directory] {
        let loader = PersistedModelLoader()
        let persistedModelTree = loader.loadPersistedModels()
        let rootIds = loader.getRootIds()
        let persistedDirectories = loader.loadPersistedDirectories()
        let projects = ModelFactory().loadProjectModel(from: persistedModelTree)
        let directories = ModelFactory().loadDirectoryModel(from: persistedDirectories,
                                                            withRootIds: rootIds,
                                                            withProjects: projects)

        return directories
    }

    init(name: String,
         description: String,
         id: UUID = UUID(),
         dateAdded: Date = Date(),
         dateUpdated: Date = Date(),
         children: [Directory] = [],
         parent: Folder? = nil) {

        self.description = description
        self.id = id
        self.name = name
        self.dateAdded = dateAdded
        self.dateUpdated = dateUpdated
        self.children = children
        self.parent = parent
        self.children = (parent == nil)
            ? self.retrieveDirectoriesFromStorage()
            : children
    }

    func setParent(to parent: Folder) {
        self.parent = parent
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
        } else if let folder = directory as? Folder {
            folder.setParent(to: self)
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

    func observedBy(_ observer: FolderObserver) {
        observers.append(observer)
    }

    private func notifyObservers() {
        observers.forEach({ $0.modelDidChange() })
    }

    func addDirectories(_ directories: [Directory]) {
        self.children.append(contentsOf: directories)
        directories.forEach { saveDirectory($0) }
        self.saveDirectory(self)
    }

    func moveChildren(indices selectedIndices: [Int], to folder: Folder) {
        let sortedIndices = selectedIndices.sorted(by: { $1 < $0 })
        let movedChildren: [Directory] = sortedIndices.compactMap {
            children.indices.contains($0) ? children[$0] : nil
        }
        movedChildren.forEach {
            ($0 as? Folder)?.setParent(to: folder)
        }
        folder.addDirectories(movedChildren)
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
