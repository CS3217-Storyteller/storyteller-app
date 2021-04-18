//
//  ModelManager.swift
//  Storyteller
//
//  Created by TFang on 20/3/21.
//
import PencilKit

class ModelManager {
    private let thumbnailQueue = DispatchQueue(label: "ThumbnailQueue", qos: .background)
    private let storageQueue = DispatchQueue(label: "StorageQueue", qos: .background)

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

    func getShot(_ index: Int, after shotLabel: ShotLabel) -> Shot? {
        guard let scene = getScene(of: shotLabel.sceneLabel),
              let currentIndex = scene.shotOrder.firstIndex(of: shotLabel.shotId),
              scene.shotOrder.indices.contains(currentIndex + index) else {
            return nil
        }
        let shotId = scene.shotOrder[currentIndex + index]
        guard let shot = scene.shots[shotId] else {
            return nil
        }
        return shot
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

    var onGoingSaveTask: (project: Project, workItem: DispatchWorkItem)?
    private func saveProject(_ project: Project?) {
        self.observers.forEach({ $0.modelDidChange() })

        guard let project = project else {
            return
        }
        let workItem = DispatchWorkItem { [weak self] in
            self?.storageManager.saveProject(project: project)
        }
        if let task = onGoingSaveTask, task.project.title == project.title {
            task.workItem.cancel()
            onGoingSaveTask = (project, workItem)
        }
        storageQueue.async(execute: workItem)
    }

    private func deleteProject(_ project: Project) {
        self.storageManager.deleteProject(projectTitle: project.title)
        self.observers.forEach({ $0.modelDidChange() })
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
                 backgroundColor: UIColor = .clear) {
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
            let layer = Layer(withDrawing: PKDrawing(), canvasSize: scene.canvasSize, label: layerLabel)
            newShot.addLayer(layer)
        }

        projects[projectId]?.addShot(newShot, to: sceneLabel)
        saveProject(projects[projectId])
    }

    func moveShot(_ shotLabel: ShotLabel, to newIndex: Int) {
        let projectId = shotLabel.projectId
        projects[projectId]?.moveShot(shotLabel, to: newIndex)
        saveProject(projects[projectId])
    }

    func moveShot(_ shotLabel: ShotLabel, to newIndex: Int? = nil, atScene sceneLabel: SceneLabel) {
        let projectId = sceneLabel.projectId
        guard var shot = getShot(of: shotLabel)?.duplicate() else {
            return
        }
        let label = sceneLabel.generateShotLabel(withId: UUID())
        shot.label = label
        projects[projectId]?.addShot(shot, to: sceneLabel)
        if let index = newIndex {
            moveShot(label, to: index)
        }
        saveProject(getProject(of: sceneLabel.projectLabel))
    }
    var onGoingThumbnailTask: (shot: ShotLabel, workItem: DispatchWorkItem)?
}

// MARK: - Specific Shot Methods
extension ModelManager {
    func getBackgroundColor(of shotLabel: ShotLabel) -> UIColor? {
        self.getShot(of: shotLabel)?.backgroundColor.uiColor
    }
    func setBackgroundColor(of shotLabel: ShotLabel, using uiColor: UIColor) {
        // TODO
        generateThumbnailAndSave(shotLabel: shotLabel)
    }

    private func generateThumbnailAndSave(shotLabel: ShotLabel) {
        let projectId = shotLabel.projectId
        saveProject(projects[projectId])
        guard var shot = getShot(of: shotLabel) else {
            return
        }
        let workItem = DispatchWorkItem {
            shot.generateThumbnails()
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                // TODO: Change to update thumbnail only
                self.projects[projectId]?.updateShot(shotLabel, withShot: shot)
                self.saveProject(self.projects[projectId])
                self.onGoingThumbnailTask = nil
            }
        }
        if let task = onGoingThumbnailTask, task.shot.shotId == shotLabel.shotId {
            task.workItem.cancel()
            onGoingThumbnailTask = (shotLabel, workItem)
        }
        thumbnailQueue.async(execute: workItem)
    }

    // MARK: - Layers CRUD
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
        let layer = Layer(withDrawing: drawing,
                          canvasSize: shot.canvasSize,
                          label: label)
        projects[projectId]?.addLayer(layer, at: index, to: shotLabel)
        observers.forEach({ $0.DidAddLayer(layer: layer) })
        generateThumbnailAndSave(shotLabel: shotLabel)
    }
    func addLayer(at index: Int? = nil, to shotLabel: ShotLabel,
                  withImage image: UIImage) {
        let projectId = shotLabel.projectId
        guard let shot = getShot(of: shotLabel) else {
            return
        }
        let newId = UUID()
        let sceneId = shotLabel.sceneId
        let shotId = shotLabel.shotId
        let label = LayerLabel(projectId: projectId, sceneId: sceneId, shotId: shotId, layerId: newId)
        let layer = Layer(withImage: image,
                          canvasSize: shot.canvasSize,
                          label: label)
        projects[projectId]?.addLayer(layer, at: index, to: shotLabel)
        observers.forEach({ $0.DidAddLayer(layer: layer) })
        generateThumbnailAndSave(shotLabel: shotLabel)
    }
    func updateLayer(layerLabel: LayerLabel, withLayer newLayer: Layer) {
        let projectId = layerLabel.projectId
        projects[projectId]?.updateLayer(layerLabel, withLayer: newLayer)
        observers.forEach({ $0.DidUpdateLayer() })
        generateThumbnailAndSave(shotLabel: layerLabel.shotLabel)
    }
    func removeLayers(withIds ids: [UUID], of shotLabel: ShotLabel) {
        let projectId = shotLabel.projectId
        projects[projectId]?.removeLayers(withIds: Set(ids), of: shotLabel)
        generateThumbnailAndSave(shotLabel: shotLabel)
    }
    func duplicateLayers(withIds ids: [UUID], of shotLabel: ShotLabel) {
//        let projectId = shotLabel.projectId
        // TODO: Duplicate Layers: duplicate selected layers, and put each copy right after the duplicated layer
        generateThumbnailAndSave(shotLabel: shotLabel)
    }
    func groupLayers(withIds ids: [UUID], of shotLabel: ShotLabel) {
//        let projectId = shotLabel.projectId
        // TODO: Group Layers: create a composite component using selected layers
        // and put the grouped layer at the position of the toppest layer selected
        // Note that selected layers's visibility and lock should be reset before grouping
        generateThumbnailAndSave(shotLabel: shotLabel)
    }
    func ungroupLayer(withId id: UUID, of shotLabel: ShotLabel) {
//        let projectId = shotLabel.projectId
        // TODO: Ungroup Layers: get children of the composite component
        // and put them at the index of the the composite component
        generateThumbnailAndSave(shotLabel: shotLabel)
    }
    func renameLayer(withId id: UUID, of shotLabel: ShotLabel) {

    }
    // MARK: - Rearrange elements
    func moveLayer(_ layerLabel: LayerLabel, to newIndex: Int) {
        let projectId = layerLabel.projectId
        projects[projectId]?.moveLayer(layerLabel, to: newIndex)
        generateThumbnailAndSave(shotLabel: layerLabel.shotLabel)
    }
}
protocol ModelManagerObserver {
    /// Invoked when the model changes.
    func modelDidChange()
    func DidUpdateLayer()
    func DidAddLayer(layer: Layer)
}

extension ModelManagerObserver {
    func DidUpdateLayer() { }
    func DidAddLayer(layer: Layer) { }
}
