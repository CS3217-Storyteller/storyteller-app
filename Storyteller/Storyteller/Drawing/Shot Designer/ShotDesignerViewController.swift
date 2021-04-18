//
//  ShotDesignerController.swift
//  Storyteller
//
//  Created by TFang on 20/3/21.
//
import PencilKit

class ShotDesignerViewController: UIViewController {
    @IBOutlet private var shotView: ShotView! {
        didSet {
            shotView.clipsToBounds = true
            shotView.addInteraction(UIDropInteraction(delegate: self))
        }
    }

    @IBOutlet private var transformLayerButton: TransformLayerButton!
    @IBOutlet private var drawingModeButton: DrawingModeButton!

    var editingMode = EditingMode.free {
        didSet {
            switch editingMode {
            case .free:
                transformLayerButton.deselect()
                drawingModeButton.deselect()
                shotView.isInDrawingMode = false
            case .transformLayer:
                transformLayerButton.select()
                drawingModeButton.deselect()
                shotView.isInDrawingMode = false
            case .drawing:
                transformLayerButton.deselect()
                drawingModeButton.select()
                shotView.isInDrawingMode = true
            }
        }
    }
    var onionSkinRange = OnionSkinRange()
    var toolPicker = PKToolPicker()
    // should be intialized via segue
    var modelManager: ModelManager!
    var shot: Shot!
    var scene: Scene!
    var project: Project!

    var canvasTransform = CGAffineTransform.identity {
        didSet {
            self.updateShotTransform()
        }
    }

    var canvasSize: CGSize {
        self.shot.canvasSize
    }

    var selectedLayerIndex: Int {
        get {
            self.shotView.selectedLayerIndex
        }
        set {
            self.shotView.selectedLayerIndex = newValue
        }
    }

    var selectedLayer: Layer? {
        let layer = self.shot.layers[selectedLayerIndex]
        return layer
    }

    func setModelManager(to modelManager: ModelManager) {
        self.modelManager = modelManager
    }

    func setShot(to shot: Shot) {
        self.shot = shot
    }
    
    func setScene(to scene: Scene) {
        self.scene = scene
    }
    
    func setProject(to project: Project) {
        self.project = project
    }

    override var prefersStatusBarHidden: Bool {
        true
    }

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.toolPicker.addObserver(self)
        self.modelManager.observers.append(self)

        self.shotView.setSize(canvasSize: self.canvasSize)
        self.setUpShot()

        self.editingMode = .drawing
        self.navigationItem.leftItemsSupplementBackButton = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.updateShotTransform()
    }

    private func setUpShot() {
        self.shotView.backgroundColor = self.shot.backgroundColor.uiColor
        let layers = self.shot.layers
        
        if layers.isEmpty {
            return
        }

        let layerViews = layers.map({ DrawingUtility.generateLayerView(for: $0) })
        self.shotView.setUpLayerViews(layerViews, toolPicker: toolPicker, PKDelegate: self)
        self.updateOnionSkins()
        self.updateShotTransform()
    }
    
    private func updateOnionSkins() {
        guard self.modelManager != nil, self.shotView != nil else {
            return
        }
        let redOnionSkin = onionSkinRange.redIndicies.compactMap({ self.scene.getShot($0, after: self.shot) })
            .reduce(UIImage.solidImage(ofColor: .clear, ofSize: self.canvasSize), { $0.mergeWith($1.redOnionSkin) })
        
        let greenOnionSkin = onionSkinRange.greenIndicies.compactMap({ self.scene.getShot($0, after: self.shot) })
            .reduce(UIImage.solidImage(ofColor: .clear, ofSize: self.canvasSize), { $0.mergeWith($1.greenOnionSkin) })
        
        self.shotView.updateOnionSkins(skins: redOnionSkin.mergeWith(greenOnionSkin))
    }
    
    private func updateShotTransform() {
        self.shotView.transform = .identity
        self.shotView.transform = self.zoomToFitTransform.concatenating(self.canvasTransform)
        self.shotView.center = self.canvasCenter
    }

    private var panPosition = CGPoint.zero
    private var additionalLayerTransform = CGAffineTransform.identity
}

// MARK: - Gestures
extension ShotDesignerViewController {
    
