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

        updateShot()

        navigationController?.setToolbarHidden(false, animated: false)
        navigationItem.leftItemsSupplementBackButton = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateShotTransform()
    }

    private func updateShot() {
        shotView.backgroundColor = shot?.backgroundColor.uiColor

        guard let layers = modelManager.getLayers(of: shotLabel),
              !layers.isEmpty else {
            return
        }

        let layerViews = layers.map({ DrawingUtility.generateLayerView(for: $0) })
        shotView.setUpLayerViews(layerViews, toolPicker: toolPicker, PKDelegate: self)
        shotView.currentCanvasView?.becomeFirstResponder()

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
        canvasTransform = canvasTransform.scaledBy(x: scale, y: scale)
        sender.scale = 1
    }
    private func scaleLayer(_ sender: UIPinchGestureRecognizer) {

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
        canvasTransform = canvasTransform.rotated(by: rotation)
        sender.rotation = .zero
    }
    private func rotateLayer(_ sender: UIRotationGestureRecognizer) {
        guard let layer = selectedLayer else {
            return
        }
        let rotation = sender.rotation
        // TODO: also change view
        modelManager.update(layer: layer.rotated(by: rotation), at: selectedLayerIndex,
                            ofShot: shotLabel)
    }

}

// MARK: - Actions
extension ShotDesignerViewController {
    @IBAction private func zoomToFit() {
        canvasTransform = .identity
        updateShotTransform()
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
        updateShot()
    }
}
// MARK: - PKCanvasViewDelegate
extension ShotDesignerViewController: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        guard let newLayer = selectedLayer?.setDrawing(to: canvasView.drawing) else {
            return
        }
        modelManager.update(layer: newLayer, at: selectedLayerIndex, ofShot: shotLabel)
//        modelManager.updateDrawing(ofShot: shotLabel, atLayer: index, withDrawing: canvasView.drawing)
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
