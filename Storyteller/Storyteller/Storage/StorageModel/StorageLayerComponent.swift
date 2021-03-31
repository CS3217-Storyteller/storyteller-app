//
//  StorageCompositeComponent.swift
//  Storyteller
//
//  Created by TFang on 31/3/21.
//

struct StorageLayerComponent: Codable {
    enum StorageNodeType {
        case composite([StorageLayerComponent])
        case drawing(DrawingComponent)
    }

    var transformInfo = TransformInfo()
    var type: StorageNodeType

    init(_ node: LayerComponent) {
        self = StorageLayerComponent.generateStorageComponent(node)
    }

    init(transformInfo: TransformInfo, type: StorageNodeType) {
        self.transformInfo = transformInfo
        self.type = type
    }

    static func generateStorageComponent(_ layerComponent: LayerComponent) -> StorageLayerComponent {
        if let drawingComponent = layerComponent as? DrawingComponent {
            return StorageLayerComponent(transformInfo: layerComponent.transformInfo,
                                         type: .drawing(drawingComponent))
        }
        if let composite = layerComponent as? CompositeComponent {
            let storageChildren = composite.children.map({ generateStorageComponent($0) })
            return StorageLayerComponent(transformInfo: layerComponent.transformInfo,
                                         type: .composite(storageChildren))
        }

        fatalError("Failed to generate storage layer component")
    }

    enum CodingKeys: String, CodingKey {
        case children
        case drawing

        case transformInfo
    }

    enum CodableError: Error {
        case decoding(String)
        case encoding(String)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(transformInfo, forKey: .transformInfo)

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
        transformInfo = try container.decode(TransformInfo.self, forKey: .transformInfo)

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
            return CompositeComponent(transformInfo: storageComponent.transformInfo,
                                      children: children)
        case .drawing(let drawingComponent):
            return drawingComponent
        }
    }

    var component: LayerComponent {
        StorageLayerComponent.generateLayerComponent(self)
    }
}
