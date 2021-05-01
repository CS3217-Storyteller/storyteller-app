//
//  ModelFactory.swift
//  Storyteller
//
//  Created by mmarcus on 30/4/21.
//

import Foundation

class ModelFactory {
    typealias PersistedModelTree = [(PersistedProject,
                                    [(PersistedScene,
                                      [(PersistedShot,
                                        [PersistedLayer]
                                      )])])]

    private func generateProject(from persistedProject: PersistedProject, withScenes scenes: [Scene]) -> Project {
        let idToScene: [UUID: Scene] = Dictionary(scenes.map({ ($0.id, $0 )})) { $1 }
        return Project(title: persistedProject.title, canvasSize: persistedProject.canvasSize,
                       scenes: persistedProject.scenes.compactMap({ idToScene[$0] }),
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

    func loadProjectModel(from tree: PersistedModelTree) -> [Project] {
        tree.map {
            generateProject(from: $0, withScenes: $1.map {
                generateScene(from: $0, withShots: $1.map {
                    generateShot(from: $0, withLayers: generateLayers(from: $1))
                })
            })
        }
    }
}
