//
//  ModelManager.swift
//  Storyteller
//
//  Created by TFang on 20/3/21.
//
import PencilKit

// TODO: Each model class should have the right model manager, saving system, etc.
// TODO: Should PersistedProject be created here or created in persistencemanager?
class ModelManager {

    private let storageQueue = DispatchQueue(label: "StorageQueue", qos: .background)

    private let persistenceManager = MainPersistenceManager()
    var observers = [ModelManagerObserver]()

    var projects: [Project]

    init() {
        let persistedModelTree = PersistedModelLoader().loadPersistedModels()
        self.projects = ModelFactory().loadProjectModel(from: persistedModelTree)
        print(projects.map { $0.scenes.map { $0.shots.map { $0.layers.count }}})
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

    var onGoingSaveTask: (project: Project, workItem: DispatchWorkItem)?

    func saveProject(_ project: Project?) {
        guard let project = project else {
            return
        }
        let persistedProject = PersistedProject(project)
        self.persistenceManager.saveProject(persistedProject)
        notifyObservers()
        /*
        self.observers.forEach({ $0.modelDidChange() })

        guard let project = project else {
            return
        }
        let workItem = DispatchWorkItem { [weak self] in
            self?.storageManager.saveProject(project: project)
        }
        if let task = onGoingSaveTask, task.project.title == project.title {
            task.workItem.cancel()
            onGoingSaveTask = (project, workItem)
        }
        storageQueue.async(execute: workItem)
        */
    }

    func deleteProject(_ project: Project) {
        // self.storageManager.deleteProject(projectTitle: project.title)
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
