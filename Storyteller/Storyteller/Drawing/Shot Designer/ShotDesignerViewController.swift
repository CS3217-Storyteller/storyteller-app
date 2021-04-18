//
//  ShotDesignerController.swift
//  Storyteller
//
//  Created by TFang on 20/3/21.
//
import UIKit
import PencilKit

class ShotDesignerViewController: UIViewController, PKToolPickerObserver {
    @IBOutlet private var shotView: ShotView!

    @IBOutlet private var transformLayerButton: TransformLayerButton!
    @IBOutlet private var drawingModeButton: DrawingModeButton!

    var editingMode = EditingMode.free {
        didSet {
            switch editingMode {
            case .free:
                self.transformLayerButton.deselect()
                self.drawingModeButton.deselect()
                self.shotView.isInDrawingMode = false
            case .transformLayer:
                self.transformLayerButton.select()
                self.drawingModeButton.deselect()
                self.shotView.isInDrawingMode = false
            case .drawing:
                self.transformLayerButton.deselect()
                self.drawingModeButton.select()
                self.shotView.isInDrawingMode = true
            }
        }
    }

    var toolPicker = PKToolPicker()
    
    // should be intialized via segue
    var shot: Shot!
    var scene: Scene!
    var project: Project!
    var modelManager: ModelManager!

    var canvasTransform = CGAffineTransform.identity {
        didSet {
            self.updateShotTransform()
        }
    }
    
    var canvasSize: CGSize {
        shot?.canvasSize ?? .zero
    }

    var selectedLayerIndex: Int {
        get {
            shotView.selectedLayerIndex
        }
        set {
            shotView.selectedLayerIndex = newValue
        }
    }

    var selectedLayer: Layer? {
        let layers = self.shot.orderedLayers
        let layer = layers[selectedLayerIndex]
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

        self.shotView.frame.size = self.canvasSize
        self.shotView.bounds.size = self.canvasSize

        self.setUpShot()

        self.editingMode = .drawing
        self.navigationItem.leftItemsSupplementBackButton = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.updateShotTransform()
    }

    @IBAction private func nextShot(_ sender: Any) {
        let currentShotId = self.shot.id
        guard let idx = self.scene.shotOrder.firstIndex(of: currentShotId) else {
            return
        }
        if idx + 1 >= scene.shotOrder.count {
            return
        }
        let nextShotId = scene.shotOrder[idx + 1]
        guard let nextShot = scene.shots[nextShotId] else {
            return
        }
        self.setShot(to: nextShot)
        self.setUpShot()

    }

    @IBAction private func previousShot(_ sender: Any) {
        let currentShotId = self.shot.id
        guard let idx = self.scene.shotOrder.firstIndex(of: currentShotId) else {
            return
        }
        if idx <= 0 {
            return
        }
        let nextShotId = self.scene.shotOrder[idx - 1]
        guard let nextShot = self.scene.shots[nextShotId] else {
            return
        }
        self.setShot(to: nextShot)
        self.setUpShot()
    }

    private func setUpShot() {
        self.shotView.backgroundColor = self.shot.backgroundColor.uiColor

        let layers = self.shot.orderedLayers
        
        if layers.isEmpty {
            return
        }

        let layerViews = layers.map({ DrawingUtility.generateLayerView(for: $0) })
        self.shotView.setUpLayerViews(layerViews, toolPicker: toolPicker, PKDelegate: self)

        self.updateShotTransform()
    }

    private func updateShotTransform() {
        self.shotView.transform = .identity
        self.shotView.transform = zoomToFitTransform.concatenating(canvasTransform)
        self.shotView.center = canvasCenter
    }

    private var panPosition = CGPoint.zero
}

