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

    // MARK: - View Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setUpShot()

        navigationItem.leftItemsSupplementBackButton = true
    }

    private func setUpShot() {
        shotView.frame.origin = CGPoint(x: 0, y: 200)
        shotView.frame.size = canvasSize
        shotView.backgroundColor = shot?.backgroundColor.uiColor

        guard let layers = modelManager.getLayers(of: shotLabel) else {
            return
        }

        if !layers.isEmpty {
            let layerViews = layers.map({ DrawingUtility.generateLayerView(for: $0) })
            shotView.setUpLayerViews(layerViews, toolPicker: toolPicker)
        } else {
            modelManager.addLayer(type: .drawing, to: shotLabel)
            if let newLayers = modelManager.getLayers(of: shotLabel) {
                let layerViews = newLayers.map({ DrawingUtility.generateLayerView(for: $0) })
                shotView.setUpLayerViews(layerViews, toolPicker: toolPicker)
            }
        }
        shotView.layerViews.last?.becomeFirstResponder()
        shotView.setPKDelegate(delegate: self)
    }

    @IBAction private func duplicateShot(_ sender: UIBarButtonItem) {
        guard let shot = shot else {
            return
        }

        modelManager.addShot(ofShot: shotLabel.nextLabel,
                             layers: shot.layers,
                             backgroundColor: shot.backgroundColor.uiColor)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        zoomToFit()
    }

}

// MARK: - Actions
extension ShotDesignerViewController {
    @IBAction private func zoomToFit() {

        shotView.updateZoomScale(scale: canvasScale)
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
    var canvasMaxHeight: CGFloat {
        let navBarHeight = navigationController?.navigationBar.frame.height ?? 0
        let toolbarHeight = navigationController?.toolbar.frame.height ?? 0
        return Constants.screenHeight - navBarHeight
            - toolbarHeight - Constants.verticalCanvasMargin * 2
    }

    var canvasMaxWidth: CGFloat {
        Constants.screenWidth
    }

    var canvasMaxSize: CGSize {
        CGSize(width: canvasMaxWidth, height: canvasMaxHeight)
    }

    var canvasScale: CGFloat {
        shotView.bounds.width / canvasSize.width
    }
}
