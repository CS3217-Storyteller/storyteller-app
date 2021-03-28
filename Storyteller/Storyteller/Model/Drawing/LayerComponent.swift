//
//  LayerComponent.swift
//  Storyteller
//
//  Created by TFang on 28/3/21.
//

import PencilKit
//
//struct Layer<T: LayerComponent, Codable>: Decodable {
//    var component: LayerComponent
//    let canvasSize: CGSize
//
//    func addToMerger(_ merger: LayerMerger) {
//        component.addToMerger(merger)
//    }
//}

protocol Component: Codable {

}

struct Node<T: Component>: Codable {
    var component: T
    var children: [Node<T>] = []

    var drawingComponent: DrawingComponent {
        let drawing = PKDrawing()

    }

    init(value: T) {
        self.component = value
    }
    var frame: CGRect {
        guard let drawingBounds = drawingComponent?.drawing.bounds else {
            return children.map({ $0.frame }).reduce(CGRect.zero, { $0.union($1)})
        }
        return children.map({ $0.frame }).reduce(drawingBounds, { $0.union($1)})
    }


    func isComposite() -> Bool {
        true
    }

    func appendDrawing(_ drawing: PKDrawing?) {
        guard let drawing = drawing, isComposite() else {
            return
        }

        if drawingComponent?.appendDrawing(drawing) == nil {
            drawingComponent = DrawingComponent(drawing: drawing)
        }
    }

    func extractDrawing() -> PKDrawing? {
        let drawing = drawingComponent?.drawing
        drawingComponent = nil
        return drawing
    }

    func add(component: CompositeLayerComponent) {
        guard isComposite() else {
            return
        }

        appendDrawing(component.extractDrawing())

        guard !(component is DrawingComponent) else {
            return
        }

        children.append(component)
    }

    // may add remove() method if future features require

    func addToMerger(_ merger: LayerMerger) {
        children.forEach({ $0.addToMerger(merger) })
        drawingComponent?.addToMerger(merger)
    }
}

struct DrawingComponent: Component {
    private(set) var drawing: PKDrawing

    init(drawing: PKDrawing) {
        self.drawing = drawing
    }

    func addToMerger(_ merger: LayerMerger) {
        merger.mergeDrawing(component: self)
    }

    func extractDrawing() -> PKDrawing? {
        drawing
    }

    mutating func appendDrawing(_ toAppend: PKDrawing) {
        drawing.append(toAppend)
    }

    mutating func setDrawingTo(_ updatedDrawing: PKDrawing) {
        drawing = updatedDrawing
    }
}

//class CompositeLayerComponent: Codable {
//    var frame: CGRect {
//        guard let drawingBounds = drawingComponent?.drawing.bounds else {
//            return children.map({ $0.frame }).reduce(CGRect.zero, { $0.union($1)})
//        }
//        return children.map({ $0.frame }).reduce(drawingBounds, { $0.union($1)})
//    }
//
//    private var children = [CompositeLayerComponent]()
//    var drawingComponent: DrawingComponent?
//
//    func isComposite() -> Bool {
//        true
//    }
//
//    func appendDrawing(_ drawing: PKDrawing?) {
//        guard let drawing = drawing, isComposite() else {
//            return
//        }
//
//        if drawingComponent?.appendDrawing(drawing) == nil {
//            drawingComponent = DrawingComponent(drawing: drawing)
//        }
//    }
//
//    func extractDrawing() -> PKDrawing? {
//        let drawing = drawingComponent?.drawing
//        drawingComponent = nil
//        return drawing
//    }
//
//    func add(component: CompositeLayerComponent) {
//        guard isComposite() else {
//            return
//        }
//
//        appendDrawing(component.extractDrawing())
//
//        guard !(component is DrawingComponent) else {
//            return
//        }
//
//        children.append(component)
//    }
//
//    // may add remove() method if future features require
//
//    func addToMerger(_ merger: LayerMerger) {
//        children.forEach({ $0.addToMerger(merger) })
//        drawingComponent?.addToMerger(merger)
//    }
//
//}

//class DrawingComponent: CompositeLayerComponent {
//    override var frame: CGRect {
//        drawing.bounds
//    }
//    override func isComposite() -> Bool {
//        false
//    }
//
//    private(set) var drawing: PKDrawing
//
//    init(drawing: PKDrawing) {
//        self.drawing = drawing
//    }
//
//    override func addToMerger(_ merger: LayerMerger) {
//        merger.mergeDrawing(component: self)
//    }
//
//    override func extractDrawing() -> PKDrawing? {
//        drawing
//    }
//
//    func appendDrawing(_ toAppend: PKDrawing) {
//        drawing.append(toAppend)
//    }
//
//    func setDrawingTo(_ updatedDrawing: PKDrawing) {
//        drawing = updatedDrawing
//    }
//
//    // MARK: - Codable
//    enum CodingKeys: String, CodingKey {
//        case drawing
//    }
//
//    required init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        drawing = try values.decode(PKDrawing.self, forKey: .drawing)
//    }
//
//    override func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(drawing, forKey: .drawing)
//    }
//}
//
