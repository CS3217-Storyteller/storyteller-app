//
//  ModelManager.swift
//  Storyteller
//
//  Created by TFang on 20/3/21.
//

import PencilKit

// TODO
class ModelManager {
    var projects: [Project]
    private let storageManager = StorageManager()

    init() {
        self.projects = storageManager.getAllProjects()
    }

    func getBackgroundColor(of shotLabel: ShotLabel) -> UIColor? {
        return getShot(of: shotLabel)?.backgroundColor.uiColor
    }

    func getProject(of projectLabel: ProjectLabel) -> Project? {
        let projectIndex = projectLabel.projectIndex
        guard projects.indices.contains(projectIndex) else {
            return nil
        }
        return projects[projectIndex]
    }

    func getScene(of sceneLabel: SceneLabel) -> Scene? {
        let projectLabel = sceneLabel.projectLabel
        guard let project = getProject(of: projectLabel) else {
            return nil
        }
        let scenes = project.scenes
        let sceneIndex = sceneLabel.sceneIndex
        guard scenes.indices.contains(sceneIndex) else {
            return nil
        }
        let scene = scenes[sceneIndex]
        return scene
    }

    func getShot(of shotLabel: ShotLabel) -> Shot? {
        let sceneLabel = shotLabel.sceneLabel
        guard let scene = getScene(of: sceneLabel) else {
            return nil
        }
        let shots = scene.shots
        let shotIndex = shotLabel.shotIndex
        guard shots.indices.contains(shotIndex) else {
            return nil
        }
        let shot = shots[shotIndex]
        return shot
    }

    func getLayers(of shotLabel: ShotLabel) -> [Layer]? {
        guard let shot = getShot(of: shotLabel) else {
            return nil
        }
        return shot.layers
    }

    func getCanvasSize(of shotLabel: ShotLabel) -> CGSize {
        let projectIndex = shotLabel.projectIndex
        return projects[projectIndex].canvasSize
    }

    private func saveProject(_ project: Project) {
        _ = storageManager.saveProject(project: project)
    }

    func updateDrawing(ofShot shotLabel: ShotLabel,
                       atLayer layer: Int,
                       withDrawing drawing: PKDrawing) {
        let projectIndex = shotLabel.projectIndex
        guard projects.indices.contains(projectIndex) else {
            return
        }
        projects[projectIndex].updateShot(ofShot: shotLabel,
                                          atLayer: layer,
                                          withDrawing: drawing)
        saveProject(projects[projectIndex])
    }

    func addProject(canvasSize: CGSize, title: String, scenes: [Scene] = [Scene]()) {
        let index = projects.count
        let label = ProjectLabel(title: title, projectIndex: index)
        let project = Project(scenes: scenes,
                              label: label,
                              canvasSize: canvasSize)
        projects.append(project)
        saveProject(project)
    }

    func addScene(projectLabel: ProjectLabel, shots: [Shot] = [Shot]()) {
        let projectIndex = projectLabel.projectIndex
        guard let project = getProject(of: projectLabel) else {
            return
        }
        let index = projects[projectIndex].scenes.count
        let label = SceneLabel(projectLabel: projectLabel, sceneIndex: index)
        let scene = Scene(shots: shots, label: label, canvasSize: project.canvasSize)
        projects[projectIndex].addScene(scene)
        saveProject(projects[projectIndex])
    }

    func addShot(ofShot shotLabel: ShotLabel,
                 layers: [Layer],
                 backgroundColor: UIColor) {
        guard let scene = getScene(of: shotLabel.sceneLabel) else {
            return
        }
        let projectIndex = shotLabel.projectIndex
        let sceneLabel = shotLabel.sceneLabel
        let shot = Shot(layers: layers,
                        label: shotLabel,
                        backgroundColor: Color(uiColor: backgroundColor),
                        canvasSize: scene.canvasSize)
        projects[projectIndex].addShot(shot, to: sceneLabel)
        saveProject(projects[projectIndex])
    }

    func addLayer(type: LayerType,
                  withDrawing drawing: PKDrawing = PKDrawing(),
                  to shotLabel: ShotLabel) {
        let projectIndex = shotLabel.projectIndex
        guard let shot = getShot(of: shotLabel) else {
            return
        }
        let layer = Layer(layerType: type, drawing: drawing, canvasSize: shot.canvasSize)
        projects[projectIndex].addLayer(layer, to: shotLabel)
        saveProject(projects[projectIndex])
    }
}