// MARK: - Gestures
extension ShotDesignerViewController {
    @IBAction private func handlePan(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            panPosition = sender.location(in: view)
        case .changed:
            let location = sender.location(in: view)
            let offsetX = location.x - panPosition.x
            let offsetY = location.y - panPosition.y
            panPosition = location

            switch editingMode {
            case .transformLayer:
                transformLayer({ $0.translatedBy(x: offsetX, y: offsetY) })
            case .free, .drawing:
                canvasTransform = canvasTransform
                    .concatenating(CGAffineTransform(translationX: offsetX, y: offsetY))
            }
        default:
            return
        }
    }

    @IBAction private func handlePinch(_ sender: UIPinchGestureRecognizer) {
        switch editingMode {
        case .transformLayer:
            scaleLayer(sender)
        case .free, .drawing:
            scaleCanvas(sender)
        }
    }
    private func scaleCanvas(_ sender: UIPinchGestureRecognizer) {
        let scale = sender.scale
        sender.scale = 1
        canvasTransform = canvasTransform.scaledBy(x: scale, y: scale)
    }
    private func scaleLayer(_ sender: UIPinchGestureRecognizer) {
        let scale = sender.scale
        sender.scale = 1
        transformLayer({ $0.scaled(by: scale) })
    }

    @IBAction private func handleRotation(_ sender: UIRotationGestureRecognizer) {
        switch editingMode {
        case .transformLayer:
            rotateLayer(sender)
        case .free, .drawing:
            rotateCanvas(sender)
        }
    }
    private func rotateCanvas(_ sender: UIRotationGestureRecognizer) {
        let rotation = sender.rotation
        sender.rotation = .zero
        canvasTransform = canvasTransform.rotated(by: rotation)
    }
    private func rotateLayer(_ sender: UIRotationGestureRecognizer) {
        let rotation = sender.rotation
        sender.rotation = .zero
        transformLayer({ $0.rotated(by: rotation) })
    }

    private func transformLayer(_ transform: (Layer) -> Layer) {
        guard let layer = selectedLayer, !layer.isLocked, layer.isVisible else {
            return
        }
        let newLayer = transform(layer)
        self.shot.updateLayer(withId: layer.id, withLayer: newLayer)
    }
}

// MARK: - Actions
extension ShotDesignerViewController {
    @IBAction private func zoomToFit() {
        switch editingMode {
        case .transformLayer:
            transformLayer({ $0.resetTransform() })
        case .free, .drawing:
            canvasTransform = .identity
            updateShotTransform()
        }
    }

    @IBAction private func duplicateShot(_ sender: UIBarButtonItem) {
        let newShot = self.shot.duplicate()
        if newShot.layers.isEmpty {
            let layer = Layer(id: UUID(), canvasSize: newShot.canvasSize , layerWithDrawing: PKDrawing())
            newShot.addLayer(with: layer)
        }
    
//        modelManager.addShot(ofShot: shotLabel.nextLabel,
//                             shot: shot,
//                             backgroundColor: shot.backgroundColor.uiColor)
    }

    @IBAction private func toggleTransformLayer(_ sender: TransformLayerButton) {
        if editingMode == .transformLayer {
            editingMode = .free
        } else {
            editingMode = .transformLayer
        }
    }

    @IBAction private func toggleDrawingMode(_ sender: DrawingModeButton) {
        if editingMode == .drawing {
            editingMode = .free
        } else {
            editingMode = .drawing
        }
    }

}

// MARK: - ModelManagerObserver
extension ShotDesignerViewController: ModelManagerObserver {
    func modelDidChange() {
        // TODO: disable this since PKCanvasView will get refreshed every time
//        setUpShot()
    }
    func layerDidUpdate() {
        self.shotView.updateLayerViews(newLayerViews: DrawingUtility.generateLayerViews(for: self.shot))
    }
    func willAddLayer() {
        self.shotView.add(
            layerView: DrawingUtility.generateLayerView(
                for: Layer.getEmptyLayer(
                    canvasSize: self.canvasSize,
                    name: Constants.defaultLayerName,
                    shotId: self.shot.id
                )
            ),
            toolPicker: self.toolPicker, PKDelegate: self
        )
    }
}
// MARK: - PKCanvasViewDelegate
extension ShotDesignerViewController: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        guard let newLayer = selectedLayer?.setDrawing(to: canvasView.drawing) else {
            return
        }
        
        self.shot.updateLayer(withId: newLayer.id, withLayer: newLayer)
        
//        modelManager.updateLayer(layerLabel: newLayer.label, withLayer: newLayer)
    }
}

