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

class CompositeLayerComponent: Codable {
    var frame: CGRect {
        guard let drawingBounds = drawingComponent?.drawing.bounds else {
            return children.map({ $0.frame }).reduce(CGRect.zero, { $0.union($1)})
        }
        return children.map({ $0.frame }).reduce(drawingBounds, { $0.union($1)})
    }

    private var children = [CompositeLayerComponent]()
    var drawingComponent: DrawingComponent?

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

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case drawingComponent
        case children
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        drawingComponent = try values.decode(DrawingComponent.self, forKey: .drawingComponent)
        children = try values.decode([CompositeLayerComponent].self, forKey: .children)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(drawingComponent, forKey: .drawingComponent)
        try container.encode(children, forKey: .children)
    }

}

class DrawingComponent: CompositeLayerComponent {
    override var frame: CGRect {
        drawing.bounds
    }
    override func isComposite() -> Bool {
        false
    }

    private(set) var drawing: PKDrawing

    init(drawing: PKDrawing) {
        self.drawing = drawing
    }

    override func addToMerger(_ merger: LayerMerger) {
        merger.mergeDrawing(component: self)
    }

    override func extractDrawing() -> PKDrawing? {
        drawing
    }

    func appendDrawing(_ toAppend: PKDrawing) {
        drawing.append(toAppend)
    }

    func setDrawingTo(_ updatedDrawing: PKDrawing) {
        drawing = updatedDrawing
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case drawing
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        drawing = try values.decode(PKDrawing.self, forKey: .drawing)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(drawing, forKey: .drawing)
    }
}

