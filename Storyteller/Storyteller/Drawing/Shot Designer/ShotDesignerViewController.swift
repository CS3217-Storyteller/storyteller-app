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
        guard let layers = modelManager.getLayers(of: shotLabel) else {
            return nil
        }
        let layer = layers[selectedLayerIndex]
        return layer
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

        shotView.setSize(canvasSize: canvasSize)
        setUpShot()

        editingMode = .drawing
        navigationItem.leftItemsSupplementBackButton = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateShotTransform()
    }

    @IBAction private func nextShot(_ sender: Any) {
        guard let scene = modelManager.getScene(of: shotLabel.sceneLabel) else {
            return
        }
        let currentShotId = self.shotLabel.shotId
        guard let index = scene.shotOrder.firstIndex(of: currentShotId) else {
            return
        }
        if index + 1 >= scene.shotOrder.count {
            return
        }
        let nextShotId = scene.shotOrder[index + 1]
        guard let nextShot = scene.shots[nextShotId] else {
            return
        }
        self.setShotLabel(to: nextShot.label)
        self.setUpShot()
    }

    @IBAction private func previousShot(_ sender: Any) {
        guard let scene = modelManager.getScene(of: shotLabel.sceneLabel) else {
            return
        }
        let currentShotId = self.shotLabel.shotId
        guard let index = scene.shotOrder.firstIndex(of: currentShotId) else {
            return
        }
        if index <= 0 {
            return
        }
        let nextShotId = scene.shotOrder[index - 1]
        guard let nextShot = scene.shots[nextShotId] else {
            return
        }
        self.setShotLabel(to: nextShot.label)
        self.setUpShot()
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
    private var additionalLayerTransform = CGAffineTransform.identity
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
                transformLayer(using: CGAffineTransform(translationX: offsetX,
                                                        y: offsetY))
            case .free, .drawing:
                canvasTransform = canvasTransform
                    .concatenating(CGAffineTransform(translationX: offsetX, y: offsetY))
            }
        case .ended:
            switch editingMode {
            case .transformLayer:
                guard selectedLayer?.canTransform == true else {
                    return
                }
                endTransform()
            case .free, .drawing:
                return
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
        guard selectedLayer?.canTransform == true else {
            return
        }
        let scale = sender.scale
        sender.scale = 1
        transformLayer(using: CGAffineTransform(scaleX: scale, y: scale))
        if sender.state == .ended {
            endTransform()
        }
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
        guard selectedLayer?.canTransform == true else {
            return
        }
        let rotation = sender.rotation
        sender.rotation = .zero
        transformLayer(using: CGAffineTransform(rotationAngle: rotation))
        if sender.state == .ended {
            endTransform()
        }
    }

    private func transformLayer(using transform: CGAffineTransform) {
        guard let layer = selectedLayer, layer.canTransform else {
            return
        }
        shotView.transformedSelectedLayer(using: transform)
        additionalLayerTransform = additionalLayerTransform.concatenating(transform)
    }
    private func endTransform() {
        guard let layer = selectedLayer, layer.canTransform else {
            return
        }
        let newLayer = layer.transformed(using: additionalLayerTransform)
        modelManager.updateLayer(layerLabel: layer.label, withLayer: newLayer)
        additionalLayerTransform = .identity
        setUpShot()
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
                             shot: shot,
                             backgroundColor: shot.backgroundColor.uiColor)
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
    func DidUpdateLayer() {
        guard let shot = shot else {
            return
        }
        shotView.updateLayerViews(newLayerViews: DrawingUtility.generateLayerViews(for: shot))
    }
    func DidAddLayer(layer: Layer) {
        shotView.add(layerView: DrawingUtility.generateLayerView(for: layer),
                     toolPicker: toolPicker, PKDelegate: self)
        selectedLayerIndex = (modelManager.getLayers(of: shotLabel)?.count ?? 1) - 1
    }
}
// MARK: - PKCanvasViewDelegate
extension ShotDesignerViewController: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        guard let newLayer = selectedLayer?.setDrawing(to: canvasView.drawing) else {
            return
        }
        modelManager.updateLayer(layerLabel: newLayer.label, withLayer: newLayer)
    }
}

// MARK: - PKToolPickerObserver {
extension ShotDesignerViewController: PKToolPickerObserver {
    func toolPickerFramesObscuredDidChange(_ toolPicker: PKToolPicker) {
        updateShotTransform()
    }
}

// MARK: - Segues
extension ShotDesignerViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let layerTable = segue.destination as? LayerTableController {
            editingMode = .free

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

    func willRemoveLayers(at indices: [Int]) {
        shotView.removeLayers(at: indices)
    }

    func willDuplicateLayers(at indices: [Int]) {
        shotView.duplicateLayers(at: indices)
    }

    func willGroupLayers(at indices: [Int]) {
        shotView.groupLayers(at: indices)
    }

    func willUngroupLayer(at index: Int) {
        shotView.ungroupLayer(at: index)
    }
    private func toggleLayerLock(at index: Int) {

        guard let layers = modelManager.getLayers(of: shotLabel) else {
            return
        }
        var newLayer = layers[index]
        newLayer.isLocked.toggle()
        modelManager.updateLayer(layerLabel: newLayer.label, withLayer: newLayer)
    }

    private func toggleLayerVisibility(at index: Int) {

        guard let layers = modelManager.getLayers(of: shotLabel) else {
            return
        }
        var newLayer = layers[index]
        newLayer.isVisible.toggle()
        modelManager.updateLayer(layerLabel: newLayer.label, withLayer: newLayer)
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
            self.modelManager?.addLayer(to: self.shotLabel, withImage: image)
        }
    }
}
