//
//  ModelManager.swift
//  Storyteller
//
//  Created by TFang on 20/3/21.
//
import PencilKit

class ModelManager {
    
    private let storageManager = StorageManager()
    var observers = [ModelManagerObserver]()
    
    var projects: [UUID: Project]
    var projectOrder: [UUID]
    
    var orderedProjects: [Project] {
        self.projectOrder.map { id in self.projects[id] }.compactMap { $0 }
    }
    
    init() {
        var dict = [UUID: Project]()
        var list = [UUID]()
        for project in storageManager.getAllProjects() {
            dict[project.id] = project
            list.append(project.id)
        }
        self.projects = dict
        self.projectOrder = list
    }

    func getProject(of projectLabel: ProjectLabel) -> Project? {
        let projectId = projectLabel.projectId
        return projects[projectId]
    }
    
    func addProject(canvasSize: CGSize, title: String, project: Project? = nil) {
        var newProject: Project
        let newProjectId = UUID()
        if let unwrappedProject = project {
            newProject = unwrappedProject.duplicate(withId: newProjectId)
        } else {
            let label = ProjectLabel(projectId: newProjectId)
            newProject = Project(
                id: newProjectId,
                label: label,
                title: title,
                canvasSize: canvasSize
            )
        }
        self.projects[newProjectId] = newProject
        self.projectOrder.append(newProjectId)
        self.saveProject(newProject)
    }
    
    func removeProject(of projectLabel: ProjectLabel) {
        let projectId = projectLabel.projectId
        if let project = projects[projectId] {
            self.deleteProject(project)
        }
        self.projects.removeValue(forKey: projectId)
        if let idx = self.projectOrder.firstIndex(of: projectId) {
            self.projectOrder.remove(at: idx)
        }
    }
    
    func renameProject(of projectLabel: ProjectLabel, to name: String) {
        let projectId = projectLabel.projectId
        guard var project = projects[projectId] else {
            return
        }
        self.removeProject(of: projectLabel)
        project.setTitle(to: name)
        self.addProject(canvasSize: project.canvasSize, title: project.title, project: project)
    }
    
    func getBackgroundColor(of shotLabel: ShotLabel) -> UIColor? {
        self.getShot(of: shotLabel)?.backgroundColor.uiColor
    }

    func getScene(of sceneLabel: SceneLabel) -> Scene? {
        let projectId = sceneLabel.projectId
        let sceneId = sceneLabel.sceneId
        return projects[projectId]?
            .scenes[sceneId]
    }

    func getShot(of shotLabel: ShotLabel) -> Shot? {
        let projectId = shotLabel.projectId
        let sceneId = shotLabel.sceneId
        let shotId = shotLabel.shotId
        return projects[projectId]?
            .scenes[sceneId]?
            .shots[shotId]
    }

    // TODO: Return optional, or empty array if shot is nil?
    func getLayers(of shotLabel: ShotLabel) -> [Layer]? {
        let layers = getShot(of: shotLabel)?.orderedLayers
        return layers
    }

    // old signature: func getLayer(at layerIndex: Int, of shotLabel: ShotLabel) -> Layer?
    func getLayer(label: LayerLabel) -> Layer? {
        let shotLabel = label.shotLabel
        let layerId = label.layerId
        let shot = getShot(of: shotLabel)
        return shot?.layers[layerId]
    }

    func getCanvasSize(of shotLabel: ShotLabel) -> CGSize? {
        let projectId = shotLabel.projectId
        return projects[projectId]?.canvasSize
    }

    private func saveProject(_ project: Project?) {
        if let project = project {
            self.storageManager.saveProject(project: project)
            self.observers.forEach({ $0.modelDidChange() })
        }
    }

    private func deleteProject(_ project: Project) {
        self.storageManager.deleteProject(projectTitle: project.title)
        self.observers.forEach({ $0.modelDidChange() })
    }

    @available(*, deprecated, message: "Deprecated. Use updateLayer function instead.")
    func updateDrawing(ofShot shotLabel: ShotLabel,
                       atLayer layer: Int,
                       withDrawing drawing: PKDrawing) {

        /* let projectIndex = shotLabel.projectIndex
        guard projects.indices.contains(projectIndex) else {
            return
        }
        projects[projectIndex].updateShot(ofShot: shotLabel,
                                          atLayer: layer,
                                          withDrawing: drawing)
        saveProject(projects[projectIndex]) */
    }

    // TODO: Use this method to update drawing
    func updateLayer(layerLabel: LayerLabel, withDrawing drawing: PKDrawing = PKDrawing()) {
        let projectId = layerLabel.projectId
        self.projects[projectId]?.updateLayer(layerLabel, withDrawing: drawing)
        self.saveProject(projects[projectId])
        self.observers.forEach({ $0.layerDidUpdate() })
    }

