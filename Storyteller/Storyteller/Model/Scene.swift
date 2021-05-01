//
//  Scene.swift
//  Storyteller
//
//  Created by Marcus on 21/3/21.
//
import PencilKit

class Scene {
    let canvasSize: CGSize
    var shots: [Shot] = [Shot]()
    let id: UUID
    private var persistenceManager: ScenePersistenceManager?

    init(canvasSize: CGSize, shots: [Shot] = [], id: UUID = UUID()) {
        self.canvasSize = canvasSize
        self.shots = shots
        self.id = id
    }

    func loadShot(at index: Int) -> Shot? {
        guard shots.indices.contains(index) else {
            return nil
        }
        let shot = shots[index]
        if let persistenceManager = persistenceManager {
            shot.setPersistenceManager(to: persistenceManager
                                            .getShotPersistenceManager(of: PersistedShot(shot)))
        }
        return shot
    }

    func setPersistenceManager(to persistenceManager: ScenePersistenceManager) {
        if self.persistenceManager != nil {
            print("PERSISTENCE MANAGER IS NOT NIL")
            return
        }
        self.persistenceManager = persistenceManager
    }

    func saveScene() {
        self.persistenceManager?.saveScene(PersistedScene(self))
    }

    func saveShot(_ shot: Shot) {
        self.persistenceManager?.saveShot(PersistedShot(shot))
        saveScene()
    }

    func deleteShot(_ shot: Shot) {
        self.persistenceManager?.deleteShot(PersistedShot(shot))
        saveScene()
    }

    func swapShots(_ index1: Int, _ index2: Int) {
        self.shots.swapAt(index1, index2)
        saveScene()
    }

    func addShot(_ shot: Shot, at index: Int? = nil) {
        self.shots.insert(shot, at: index ?? shots.endIndex)
        saveShot(shot)
        if let persistenceManager = persistenceManager {
            print("YESSSSSS")
            shot.setPersistenceManager(to: persistenceManager
                                        .getShotPersistenceManager(of: PersistedShot(shot)))
        }
        if shot.layers.isEmpty {
            print("Adding new layer")
            let layer = Layer(withDrawing: PKDrawing(), canvasSize: shot.canvasSize)
            shot.addLayer(layer)
        }
    }

    func removeShot(_ shot: Shot) {
        self.shots.removeAll(where: { $0 === shot })
        saveScene()
    }

    func moveShot(shot: Shot, to newIndex: Int) {
        removeShot(shot)
        addShot(shot, at: newIndex)
    }

    func duplicate() -> Scene {
        Scene(
            canvasSize: canvasSize,
            shots: shots.map({ $0.duplicate() })
        )
    }

    func getShot(_ index: Int, after shot: Shot) -> Shot? {
        guard let currentIndex = self.shots.firstIndex(where: { $0 === shot }),
              self.shots.indices.contains(currentIndex + index) else {
            return nil
        }
        return loadShot(at: currentIndex + index)
    }
}
