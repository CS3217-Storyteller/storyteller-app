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

    var editingMode = EditingMode.free {
        didSet {
            switch editingMode {
            case .free:
                transformLayerButton.unselect()
            case .transformLayer:
                transformLayerButton.select()
            }
        }
    }

    var toolPicker = PKToolPicker()
    // should be intialized via segue
    var modelManager: ModelManager!
    var shotLabel: ShotLabel!

    var canvasTransform = CGAffineTransform.identity {
        didSet {
            updateShotTransform()
        }
    }
    var shot: Shot? {
        modelManager.getShot(of: shotLabel)
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
        modelManager.getLayer(at: selectedLayerIndex, of: shotLabel)
    }

    func setModelManager(to modelManager: ModelManager) {
        self.modelManager = modelManager
    }

    func setShotLabel(to shotLabel: ShotLabel) {
        self.shotLabel = shotLabel
    }

    override var prefersStatusBarHidden: Bool {
        true
    }

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        toolPicker.addObserver(self)
        modelManager.observers.append(self)

        shotView.frame.size = canvasSize
        shotView.bounds.size = canvasSize

        setUpShot()

        navigationItem.leftItemsSupplementBackButton = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateShotTransform()
    }

    private func setUpShot() {
        shotView.backgroundColor = shot?.backgroundColor.uiColor

        guard let layers = modelManager.getLayers(of: shotLabel),
              !layers.isEmpty else {
            return
        }

        let layerViews = layers.map({ DrawingUtility.generateLayerView(for: $0) })
        shotView.setUpLayerViews(layerViews, toolPicker: toolPicker, PKDelegate: self)

        updateShotTransform()
    }

    private func updateShotTransform() {
        shotView.transform = .identity
        shotView.transform = zoomToFitTransform.concatenating(canvasTransform)

        shotView.center = canvasCenter
    }

    private var panPosition = CGPoint.zero
}

// MARK: - Gestures
extension ShotDesignerViewController {
    @IBAction private func handlePan(_ sender: UIPanGestureRecognizer) {
        switch editingMode {
        case .free:
            moveCanvas(sender)
        default:
            moveLayer(sender)
        }
    }
    private func moveCanvas(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            panPosition = sender.location(in: view)
        case .changed:
            let location = sender.location(in: view)
            let offsetX = location.x - panPosition.x
            let offsetY = location.y - panPosition.y
            canvasTransform = canvasTransform
                .concatenating(CGAffineTransform(translationX: offsetX, y: offsetY))
            panPosition = location
        default:
            return
        }
    }
    private func moveLayer(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            panPosition = sender.location(in: view)
        case .changed:
            let location = sender.location(in: view)
            let offsetX = location.x - panPosition.x
            let offsetY = location.y - panPosition.y
            panPosition = location

            transformLayer({ $0.translatedBy(x: offsetX, y: offsetY) })
        default:
            return
        }
    }

    @IBAction private func handlePinch(_ sender: UIPinchGestureRecognizer) {
        switch editingMode {
        case .free:
            scaleCanvas(sender)
        default:
            scaleLayer(sender)
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
        case .free:
            rotateCanvas(sender)
        default:
            rotateLayer(sender)
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
        guard let layer = selectedLayer else {
            return
        }
        let newLayer = transform(layer)
        modelManager.update(layer: newLayer, at: selectedLayerIndex, ofShot: shotLabel)
        shotView.updateLayerTransform(DrawingUtility.generateLayerView(for: newLayer))
    }
}

// MARK: - Actions
extension ShotDesignerViewController {
    @IBAction private func zoomToFit() {
        switch editingMode {
        case .free:
            canvasTransform = .identity
            updateShotTransform()
        case .transformLayer:
            transformLayer({ $0.resetTransform() })
        }
    }

    @IBAction private func duplicateShot(_ sender: UIBarButtonItem) {
        guard let shot = shot else {
            return
        }

        modelManager.addShot(ofShot: shotLabel.nextLabel,
                             layers: shot.layers,
                             backgroundColor: shot.backgroundColor.uiColor)
    }

    @IBAction private func toggleTransformLayer(_ sender: TransformLayerButton) {
        if editingMode == .transformLayer {
            editingMode = .free
        } else {
            editingMode = .transformLayer
        }
    }

}

// MARK: - ModelManagerObserver
extension ShotDesignerViewController: ModelManagerObserver {
    func modelDidChanged() {
        // TODO: disable this since PKCanvasView will get refreshed every time
//        updateShot()
    }
}
// MARK: - PKCanvasViewDelegate
extension ShotDesignerViewController: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        guard let newLayer = selectedLayer?.setDrawing(to: canvasView.drawing) else {
            return
        }
        modelManager.update(layer: newLayer, at: selectedLayerIndex, ofShot: shotLabel)
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
    @IBAction private func layerTableDidDismiss(_ segue: UIStoryboardSegue) {
        if let layerTable = segue.source as? LayerTableController {
            selectedLayerIndex = layerTable.selectedLayerIndex
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let layerTable = segue.destination as? LayerTableController {
            layerTable.selectedLayerIndex = selectedLayerIndex
            layerTable.modelManager = modelManager
            layerTable.shotLabel = shotLabel
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

    func didSelectLayer(at index: Int) {
        selectedLayerIndex = index
    }

    func didToggleLayerLock(at index: Int) {
        toggleLayerLock()
    }
    func didToggleLayerVisibility(at index: Int) {
        toggleLayerVisibility()
    }
    func didChangeLayerName(at index: Int, newName: String) {
        // TODO
    }

    private func toggleLayerLock() {
        guard var newLayer = selectedLayer else {
            return
        }
        newLayer.isLocked.toggle()
        modelManager.update(layer: newLayer, at: selectedLayerIndex, ofShot: shotLabel)
        shotView.toggleLayerLock()
    }
    private func toggleLayerVisibility() {
        guard var newLayer = selectedLayer else {
            return
        }
        newLayer.isVisible.toggle()
        modelManager.update(layer: newLayer, at: selectedLayerIndex, ofShot: shotLabel)
        shotView.toggleLayerVisibility()
    }
}