    // TODO: Use this method to update drawing
    func updateLayer(layerLabel: LayerLabel, withLayer newLayer: Layer) {
        let projectId = layerLabel.projectId
        self.projects[projectId]?.updateLayer(layerLabel, withLayer: newLayer)
        self.saveProject(projects[projectId])
        self.observers.forEach({ $0.layerDidUpdate() })
    }

    func addScene(projectLabel: ProjectLabel, scene: Scene? = nil) {
        let id = UUID()
        guard let project = getProject(of: projectLabel) else {
            print("RETURNED")
            return
        }
        let projectId = projectLabel.projectId
        var newScene: Scene
        if let unwrappedScene = scene {
            print("IF ADDSCENE")
            newScene = unwrappedScene.duplicate(withId: id)
        } else {
            print("ELSE ADDSCENE")
            let label = SceneLabel(projectId: projectId, sceneId: id)
            newScene = Scene(label: label, canvasSize: project.canvasSize, id: id)
        }
        print("project:", projects[projectId]?.title ?? "NIL")
        projects[projectId]?.addScene(newScene)
        saveProject(projects[projectId])
    }

    func addShot(ofShot shotLabel: ShotLabel,
                 shot: Shot? = nil,
                 backgroundColor: UIColor = .white) {
        let sceneLabel = shotLabel.sceneLabel
        guard let scene = getScene(of: sceneLabel) else {
            return
        }
        let id = UUID()
        let projectId = shotLabel.projectId
        let sceneId = shotLabel.sceneId
        var newShot: Shot
        if let unwrappedShot = shot {
            newShot = unwrappedShot.duplicate(withId: id)
        } else {
            let label = ShotLabel(projectId: projectId, sceneId: sceneId, shotId: id)
            newShot = Shot(id: id,
                           label: label,
                           backgroundColor: Color(uiColor: backgroundColor),
                           canvasSize: scene.canvasSize)
        }

        if newShot.layers.isEmpty {
            let layerLabel = newShot.label.generateLayerLabel(withId: id)
            let layer = Layer(layerWithDrawing: PKDrawing(), canvasSize: scene.canvasSize, label: layerLabel)
            newShot.addLayer(layer)
        }

        projects[projectId]?.addShot(newShot, to: sceneLabel)
        saveProject(projects[projectId])
    }

    // MARK: - Layers CRUD

    func removeLayers(withIds ids: [UUID], of shotLabel: ShotLabel) {
        let projectId = shotLabel.projectId
        projects[projectId]?.removeLayers(withIds: Set(ids), of: shotLabel)
    }

    // TODO: allow different types of layers to be created
    func addLayer(at index: Int? = nil, to shotLabel: ShotLabel,
                  withDrawing drawing: PKDrawing = PKDrawing()) {
        let projectId = shotLabel.projectId
        guard let shot = getShot(of: shotLabel) else {
            return
        }
        let newId = UUID()
        let sceneId = shotLabel.sceneId
        let shotId = shotLabel.shotId
        let label = LayerLabel(projectId: projectId, sceneId: sceneId, shotId: shotId, layerId: newId)
        let layer = Layer(layerWithDrawing: drawing,
                          canvasSize: shot.canvasSize,
                          name: "Give me a Name",
                          label: label)
        projects[projectId]?.addLayer(layer, at: index, to: shotLabel)
        observers.forEach({ $0.willAddLayer() })
        saveProject(projects[projectId])
    }

    func moveLayer(_ layerLabel: LayerLabel, to newIndex: Int) {
        let projectId = layerLabel.projectId
        projects[projectId]?.moveLayer(layerLabel, to: newIndex)
    }

    func moveShot(_ shotLabel: ShotLabel, to newIndex: Int) {
        let projectId = shotLabel.projectId
        projects[projectId]?.moveShot(shotLabel, to: newIndex)
        saveProject(projects[projectId])
    }

    func moveShot(_ shotLabel: ShotLabel, toScene sceneLabel: SceneLabel) {
        let projectId = sceneLabel.projectId
        let sceneId = sceneLabel.sceneId
        guard var shot = getShot(of: shotLabel)?.duplicate() else {
            return
        }
        let label = ShotLabel(projectId: projectId, sceneId: sceneId, shotId: UUID())
        shot.label = label
        projects[projectId]?.addShot(shot, to: sceneLabel)
        saveProject(getProject(of: sceneLabel.projectLabel))
    }
}


protocol ModelManagerObserver {
    /// Invoked when the model changes.
    func modelDidChange()
    func layerDidUpdate()
    func willAddLayer()
}

extension ModelManagerObserver {
    func layerDidUpdate() { }
    func willAddLayer() { }
}
