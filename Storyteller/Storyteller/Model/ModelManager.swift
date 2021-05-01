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

    private let thumbnailQueue = DispatchQueue(label: "ThumbnailQueue", qos: .background)
    private let storageQueue = DispatchQueue(label: "StorageQueue", qos: .background)

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

    var onGoingSaveTask: (project: Project, workItem: DispatchWorkItem)?

    func saveProject(_ project: Project?) {
        guard let project = project else {
            return
        }
        let persistedProject = PersistedProject(project)
        self.persistenceManager.saveProject(persistedProject)
        self.observers.forEach({ $0.modelDidChange() })
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
        self.observers.forEach({ $0.modelDidChange() })
    }

    var onGoingThumbnailTask: (shot: Shot, workItem: DispatchWorkItem)?
}

// MARK: - Specific Shot Methods
extension ModelManager {

    // TODO: should generate and save in SHOT class
    func generateThumbnailAndSave(project: Project, shot: Shot) {
        shot.saveShot()
        // self.saveProject(project)
        let workItem = DispatchWorkItem {
            shot.generateThumbnails()
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                shot.saveShot()
                // self.saveProject(project)
                self.onGoingThumbnailTask = nil
            }
        }
        if let task = self.onGoingThumbnailTask, task.shot === shot {
            task.workItem.cancel()
            self.onGoingThumbnailTask = (shot, workItem)
        }
        self.thumbnailQueue.async(execute: workItem)
    }
}

protocol ModelManagerObserver {
    /// Invoked when the model changes.
    func modelDidChange()
    // func DidUpdateLayer()
    // func DidAddLayer(layer: Layer)
}

extension ModelManagerObserver {
    // func DidUpdateLayer() { }
    // func DidAddLayer(layer: Layer) { }
}