    @IBAction private func handlePan(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            self.panPosition = sender.location(in: view)
        case .changed:
            let location = sender.location(in: view)
            let offsetX = location.x - self.panPosition.x
            let offsetY = location.y - self.panPosition.y
            self.panPosition = location

            switch self.editingMode {
            case .transformLayer:
                self.transformLayer(
                    using: CGAffineTransform(translationX: offsetX, y: offsetY)
                )
            case .free, .drawing:
                self.canvasTransform = self.canvasTransform.concatenating(
                    CGAffineTransform(translationX: offsetX, y: offsetY)
                )
            }
        case .ended:
            switch self.editingMode {
            case .transformLayer:
                guard self.selectedLayer?.canTransform == true else {
                    return
                }
                self.endTransform()
            case .free, .drawing:
                return
            }
        default:
            return
        }
    }

    @IBAction private func handlePinch(_ sender: UIPinchGestureRecognizer) {
        switch self.editingMode {
        case .transformLayer:
            self.scaleLayer(sender)
        case .free, .drawing:
            self.scaleCanvas(sender)
        }
    }
    
    private func scaleCanvas(_ sender: UIPinchGestureRecognizer) {
        let scale = sender.scale
        sender.scale = 1
        self.canvasTransform = self.canvasTransform.scaledBy(x: scale, y: scale)
    }
    
    private func scaleLayer(_ sender: UIPinchGestureRecognizer) {
        guard self.selectedLayer?.canTransform == true else {
            return
        }
        let scale = sender.scale
        sender.scale = 1
        self.transformLayer(using: CGAffineTransform(scaleX: scale, y: scale))
        if sender.state == .ended {
            self.endTransform()
        }
    }

    @IBAction private func handleRotation(_ sender: UIRotationGestureRecognizer) {
        switch self.editingMode {
        case .transformLayer:
            self.rotateLayer(sender)
        case .free, .drawing:
            self.rotateCanvas(sender)
        }
    }
    
    private func rotateCanvas(_ sender: UIRotationGestureRecognizer) {
        let rotation = sender.rotation
        sender.rotation = .zero
        self.canvasTransform = self.canvasTransform.rotated(by: rotation)
    }
    
    private func rotateLayer(_ sender: UIRotationGestureRecognizer) {
        guard self.selectedLayer?.canTransform == true else {
            return
        }
        let rotation = sender.rotation
        sender.rotation = .zero
        self.transformLayer(using: CGAffineTransform(rotationAngle: rotation))
        if sender.state == .ended {
            self.endTransform()
        }
    }

    private func transformLayer(using transform: CGAffineTransform) {
        guard let layer = self.selectedLayer, layer.canTransform else {
            return
        }
        self.shotView.transformedSelectedLayer(using: transform)
        self.additionalLayerTransform = self.additionalLayerTransform.concatenating(transform)
    }
    private func endTransform() {
        guard let layer = self.selectedLayer, layer.canTransform else {
            return
        }
        let newLayer = layer.transformed(using: additionalLayerTransform)
        
        self.shot.updateLayer(layer, with: newLayer)
        self.modelManager.generateThumbnailAndSave(project: self.project, shot: self.shot)
        self.modelManager.observers.forEach({ $0.DidUpdateLayer() })
        self.modelManager.saveProject(self.project)

//        modelManager.updateLayer(layerLabel: layer.label, withLayer: newLayer)
        additionalLayerTransform = .identity
        setUpShot()
    }

}

// MARK: - Actions
extension ShotDesignerViewController {
    
    @IBAction private func zoomToFit() {
        self.canvasTransform = .identity
        self.updateShotTransform()
    }

    @IBAction private func duplicateShot(_ sender: UIBarButtonItem) {
        if let index = self.scene.shots.firstIndex(where: { $0 === self.shot }) {
            let newShot = self.shot.duplicate()
            self.scene.addShot(newShot, at: index + 1)
            self.modelManager.saveProject(self.project)
        }
        
//        modelManager.addShot(ofShot: shotLabel.nextLabel,
//                             shot: shot,
//                             backgroundColor: shot.backgroundColor.uiColor)
    }

