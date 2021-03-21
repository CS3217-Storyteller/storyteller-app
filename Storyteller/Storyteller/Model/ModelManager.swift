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

    // TODO: Read from persistence?
    init() {
        self.projects = [Project]()
    }

    func getBackgroundColor(of shotLabel: ShotLabel) -> UIColor {
        return getShot(of: shotLabel).backgroundColor
    }

    func getProject(of projectLabel: ProjectLabel) -> Project {
        let projectIndex = projectLabel.projectIndex
        return projects[projectIndex]
    }

    func getScene(of sceneLabel: SceneLabel) -> Scene {
        let projectIndex = sceneLabel.projectIndex
        let sceneIndex = sceneLabel.sceneIndex
        let scene = projects[projectIndex].scenes[sceneIndex]
        return scene
    }

    func getShot(of shotLabel: ShotLabel) -> Shot {
        let projectIndex = shotLabel.projectIndex
        let sceneIndex = shotLabel.sceneIndex
        let shotIndex = shotLabel.shotIndex
        let scene = projects[projectIndex].scenes[sceneIndex]
        let shot = scene.shots[shotIndex]
        return shot
    }

    func getLayers(of shotLabel: ShotLabel) -> [Layer] {
        return getShot(of: shotLabel).layers
    }

    func getCanvasSize(of shotLabel: ShotLabel) -> CGSize {
        // return CGSize(width: Constants.screenWidth, height: Constants.screenHeight)
        let projectIndex = shotLabel.projectIndex
        return projects[projectIndex].canvasSize
    }

    // TODO: continuous update, write TO persistence also
    func updateDrawing(ofShot shotLabel: ShotLabel,
                       atLayer layer: Int,
                       withDrawing drawing: PKDrawing) {
        let projectIndex = shotLabel.projectIndex
        projects[projectIndex].updateShot(ofShot: shotLabel,
                                          atLayer: layer,
                                          withDrawing: drawing)
    }

    func addProject(canvasSize: CGSize, title: String, scenes: [Scene] = [Scene]()) {
        let index = projects.count
        let label = ProjectLabel(title: title, projectIndex: index)
        let project = Project(scenes: scenes,
                              label: label,
                              canvasSize: canvasSize)
        projects.append(project)
    }

    func addScene(projectLabel: ProjectLabel, shots: [Shot] = [Shot]()) {
        let projectIndex = projectLabel.projectIndex
        let index = projects[projectIndex].scenes.count
        let label = SceneLabel(projectLabel: projectLabel, sceneIndex: index)
        let scene = Scene(shots: shots, label: label)
        projects[projectIndex].addScene(scene)
    }

    func addShot(ofShot shotLabel: ShotLabel,
                 layers: [Layer],
                 backgroundColor: UIColor) {
        let projectIndex = shotLabel.projectIndex
        let sceneLabel = shotLabel.sceneLabel
        let shot = Shot(layers: layers, label: shotLabel, backgroundColor: backgroundColor)
        projects[projectIndex].addShot(shot, to: sceneLabel)
    }

    func addLayer(type: LayerType,
                  withDrawing drawing: PKDrawing = PKDrawing(),
                  to shotLabel: ShotLabel) {
        let projectIndex = shotLabel.projectIndex
        let layer = Layer(layerType: type, drawing: drawing)
        projects[projectIndex].addLayer(layer, to: shotLabel)
    }
}
