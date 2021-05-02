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

    var children: [Directory]

    var projects: [Project] {
        children.compactMap { $0 as? Project }
    }

    init() {
        let persistedModelTree = PersistedModelLoader().loadPersistedModels()
        self.children = ModelFactory().loadProjectModel(from: persistedModelTree)
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

    // addDirectory
    // loadDirectory
    // removeDirectory
    // renameDirectory
    // private saveDirectory
    // private deleteDirectory

    func addDirectory(_ directory: Directory) {
        print("not impl")
    }

    func loadDirectory(_ directory: Directory) {
        print("not impl")
    }

    func removeDirectory(_ directory: Directory) {
        print("not impl")
    }

    func renameDirectory(_ directory: Directory) {
        print("not impl")
    }


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
        project.setTitle(to: name)
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

    func observedBy(_ observer: FolderObserver) {
        observers.append(observer)
    }

    private func notifyObservers() {
        observers.forEach({ $0.modelDidChange() })
    }

    func addChildren(_ newChildren: [Directory]) {
        self.children.append(contentsOf: newChildren)
        // persist
    }

    func moveChildren(indices selectedIndices: [Int], to folder: Folder) {
        let sortedIndices = selectedIndices.sorted(by: { $1 < $0 })
        let movedChildren: [Directory] = sortedIndices.compactMap {
            children.indices.contains($0) ? children[$0] : nil
        }
        folder.addChildren(movedChildren)
        sortedIndices.forEach { self.children.remove(at: $0) }
        // persist
        notifyObservers()
    }

    func deleteChildren(at selectedIndices: [Int]) {
        let sortedIndices = selectedIndices.sorted(by: { $1 < $0 })
        sortedIndices.forEach { self.children.remove(at: $0) }
        // persist
        notifyObservers()
    }
}