    @IBAction private func toggleTransformLayer(_ sender: TransformLayerButton) {
        if self.editingMode == .transformLayer {
            self.editingMode = .free
        } else {
            self.editingMode = .transformLayer
        }
    }

    @IBAction private func toggleDrawingMode(_ sender: DrawingModeButton) {
        if self.editingMode == .drawing {
            self.editingMode = .free
        } else {
            self.editingMode = .drawing
        }
    }

    @IBAction private func nextShot(_ sender: Any) {
        guard let nextShot = self.scene.getShot(1, after: shot) else {
            return
        }
        self.setShot(to: nextShot)
        self.setUpShot()
    }

    @IBAction private func previousShot(_ sender: Any) {
        guard let prevShot = self.scene.getShot(-1, after: shot) else {
            return
        }
        self.setShot(to: prevShot)
        self.setUpShot()
    }
}

// MARK: - ModelManagerObserver
extension ShotDesignerViewController: ModelManagerObserver {
    func modelDidChange() {
        // TODO: disable this since PKCanvasView will get refreshed every time
//        setUpShot()
    }
    func DidUpdateLayer() {
        self.shotView.updateLayerViews(newLayerViews: DrawingUtility.generateLayerViews(for: self.shot))
    }
    func DidAddLayer(layer: Layer) {
        self.shotView.add(layerView: DrawingUtility.generateLayerView(for: layer),
                          toolPicker: toolPicker, PKDelegate: self)
        self.selectedLayerIndex = self.shot.layers.count - 1
    }
}
// MARK: - PKCanvasViewDelegate
extension ShotDesignerViewController: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        guard let selectedLayer = selectedLayer else {
            return
        }
        let newLayer = selectedLayer.setDrawing(to: canvasView.drawing)
        self.shot.updateLayer(selectedLayer, with: newLayer)
        self.modelManager.generateThumbnailAndSave(project: self.project, shot: self.shot)
        self.modelManager.observers.forEach({ $0.DidUpdateLayer() })
        self.modelManager.saveProject(self.project)
        
//        modelManager.updateLayer(layerLabel: newLayer.label, withLayer: newLayer)
    }
}

// MARK: - PKToolPickerObserver {
extension ShotDesignerViewController: PKToolPickerObserver {
    func toolPickerFramesObscuredDidChange(_ toolPicker: PKToolPicker) {
        self.updateShotTransform()
    }
}

// MARK: - Segues
extension ShotDesignerViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let layerTable = segue.destination as? LayerTableController {
            self.editingMode = .free
            layerTable.onionSkinRange = onionSkinRange
            layerTable.selectedLayerIndex = selectedLayerIndex
            layerTable.modelManager = modelManager
            layerTable.shot = shot
            layerTable.scene = scene
            layerTable.project = project
            layerTable.delegate = self
        }
    }
}
// MARK: - Zoom To Fit Resize
extension ShotDesignerViewController {
    var windowSize: CGSize {
        self.view.frame.size
    }
    var windowWidth: CGFloat {
        self.windowSize.width
    }
    var windowHeight: CGFloat {
        self.windowSize.height
    }

    var topInset: CGFloat {
        self.view.safeAreaInsets.top
    }
    var bottomInset: CGFloat {
        max(self.view.safeAreaInsets.bottom, self.toolPicker.frameObscured(in: self.view).height)
    }

    var canvasMaxHeight: CGFloat {
        self.windowHeight - self.topInset - self.bottomInset - Constants.verticalCanvasMargin * 2
    }
    var canvasMaxWidth: CGFloat {
        self.windowWidth - Constants.horizontalCanvasMargin * 2
    }
    var canvasMaxSize: CGSize {
        CGSize(width: self.canvasMaxWidth, height: self.canvasMaxHeight)
    }

    var canvasCenterY: CGFloat {
        self.topInset + Constants.verticalCanvasMargin + self.canvasMaxHeight / 2
    }
    var canvasCenterX: CGFloat {
        self.windowWidth / 2
    }
    var canvasCenter: CGPoint {
        CGPoint(x: self.canvasCenterX, y: self.canvasCenterY)
    }

