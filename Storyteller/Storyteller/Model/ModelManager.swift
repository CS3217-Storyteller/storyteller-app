//
//  ModelManager.swift
//  Storyteller
//
//  Created by TFang on 20/3/21.
//
import PencilKit

class ModelManager {

    private let persistenceManager = MainPersistenceManager()
    var observers = [ModelManagerObserver]()

    var projects: [Project]

    init() {
        let persistedModelTree = PersistedModelLoader().loadPersistedModels()
        self.projects = ModelFactory().loadProjectModel(from: persistedModelTree)
    }

    func loadProject(at index: Int) -> Project? {
        guard projects.indices.contains(index) else {
            return nil
        }
        let project = projects[index]
        project.setPersistenceManager(to: persistenceManager
                                        .getProjectPersistenceManager(of: PersistedProject(project)))
        return project
    }

    func addProject(_ project: Project) {
        let persistedProject = PersistedProject(project)
        project.setPersistenceManager(to: self.persistenceManager.getProjectPersistenceManager(of: persistedProject))
        self.projects.append(project)
        self.saveProject(project)
    }

    func removeProject(_ project: Project) {
        if let index = self.projects.firstIndex(where: { $0 === project }) {
            self.projects.remove(at: index)
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
        let persistedProject = PersistedProject(project)
        self.persistenceManager.saveProject(persistedProject)
        notifyObservers()
    }

    func deleteProject(_ project: Project) {
        let persistedProject = PersistedProject(project)
        self.persistenceManager.deleteProject(persistedProject)
        notifyObservers()
    }

    func observedBy(_ observer: ModelManagerObserver) {
        observers.append(observer)
    }

    func notifyObservers() {
        observers.forEach({ $0.modelDidChange() })
    }
}
