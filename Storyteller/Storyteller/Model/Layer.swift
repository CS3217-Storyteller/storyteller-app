////
////  Layer.swift
////  Storyteller
////
////  Created by TFang on 20/3/21.
////
//import PencilKit
//
//protocol Layer: Codable {
////    var layerType: LayerType { get }
//    var drawing: PKDrawing { get set }
//    var canvasSize: CGSize { get }
//
//    func addToMerger(_ merger: LayerMerger)
//    mutating func setDrawingTo(_ updatedDrawing: PKDrawing)
//}
//
//struct DrawingLayer: Layer {
//
//
//    var layerType: LayerType
//    var drawing: PKDrawing
//    let canvasSize: CGSize
//
//    func addToMerger(_ merger: LayerMerger) {
//        merger.mergeDrawing(layer: self)
//    }
//    mutating func setDrawingTo(_ updatedDrawing: PKDrawing) {
//        drawing = updatedDrawing
//    }
//}
//
//struct ImageLayer: Layer {
//
//
//    var layerType: LayerType
//    var drawing: PKDrawing
//    let canvasSize: CGSize
//
//    func addToMerger(_ merger: LayerMerger) {
//        merger.mergeDrawing(layer: self)
//    }
//    mutating func setDrawingTo(_ updatedDrawing: PKDrawing) {
//        drawing = updatedDrawing
//    }
//}
//
//class LayerDecorator: Layer {
//    private var layer: Layer
//
//    init(layer: Layer) {
//        self.layer = layer
//    }
//
//    func addToMerger(_ merger: LayerMerger) {
//        layer.addToMerger(merger)
//    }
//}
//
//class ImageLayerDecorator: LayerDecorator {
//    override func addToMerger(_ merger: LayerMerger) {
//        layer.addToMerger(merger)
//    }
//}
