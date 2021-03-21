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
    // TODO enable the following line after implementing ModelManager
//    var modelManager: ModelManager!
    var modelManager: ModelManager!
    var shotLabel: ShotLabel!

    var canvasSize: CGSize {
        modelManager.getCanvasSize(of: shotLabel)
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
        shotView.backgroundColor = modelManager.getBackgroundColor(of: shotLabel)
        // TODO add drawings and setup tool picker
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

    var canvasScale = CGFloat(1) {
        didSet {
            shotView.updateZoomScale(scale: canvasScale)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if (gesture.location(in: self.view).x < 50) {
            dismiss(animated: true, completion: nil)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        canvasScale = shotView.bounds.width / canvasSize.width
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
        guard let layerView = canvasView as? LayerView,
              let index = shotView.layerViews.firstIndex(of: layerView) else {
            return
        }
        modelManager.updateDrawing(ofShot: shotLabel, atLayer: index, withDrawing: layerView.drawing)
    }
}
