//
//  LayerComponent.swift
//  Storyteller
//
//  Created by TFang on 28/3/21.
//

import PencilKit

struct CompositeLayerComponent: LayerComponent {
    var compositeElements: [CompositeElement]

    var components: [LayerComponent] {
        compositeElements.map({ $0.component })
    }

    var drawingComponent: DrawingComponent? {
        compositeElements.compactMap({ $0.drawingComponent }).last
    }

    var frame: CGRect {
        components.map({ $0.frame }).reduce(CGRect.zero, { $0.union($1)})
    }

    mutating func setDrawing(to drawing: PKDrawing) {
        guard let index = compositeElements
                .lastIndex(where: { $0.drawingComponent != nil} ) else {
            return
        }
        compositeElements[index].setDrawing(to: drawing)
    }
    mutating func append(_ component: CompositeLayerComponent) {
        compositeElements.append(contentsOf: component.compositeElements)
    }

    mutating func append(_ drawingComponent: DrawingComponent) {
        let element = CompositeElement.drawing(drawingComponent)
        compositeElements.append(element)
    }

    // may add remove() method if future features require

    func addToMerger(_ merger: LayerMerger) {
        components.forEach({ $0.addToMerger(merger) })
    }
}

extension CompositeLayerComponent: Codable {

}

enum CompositeElement: LayerComponent, Codable {
    case drawing(DrawingComponent)

    var frame: CGRect {
        component.frame
    }

    mutating func setDrawing(to drawing: PKDrawing) {
        component.setDrawing(to: drawing)
    }

    var drawingComponent: DrawingComponent? {
        get {
            switch self {
            case .drawing(let component):
                return component
            default:
                return nil
            }
        }
    }

    var component: LayerComponent {
        get{
            switch self {
            case .drawing(let component):
                return component
            }
        }
        set {
            component = newValue
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let component = try? container.decode(DrawingComponent.self) {
            self = .drawing(component)
            return
        }
        throw DecodingError.typeMismatch(CompositeElement.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for CompositeElement"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .drawing(let component):
            try container.encode(component)
        }
    }
}

protocol LayerComponent: Codable {
    var frame: CGRect { get }
    mutating func setDrawing(to drawing: PKDrawing)
    func addToMerger(_ merger: LayerMerger)
}

protocol LeafComponent: LayerComponent {
}

struct DrawingComponent: LeafComponent {
    var frame: CGRect {
        drawing.bounds
    }

    private(set) var drawing: PKDrawing

    init(drawing: PKDrawing) {
        self.drawing = drawing
    }

    mutating func setDrawing(to drawing: PKDrawing) {
        self.drawing = drawing
    }

    func addToMerger(_ merger: LayerMerger) {
        merger.mergeDrawing(component: self)
    }
}

extension DrawingComponent: Codable {

}