// MARK: - PKToolPickerObserver {
extension ShotDesignerViewController {
    func toolPickerFramesObscuredDidChange(_ toolPicker: PKToolPicker) {
        updateShotTransform()
    }
}

// MARK: - Segues
extension ShotDesignerViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let layerTable = segue.destination as? LayerTableController {
            layerTable.selectedLayerIndex = self.selectedLayerIndex
            layerTable.modelManager = self.modelManager
            layerTable.shot = self.shot
            layerTable.scene = self.scene
            layerTable.project = self.project
            layerTable.delegate = self
        }
    }
}
// MARK: - Zoom To Fit Resize
extension ShotDesignerViewController {
    var windowSize: CGSize {
        view.frame.size
    }
    var windowWidth: CGFloat {
        windowSize.width
    }
    var windowHeight: CGFloat {
        windowSize.height
    }

    var topInset: CGFloat {
        view.safeAreaInsets.top
    }
    var bottomInset: CGFloat {
        max(view.safeAreaInsets.bottom, toolPicker.frameObscured(in: view).height)
    }

    var canvasMaxHeight: CGFloat {
        windowHeight - topInset - bottomInset - Constants.verticalCanvasMargin * 2
    }
    var canvasMaxWidth: CGFloat {
        windowWidth - Constants.horizontalCanvasMargin * 2
    }
    var canvasMaxSize: CGSize {
        CGSize(width: canvasMaxWidth, height: canvasMaxHeight)
    }

    var canvasCenterY: CGFloat {
        topInset + Constants.verticalCanvasMargin + canvasMaxHeight / 2
    }
    var canvasCenterX: CGFloat {
        windowWidth / 2
    }
    var canvasCenter: CGPoint {
        CGPoint(x: canvasCenterX, y: canvasCenterY)
    }

    var canvasCenterTranslation: (x: CGFloat, y: CGFloat) {
        (canvasCenterX - shotView.center.x, canvasCenterY - shotView.center.y)
    }

    var canvasScale: CGFloat {
        let widthScale = canvasMaxWidth / shotView.bounds.width
        let heightScale = canvasMaxHeight / shotView.bounds.height
        return min(widthScale, heightScale)
    }

    var zoomToFitTransform: CGAffineTransform {
        CGAffineTransform(scaleX: canvasScale, y: canvasScale)
    }

}

// MARK: UIGestureRecognizerDelegate
extension ShotDesignerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        gestureRecognizer is UIRotationGestureRecognizer
            || gestureRecognizer is UIPinchGestureRecognizer
            || gestureRecognizer is UIPanGestureRecognizer
    }
}

extension ShotDesignerViewController: LayerTableDelegate {
    func didMoveLayer(from oldIndex: Int, to newIndex: Int) {
        shotView.moveLayer(from: oldIndex, to: newIndex)
    }

    func didSelectLayer(at index: Int) {
        selectedLayerIndex = index
    }

    func didToggleLayerLock(at index: Int) {
        toggleLayerLock(at: index)
    }
    func didToggleLayerVisibility(at index: Int) {
        toggleLayerVisibility(at: index)
    }
    func didChangeLayerName(at index: Int, newName: String) {
        // TODO
    }

    func didRemoveLayers(at indices: [Int]) {
        shotView.removeLayers(at: indices)
    }

    private func toggleLayerLock(at index: Int) {

        let layers = self.shot.orderedLayers
        let layer = layers[index]
        let newLayer = layer.duplicate(withId: layer.id)
        newLayer.isLocked.toggle()
        self.shot.updateLayer(withId: newLayer.id, withLayer: newLayer)
//        modelManager.updateLayer(layerLabel: newLayer.label, withLayer: newLayer)
    }

    private func toggleLayerVisibility(at index: Int) {

        let layers = self.shot.orderedLayers
        let layer = layers[index]
        let newLayer = layer.duplicate(withId: layer.id)
        newLayer.isVisible.toggle()
        self.shot.updateLayer(withId: layer.id, withLayer: newLayer)
//        modelManager.updateLayer(layerLabel: newLayer.label, withLayer: newLayer)
    }
}
