//
//  ModelFactory.swift
//  Storyteller
//
//  Created by mmarcus on 30/4/21.
//

import Foundation

class ModelFactory {
    private let rootPersistenceManager = MainPersistenceManager()
    typealias PersistedModelTree = [(PersistedProject,
                                    [(PersistedScene,
                                      [(PersistedShot,
                                        [PersistedLayer]
                                      )])])]

    private func generateProject(from persistedProject: PersistedProject, withScenes scenes: [Scene]) -> Project {
        let idToScene: [UUID: Scene] = Dictionary(scenes.map({ ($0.id, $0 )})) { $1 }
        let orderedScenes = persistedProject.scenes.compactMap({ idToScene[$0] })
        return Project(title: persistedProject.title,
                       canvasSize: persistedProject.canvasSize,
                       scenes: orderedScenes,
                       id: persistedProject.id
        )
    }

    private func generateScene(from persistedScene: PersistedScene, withShots shots: [Shot]) -> Scene {
        let idToShot: [UUID: Shot] = Dictionary(shots.map({ ($0.id, $0 )})) { $1 }
        return Scene(canvasSize: persistedScene.canvasSize,
                     shots: persistedScene.shots.compactMap({ idToShot[$0] }),
                     id: persistedScene.id
        )
    }

    private func generateShot(from persistedShot: PersistedShot, withLayers layers: [Layer]) -> Shot {
        let idToLayer: [UUID: Layer] = Dictionary(layers.map({ ($0.id, $0 )})) { $1 }
        return Shot(canvasSize: persistedShot.canvasSize,
                    backgroundColor: persistedShot.backgroundColor,
                    layers: persistedShot.layers.compactMap({ idToLayer[$0] }),
                    thumbnail: persistedShot.thumbnail,
                    id: persistedShot.id
        )
    }

    private func generateLayers(from persistedLayers: [PersistedLayer]) -> [Layer] {
        persistedLayers.map({ $0.layer })
    }

    private func initializePersistenceManagers(for projects: [Project]) {
        projects.forEach {
            let projectPersistenceManager = rootPersistenceManager
                .getProjectPersistenceManager(of: PersistedProject($0))
            $0.setPersistenceManager(to: projectPersistenceManager)
            $0.scenes.forEach {
                let scenePersistenceManager = projectPersistenceManager
                    .getScenePersistenceManager(of: PersistedScene($0))
                $0.setPersistenceManager(to: scenePersistenceManager)
                $0.shots.forEach {
                    let shotPersistenceManager = scenePersistenceManager
                        .getShotPersistenceManager(of: PersistedShot($0))
                    $0.setPersistenceManager(to: shotPersistenceManager)
                    $0.layers.forEach {
                        let layerPersistenceManager = shotPersistenceManager
                            .getLayerPersistenceManager(for: PersistedLayer($0))
                        $0.setPersistenceManager(to: layerPersistenceManager)
                    }
                }
            }
        }
    }

    func loadProjectModel(from tree: PersistedModelTree) -> [Project] {
        let projects = tree.map {
            generateProject(from: $0, withScenes: $1.map {
                generateScene(from: $0, withShots: $1.map {
                    generateShot(from: $0, withLayers: generateLayers(from: $1))
                })
            })
        }
        initializePersistenceManagers(for: projects)
        return projects
    }
}
