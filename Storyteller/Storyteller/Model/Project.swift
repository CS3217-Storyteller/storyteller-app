//
//  Project.swift
//  Storyteller
//
//  Created by Marcus on 21/3/21.
//
import PencilKit

class Project: Directory {
    var description: String = "DESCRIPTION" // Todo: Proper Init
    var name: String = "Project UNNAMED" // Todo: Proper Init
    let id: UUID = UUID() // TODO: Proper init
    var dateAdded: Date = Date() // TODO: Proper date init
    var dateUpdated: Date = Date() // TODO: Proper date init

    let canvasSize: CGSize

    private var persistenceManager: ProjectPersistenceManager?
    private var observers = [ProjectObserver]()

    func observedBy(_ observer: ProjectObserver) {
        observers.append(observer)
    }

    var persisted: PersistedProject {
        PersistedProject(self)
    }

    func notifyObservers() {
        observers.forEach({ $0.modelDidChange() })
    }

    var scenes: [Scene] = []

    func loadScene(at index: Int) -> Scene? {
        guard scenes.indices.contains(index) else {
            return nil
        }
        let scene = scenes[index]
        if let persistenceManager = persistenceManager {
            scene.setPersistenceManager(to: persistenceManager
                                            .getScenePersistenceManager(of: scene.persisted))
        }
        return scene
    }

    init(title: String, canvasSize: CGSize, scenes: [Scene] = [],
         id: UUID = UUID(),
         persistenceManager: ProjectPersistenceManager? = nil) {
        self.title = title
        self.canvasSize = canvasSize
        self.scenes = scenes
        self.id = id
        self.persistenceManager = persistenceManager
    }

    func setPersistenceManager(to persistenceManager: ProjectPersistenceManager) {
        if self.persistenceManager != nil {
            return
        }
        self.persistenceManager = persistenceManager
    }

    private func saveScene(_ scene: Scene) {
        self.persistenceManager?.saveScene(scene.persisted)
        self.saveProject()
    }

    private func deleteScene(_ scene: Scene) {
        self.persistenceManager?.deleteScene(scene.persisted)
        self.saveProject()
    }

    private func saveProject() {
        self.persistenceManager?.saveProject(self.persisted)
        self.notifyObservers()
    }

    func addScene(_ scene: Scene) {
        if let persistenceManager = persistenceManager {
            scene.setPersistenceManager(to: persistenceManager
                                        .getScenePersistenceManager(of: scene.persisted))
        }
        self.scenes.append(scene)
        self.saveScene(scene)
    }

    func deleteScene(at index: Int) {
        let removedScene = self.scenes.remove(at: index)
        self.deleteScene(removedScene)
    }

    func setTitle(to title: String) {
        self.title = title
        self.saveProject()
    }

    func duplicate() -> Project {
        Project(
            title: self.title,
            canvasSize: self.canvasSize,
            scenes: scenes.map({ $0.duplicate() })
        )
    }
}
