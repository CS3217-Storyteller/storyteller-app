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
            updateShotTransform()
        }
    }

    var canvasSize: CGSize {
        shot.canvasSize
    }

    var selectedLayerIndex: Int {
        get {
            shotView.selectedLayerIndex
        }
        set {
            shotView.selectedLayerIndex = newValue
        }
    }

    var selectedLayer: Layer {
        shot.layers[selectedLayerIndex]
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

    private func setUpShot() {
        shotView.backgroundColor = shot.backgroundColor.uiColor
        let layers = shot.layers

        if layers.isEmpty {
            return
        }

        let layerViews = layers.map({ DrawingUtility.generateLayerView(for: $0) })
        shotView.setUpLayerViews(layerViews, toolPicker: toolPicker, PKDelegate: self)
        updateOnionSkins()
        updateShotTransform()
    }

    private func updateOnionSkins() {
        guard modelManager != nil, shotView != nil else {
            return
        }
        let redOnionSkin = onionSkinRange.redIndicies.compactMap({ scene.getShot($0, after: shot) })
            .reduce(UIImage.solidImage(ofColor: .clear, ofSize: canvasSize), { $0.mergeWith($1.redOnionSkin) })
        let greenOnionSkin = onionSkinRange.greenIndicies.compactMap({ scene.getShot($0, after: shot) })
            .reduce(UIImage.solidImage(ofColor: .clear, ofSize: canvasSize), { $0.mergeWith($1.greenOnionSkin) })
        shotView.updateOnionSkins(skins: redOnionSkin.mergeWith(greenOnionSkin))
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
                transformLayer(
                    using: CGAffineTransform(translationX: offsetX, y: offsetY)
                )
            case .free, .drawing:
                canvasTransform = canvasTransform.concatenating(
                    CGAffineTransform(translationX: offsetX, y: offsetY)
                )
            }
        case .ended:
            switch editingMode {
            case .transformLayer:
                guard selectedLayer.canTransform else {
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
        guard selectedLayer.canTransform else {
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
        guard selectedLayer.canTransform else {
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
        guard selectedLayer.canTransform else {
            return
        }
        shotView.transformedSelectedLayer(using: transform)
        additionalLayerTransform = additionalLayerTransform.concatenating(transform)
    }
    private func endTransform() {
        guard selectedLayer.canTransform else {
            return
        }
        selectedLayer.transform(using: additionalLayerTransform)

        additionalLayerTransform = .identity
        setUpShot()

        modelManager.generateThumbnailAndSave(project: project, shot: shot)
    }

}

// MARK: - Actions
extension ShotDesignerViewController {

    @IBAction private func zoomToFit() {
        canvasTransform = .identity
        updateShotTransform()
    }

    @IBAction private func duplicateShot(_ sender: UIBarButtonItem) {
        if let index = scene.shots.firstIndex(where: { $0 === shot }) {
            let newShot = shot.duplicate()
            scene.addShot(newShot, at: index + 1)
            modelManager.saveProject(project)
        }

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

    @IBAction private func nextShot(_ sender: Any) {
        guard let nextShot = scene.getShot(1, after: shot) else {
            return
        }
        shot = nextShot
        setUpShot()
    }

    @IBAction private func previousShot(_ sender: Any) {
        guard let prevShot = scene.getShot(-1, after: shot) else {
            return
        }
        shot = prevShot
        setUpShot()
    }
}

// MARK: - ModelManagerObserver
extension ShotDesignerViewController: ModelManagerObserver {
    func modelDidChange() {
        // TODO: disable this since PKCanvasView will get refreshed every time
//        setUpShot()
    }
//    func DidUpdateLayer() {
//        shotView.updateLayerViews(newLayerViews: DrawingUtility.generateLayerViews(for: shot))
//    }
//    func DidAddLayer(layer: Layer) {
//        shotView.add(layerView: DrawingUtility.generateLayerView(for: layer),
//                     toolPicker: toolPicker, PKDelegate: self)
//        selectedLayerIndex = shot.layers.count - 1
//    }
}
// MARK: - PKCanvasViewDelegate
extension ShotDesignerViewController: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        selectedLayer.setDrawing(to: canvasView.drawing)
        modelManager.generateThumbnailAndSave(project: project, shot: shot)
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

            modelManager.observers.append(layerTable)

            layerTable.onionSkinRange = onionSkinRange
            layerTable.selectedLayerIndex = selectedLayerIndex
            layerTable.shot = shot
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

    func backgroundColorWillChange(color: UIColor) {
        shotView.backgroundColor = shot.backgroundColor.uiColor
        shot.setBackgroundColor(color: Color(uiColor: color))
        modelManager.generateThumbnailAndSave(project: project, shot: shot)
    }

    func didSelectLayer(at index: Int) {
        selectedLayerIndex = index
    }
    func onionSkinsDidChange() {
        updateOnionSkins()
    }
    func willMoveLayer(from oldIndex: Int, to newIndex: Int) {
        shotView.moveLayer(from: oldIndex, to: newIndex)
        shot.moveLayer(from: oldIndex, to: newIndex)
        modelManager.generateThumbnailAndSave(project: project, shot: shot)
    }

    func didToggleLayerLock(at index: Int) {
        let layer = shot.layers[index]
        layer.isLocked.toggle()
        shotView.updateLayerView(at: index, isLocked: layer.isLocked,
                                 isVisible: layer.isVisible)
        modelManager.generateThumbnailAndSave(project: project, shot: shot)
    }
    func didToggleLayerVisibility(at index: Int) {
        let layer = shot.layers[index]
        layer.isVisible.toggle()
        shotView.updateLayerView(at: index, isLocked: layer.isLocked,
                                 isVisible: layer.isVisible)
        modelManager.generateThumbnailAndSave(project: project, shot: shot)
    }

    func didChangeLayerName(at index: Int, newName: String) {
        let layer = shot.layers[index]
        layer.name = newName
        modelManager.generateThumbnailAndSave(project: project, shot: shot)
    }

    func willAddLayer() {
        let layer = Layer(withDrawing: PKDrawing(), canvasSize: shot.canvasSize)
        shotView.add(layerView: DrawingUtility.generateLayerView(for: layer),
                     toolPicker: toolPicker, PKDelegate: self)
        shot.addLayer(layer)
        selectTopLayer()
        modelManager.generateThumbnailAndSave(project: project, shot: shot)
    }
    private func selectTopLayer() {
        selectedLayerIndex = shot.layers.count - 1
    }
    func willRemoveLayers(at indices: [Int]) {
        guard !indices.isEmpty else {
            return
        }
        shotView.removeLayers(at: indices)
        shot.removeLayers(at: indices)
        modelManager.generateThumbnailAndSave(project: project, shot: shot)
    }

    func willDuplicateLayers(at indices: [Int]) {
        guard !indices.isEmpty else {
            return
        }
        shot.duplicateLayers(at: indices)
        setUpShot()
        modelManager.generateThumbnailAndSave(project: project, shot: shot)
    }

    func willGroupLayers(at indices: [Int]) {
        guard let lastIndex = indices.last else {
            return
        }
        let newIndex = lastIndex - (indices.count - 1)

        shot.groupLayers(at: indices)
        setUpShot()
        selectedLayerIndex = newIndex
        modelManager.generateThumbnailAndSave(project: project, shot: shot)
    }

    func willUngroupLayer(at index: Int) {
        shot.ungroupLayer(at: index)
        setUpShot()
        modelManager.generateThumbnailAndSave(project: project, shot: shot)
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
            self.shotView
                .add(layerView: DrawingUtility.generateLayerView(for: layer),
                     toolPicker: self.toolPicker, PKDelegate: self)
            self.selectTopLayer()
            self.modelManager.generateThumbnailAndSave(project: self.project, shot: self.shot)
        }
    }
}