    var canvasCenterTranslation: (x: CGFloat, y: CGFloat) {
        (self.canvasCenterX - self.shotView.center.x, self.canvasCenterY - self.shotView.center.y)
    }

    var canvasScale: CGFloat {
        let widthScale = self.canvasMaxWidth / self.shotView.bounds.width
        let heightScale = self.canvasMaxHeight / self.shotView.bounds.height
        return min(widthScale, heightScale)
    }

    var zoomToFitTransform: CGAffineTransform {
        CGAffineTransform(scaleX: self.canvasScale, y: self.canvasScale)
    }

}

// MARK: - UIGestureRecognizerDelegate
extension ShotDesignerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        gestureRecognizer is UIRotationGestureRecognizer
            || gestureRecognizer is UIPinchGestureRecognizer
            || gestureRecognizer is UIPanGestureRecognizer
    }
}

extension ShotDesignerViewController: LayerTableDelegate {
    func backgroundColorDidChange() {
        self.shotView.backgroundColor = self.shot.backgroundColor.uiColor
    }

    func onionSkinsDidChange() {
        self.updateOnionSkins()
    }
    func didMoveLayer(from oldIndex: Int, to newIndex: Int) {
        self.shotView.moveLayer(from: oldIndex, to: newIndex)
    }

    func didSelectLayer(at index: Int) {
        self.selectedLayerIndex = index
    }

    func didToggleLayerLock(at index: Int) {
        self.toggleLayerLock(at: index)
    }
    func didToggleLayerVisibility(at index: Int) {
        self.toggleLayerVisibility(at: index)
    }
    func didChangeLayerName(at index: Int, newName: String) {
        // TODO
    }

    func willRemoveLayers(at indices: [Int]) {
        self.shotView.removeLayers(at: indices)
    }

    func willDuplicateLayers(at indices: [Int]) {
        self.shotView.duplicateLayers(at: indices)
    }

    func willGroupLayers(at indices: [Int]) {
        self.shotView.groupLayers(at: indices)
    }

    func willUngroupLayer(at index: Int) {
        self.shotView.ungroupLayer(at: index)
    }
    private func toggleLayerLock(at index: Int) {

        let layer = self.shot.layers[index]
        let newLayer = layer.duplicate()
        newLayer.isLocked.toggle()
        self.shot.updateLayer(layer, with: newLayer)
        self.modelManager.generateThumbnailAndSave(project: self.project, shot: self.shot)
        self.modelManager.observers.forEach({ $0.DidUpdateLayer() })
        self.modelManager.saveProject(self.project)
        
//        modelManager.updateLayer(layerLabel: newLayer.label, withLayer: newLayer)
    }

    private func toggleLayerVisibility(at index: Int) {

        let layers = self.shot.layers
        let layer = layers[index]
        let newLayer = layer.duplicate()
        newLayer.isVisible.toggle()
        self.shot.updateLayer(layer, with: newLayer)
        self.modelManager.generateThumbnailAndSave(project: self.project, shot: self.shot)
        self.modelManager.observers.forEach({ $0.DidUpdateLayer() })
        self.modelManager.saveProject(self.project)
    }
}
// MARK: - UIDropInteractionDelegate
extension ShotDesignerViewController: UIDropInteractionDelegate {
    func dropInteraction(_ interaction: UIDropInteraction,
                         canHandle session: UIDropSession) -> Bool {
        session.canLoadObjects(ofClass: UIImage.self)
    }
    func dropInteraction(_ interaction: UIDropInteraction,
                         sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        UIDropProposal(operation: .copy)
    }
    func dropInteraction(_ interaction: UIDropInteraction,
                         performDrop session: UIDropSession) {
        session.loadObjects(ofClass: UIImage.self) { [weak self] imageItems in
            guard let image = imageItems.first as? UIImage,
                  let self = self else {
                return
            }
            let layer = Layer(withImage: image, canvasSize: self.shot.canvasSize)
            self.shot.addLayer(layer)
            self.modelManager.generateThumbnailAndSave(project: self.project, shot: self.shot)
            self.modelManager.observers.forEach({ $0.DidUpdateLayer() })
            self.modelManager.saveProject(self.project)
//            self.modelManager?.addLayer(to: self.shotLabel, withImage: image)
        }
    }
}
