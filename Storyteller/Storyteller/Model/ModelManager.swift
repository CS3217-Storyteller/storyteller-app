//
//  ModelManager.swift
//  Storyteller
//
//  Created by TFang on 20/3/21.
//
import PencilKit

// TODO: Rename ModelManager to ProjectManager?
class ModelManager {

    private let thumbnailQueue = DispatchQueue(label: "ThumbnailQueue", qos: .background)
    private let storageQueue = DispatchQueue(label: "StorageQueue", qos: .background)

    private let storageManager = StorageManager()
    var observers = [ModelManagerObserver]()

    var projects: [Project]

    init() {
        var list = [Project]()
        for project in storageManager.getAllProjects() {
            list.append(project)
        }
        self.projects = list
    }

    func addProject(_ project: Project) {
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
    }

    func deleteProject(_ project: Project) {
        self.storageManager.deleteProject(projectTitle: project.title)
        self.observers.forEach({ $0.modelDidChange() })
    }

    var onGoingThumbnailTask: (shot: Shot, workItem: DispatchWorkItem)?
}

// MARK: - Specific Shot Methods
extension ModelManager {

    func generateThumbnailAndSave(project: Project, shot: Shot) {
        saveProject(project)
        let workItem = DispatchWorkItem {
            shot.generateThumbnails()
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                self.saveProject(project)
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

/*protocol ModelObserver {
    /// Invoked when the model changes.
    func modelDidChange()
}/*    func DidUpdateLayer()
    func DidAddLayer(layer: Layer)
}

extension ModelObserver {
    func DidUpdateLayer() { }
    func DidAddLayer(layer: Layer) { }
}*/*/
