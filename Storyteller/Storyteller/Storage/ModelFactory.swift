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

    /*
    func generateShots(from persistedShots: [PersistedShot], withLayers layers: [Layer]) -> [Shot] {
        let idToLayer: [UUID: Layer] = Dictionary(layers.map({ ($0.id, $0 )})) { $1 }
        return persistedShots.map({ Shot(canvasSize: $0.canvasSize,
                                         backgroundColor: $0.backgroundColor,
                                         layers: $0.layers.compactMap({ idToLayer[$0] }),
                                         thumbnail: $0.thumbnail,
                                         id: $0.id
        )})
    }

    func generateScenes(from persistedScenes: [PersistedScene], withShots shots: [Shot]) -> [Scene] {
        let idToShot: [UUID: Shot] = Dictionary(shots.map({ ($0.id, $0 )})) { $1 }
        return persistedScenes.map({ Scene(canvasSize: $0.canvasSize,
                                           shots: $0.shots.compactMap({ idToShot[$0] }),
                                           id: $0.id
        )})
    }

    func generateProjects(from persistedProjects: [PersistedProject], withScenes scenes: [Scene]) -> [Project] {
        let idToScene: [UUID: Scene] = Dictionary(scenes.map({ ($0.id, $0 )})) { $1 }
        return persistedProjects.map({ Project(title: $0.title, canvasSize: $0.canvasSize,
                                               scenes: $0.scenes.compactMap({ idToScene[$0] }),
                                               id: $0.id
        )})
    }



    func loadProjectModel(persistedProject: PersistedProject, persistedScenes: [PersistedScene], persistedShots: [PersistedShot], persistedLayers: [PersistedLayer]) -> Project {
        let layers = generateLayers(from: persistedLayers)
        let shots = generateShots(from: persistedShots, withLayers: layers)
        let scenes = generateScenes(from: persistedScenes, withShots: shots)
        let project = generateProject(from: persistedProject, withScenes: scenes)

        return project
    }
     */

    /*
    func loadProjectModel(persistedProjects: [PersistedProject], persistedScenes: [PersistedScene], persistedShots: [PersistedShot], persistedLayers: [PersistedLayer]) -> [Project] {
        let layers = generateLayers(from: persistedLayers)
        let shots = generateShots(from: persistedShots, withLayers: layers)
        let scenes = generateScenes(from: persistedScenes, withShots: shots)
        let projects = generateProjects(from: persistedProjects, withScenes: scenes)

        return projects
    }
    */
}
