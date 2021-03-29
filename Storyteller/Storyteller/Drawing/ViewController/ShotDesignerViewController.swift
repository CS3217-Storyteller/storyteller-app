//
//  ShotDesignerController.swift
//  Storyteller
//
//  Created by TFang on 20/3/21.
//
import UIKit
import PencilKit

class ShotDesignerViewController: UIViewController {
    @IBOutlet private var shotView: ShotView!

    var toolPicker = PKToolPicker()
    // should be intialized via segue
    var modelManager: ModelManager!
    var shotLabel: ShotLabel!

    var shotTransform = CGAffineTransform.identity {
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

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
        updateShotTransform()

        shotView.backgroundColor = shot?.backgroundColor.uiColor

        guard let layers = modelManager.getLayers(of: shotLabel),
              !layers.isEmpty else {
            return
        }

        let layerViews = layers.map({ DrawingUtility.generateLayerView(for: $0) })
        shotView.setUpLayerViews(layerViews, toolPicker: toolPicker, PKDelegate: self)

        shotView.currentCanvasView?.becomeFirstResponder()
    }

    private func updateShotTransform() {
        shotView.transform = .identity
        shotView.transform = zoomToFitTransform.concatenating(shotTransform)

        shotView.center = canvasCenter

    }

    @IBAction private func duplicateShot(_ sender: UIBarButtonItem) {
        guard let shot = shot else {
            return
        }

        modelManager.addShot(ofShot: shotLabel.nextLabel,
                             layers: shot.layers,
                             backgroundColor: shot.backgroundColor.uiColor)
    }

}

// MARK: - Actions
extension ShotDesignerViewController {
    @IBAction private func zoomToFit() {
        shotTransform = .identity
        updateShotTransform()
    }

}

// MARK: - PKCanvasViewDelegate
extension ShotDesignerViewController: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        guard let index = shotView.indexOfLayer(containing: canvasView) else {
            return
        }
        modelManager.updateDrawing(ofShot: shotLabel, atLayer: index, withDrawing: canvasView.drawing)
    }
}

// MARK: - Resize
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

    var navBarHeight: CGFloat {
        navigationController?.navigationBar.frame.height ?? 0
    }

    var toolbarHeight: CGFloat {
        navigationController?.toolbar.frame.height ?? 0
    }

    var topInset: CGFloat {
        navBarHeight + view.safeAreaInsets.top
    }

    var bottomInset: CGFloat {
        toolbarHeight + view.safeAreaInsets.bottom
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
    var zoomToFitTransform: CGAffineTransform {
        CGAffineTransform(scaleX: canvasScale, y: canvasScale)
            .translatedBy(x: canvasCenterTranslation.x, y: canvasCenterTranslation.y)
    }

//    var canvasScale: CGFloat {
//        shotView.bounds.width / canvasSize.width
//    }
    var canvasScale: CGFloat {
        let widthScale = canvasMaxWidth / shotView.bounds.width
        let heightScale = canvasMaxHeight / shotView.bounds.height
        return min(widthScale, heightScale)

    }
}
