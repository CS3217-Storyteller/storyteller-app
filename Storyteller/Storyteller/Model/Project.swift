//
//  Project.swift
//  Storyteller
//
//  Created by Marcus on 21/3/21.
//
import PencilKit

class Project {
    var title: String
    let canvasSize: CGSize
    let id: UUID
    private var persistenceManager: ProjectPersistenceManager?
    private var observers = [ProjectObserver]()

    func observedBy(_ observer: ProjectObserver) {
        observers.append(observer)
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
                                            .getScenePersistenceManager(of: PersistedScene(scene)))
        }
        return scene
    }

    init(title: String, canvasSize: CGSize, scenes: [Scene] = [], id: UUID = UUID(), persistenceManager: ProjectPersistenceManager? = nil) {
        self.title = title
        self.canvasSize = canvasSize
        self.scenes = scenes
        self.id = id
        self.persistenceManager = persistenceManager
    }

    func setPersistenceManager(to persistenceManager: ProjectPersistenceManager) {
        if self.persistenceManager != nil {
            print("PERSISTENCE MANAGER IS NOT NIL")
            return
        }
        self.persistenceManager = persistenceManager
    }

    func saveScene(_ scene: Scene) {
        self.persistenceManager?.saveScene(PersistedScene(scene))
            ?? print("NO PROJECT PERSISTENCE MANAGER")
        self.saveProject()
        // TODO: inform observers
    }

    func deleteScene(_ scene: Scene) {
        self.persistenceManager?.deleteScene(PersistedScene(scene))
            ?? print("NO PROJECT PERSISTENCE MANAGER")
        self.saveProject()
        // TODO: inform observers
    }

    func saveProject() {
        self.persistenceManager?.saveProject(PersistedProject(self))
            ?? print("NO PROJECT PERSISTENCE MANAGER")
        // TODO: inform observers?
    }

    func addScene(_ scene: Scene) {
        if let persistenceManager = persistenceManager {
            scene.setPersistenceManager(to: persistenceManager
                                        .getScenePersistenceManager(of: PersistedScene(scene)))
        }
        self.scenes.append(scene)
        self.saveScene(scene)
    }

    func deleteScene(at index: Int) {
        print(scenes.count)
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
