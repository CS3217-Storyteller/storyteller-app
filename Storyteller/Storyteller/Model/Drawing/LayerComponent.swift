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
protocol LayerComponent: Codable {
    var frame: CGRect { get }
    func isComposite() -> Bool
    func extractDrawing() -> PKDrawing?
    func addToMerger(_ merger: LayerMerger)
}

extension LayerComponent {
    func isComposite() -> Bool {
        false
    }
    func extractDrawing() -> PKDrawing? {
        nil
    }
}

struct CompositeLayerComponent: LayerComponent {
    var frame: CGRect {
        guard let drawingBounds = drawingComponent?.drawing.bounds else {
            return children.map({ $0.frame }).reduce(CGRect.zero, { $0.union($1)})
        }
        return children.map({ $0.frame }).reduce(drawingBounds, { $0.union($1)})
    }

    private var children = [LayerComponent]()
    var drawingComponent: DrawingComponent?

    func isComposite() -> Bool {
        true
    }

    mutating func appendDrawing(_ drawing: PKDrawing?) {
        guard let drawing = drawing else {
            return
        }

        if drawingComponent?.appendDrawing(drawing) == nil {
            drawingComponent = DrawingComponent(drawing: drawing)
        }
    }

    mutating func extractDrawing() -> PKDrawing? {
        let drawing = drawingComponent?.drawing
        drawingComponent = nil
        return drawing
    }

    mutating func add(component: LayerComponent) {
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

extension CompositeLayerComponent: Codable {
    enum CodingKeys: String, CodingKey {
        case drawingComponent
        case children
        case additionalInfo
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(drawingComponent, forKey: .drawingComponent)
        try container.encode(children, forKey: .children)

        var additionalInfo = container.nestedContainer(keyedBy: AdditionalInfoKeys.self, forKey: .additionalInfo)
        try additionalInfo.encode(elevation, forKey: .elevation)
    }
}

struct DrawingComponent: LayerComponent {
    var frame: CGRect {
        drawing.bounds
    }

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

extension DrawingComponent: Codable {

}
