//
//  ModelManager.swift
//  Storyteller
//
//  Created by TFang on 20/3/21.
//
import PencilKit

class ModelManager {
    var projects: [Project]
    private let storageManager = StorageManager()

    var observers = [ModelManagerObserver]()

    init() {
        self.projects = storageManager.getAllProjects()
    }

    func getBackgroundColor(of shotLabel: ShotLabel) -> UIColor? {
        getShot(of: shotLabel)?.backgroundColor.uiColor
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

    func getLayer(at layerIndex: Int, of shotLabel: ShotLabel) -> Layer? {
        guard let layers = getLayers(of: shotLabel),
              layers.indices.contains(layerIndex) else {
            return nil
        }
        return layers[layerIndex]
    }

    func getCanvasSize(of shotLabel: ShotLabel) -> CGSize {
        let projectIndex = shotLabel.projectIndex
        return projects[projectIndex].canvasSize
    }

    private func saveProject(_ project: Project) {
        storageManager.saveProject(project: project)
        observers.forEach({ $0.modelDidChanged() })
    }

    // TODO: remove all updateDrawing since we are using update(layer) now
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
        let label = ProjectLabel(projectIndex: index)
        let project = Project(scenes: scenes,
                              label: label,
                              canvasSize: canvasSize,
                              title: title
        )
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
                 layers: [Layer] = [],
                 backgroundColor: UIColor = .white) {
        guard let scene = getScene(of: shotLabel.sceneLabel) else {
            return
        }
        var layersInNewShot = layers
        if layers.isEmpty {
            layersInNewShot = [Layer(layerWithDrawing: PKDrawing(),
                                     canvasSize: scene.canvasSize)]
        }

        let projectIndex = shotLabel.projectIndex
        let sceneLabel = shotLabel.sceneLabel
        let shot = Shot(layers: layersInNewShot,
                        label: shotLabel,
                        backgroundColor: Color(uiColor: backgroundColor),
                        canvasSize: scene.canvasSize)
        projects[projectIndex].addShot(shot, to: sceneLabel)
        saveProject(projects[projectIndex])
    }

    // MARK: - Layers CRUD

    // TODO: allow different types of layers to be created
    func addLayer(at index: Int? = nil, to shotLabel: ShotLabel,
                  withDrawing drawing: PKDrawing = PKDrawing()) {
        let projectIndex = shotLabel.projectIndex
        guard let shot = getShot(of: shotLabel) else {
            return
        }
        let layer = Layer(layerWithDrawing: drawing, canvasSize: shot.canvasSize)
        projects[projectIndex].addLayer(layer, at: index, to: shotLabel)
        saveProject(projects[projectIndex])
    }

    func update(layer: Layer, at layerIndex: Int, of shotLabel: ShotLabel) {
        let projectIndex = shotLabel.projectIndex
        guard projects.indices.contains(projectIndex) else {
            return
        }
        projects[projectIndex].update(layer: layer, at: layerIndex, ofShot: shotLabel)

        saveProject(projects[projectIndex])
    }

    func removeLayers(at layerIndices: [Int], of shotLabel: ShotLabel) {
        let projectIndex = shotLabel.projectIndex
        guard projects.indices.contains(projectIndex) else {
            return
        }
        projects[projectIndex].removeLayers(at: layerIndices, of: shotLabel)

        saveProject(projects[projectIndex])
    }
    func moveLayer(from oldIndex: Int, to newIndex: Int, of shotLabel: ShotLabel) {
        let projectIndex = shotLabel.projectIndex
        guard projects.indices.contains(projectIndex) else {
            return
        }
        projects[projectIndex].moveLayer(from: oldIndex, to: newIndex, of: shotLabel)

        saveProject(projects[projectIndex])
    }
}

protocol ModelManagerObserver {
    /// Invoked when the model changes.
    func modelDidChanged()
}
