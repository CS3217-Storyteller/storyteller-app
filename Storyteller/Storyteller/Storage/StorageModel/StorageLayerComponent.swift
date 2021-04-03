//
//  StorageCompositeComponent.swift
//  Storyteller
//
//  Created by TFang on 31/3/21.
//
import CoreGraphics

struct StorageLayerComponent: Codable {
    enum StorageNodeType {
        case composite([StorageLayerComponent])
        case drawing(DrawingComponent)
    }

    var transform: CGAffineTransform
    var type: StorageNodeType

    init(_ node: LayerComponent) {
        self = StorageLayerComponent.generateStorageComponent(node)
    }

    init(transform: CGAffineTransform, type: StorageNodeType) {
        self.transform = transform
        self.type = type
    }

    static func generateStorageComponent(_ layerComponent: LayerComponent) -> StorageLayerComponent {
        if let drawingComponent = layerComponent as? DrawingComponent {
            return StorageLayerComponent(transform: layerComponent.transform,
                                         type: .drawing(drawingComponent))
        }
        if let composite = layerComponent as? CompositeComponent {
            let storageChildren = composite.children.map({ generateStorageComponent($0) })
            return StorageLayerComponent(transform: layerComponent.transform,
                                         type: .composite(storageChildren))
        }

        fatalError("Failed to generate storage layer component")
    }

    enum CodingKeys: String, CodingKey {
        case children
        case drawing

        case transform
    }

    enum CodableError: Error {
        case decoding(String)
        case encoding(String)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(transform, forKey: .transform)

        switch type {
        case .composite(let children):
            var childrenContainer = container.nestedUnkeyedContainer(forKey: .children)
            try childrenContainer.encode(contentsOf: children)
        case .drawing(let drawingComponent):
            try container.encode(drawingComponent, forKey: .drawing)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        transform = try container.decode(CGAffineTransform.self, forKey: .transform)

        if let children = try? container.decode([StorageLayerComponent].self, forKey: .children) {
            self.type = .composite(children)
            return
        }

        if let drawingComponent = try? container.decode(DrawingComponent.self, forKey: .drawing) {
            self.type = .drawing(drawingComponent)
            return
        }

        throw CodableError.decoding("Error while decoding StorageLayerComponent")
    }
}

extension StorageLayerComponent {
    static func generateLayerComponent(_ storageComponent: StorageLayerComponent) -> LayerComponent {
        switch storageComponent.type {
        case .composite(let storageChildren):
            let children = storageChildren.map({ generateLayerComponent($0) })
            return CompositeComponent(transform: storageComponent.transform,
                                      children: children)
        case .drawing(let drawingComponent):
            return drawingComponent
        }
    }

    var component: LayerComponent {
        StorageLayerComponent.generateLayerComponent(self)
    }
}
