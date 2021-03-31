//
//  StorageComponentNode.swift
//  Storyteller
//
//  Created by TFang on 31/3/21.
//

struct StorageComponentNode: Codable {
    enum StorageNodeType {
        case composite([StorageComponentNode])
        case drawing(DrawingComponent)
    }

    var transformInfo = TransformInfo()
    var type: StorageNodeType

    init(_ node: LayerComponentNode) {
        self = StorageComponentNode.generateStorageNode(node)
    }

    init(transformInfo: TransformInfo, type: StorageNodeType) {
        self.transformInfo = transformInfo
        self.type = type
    }

    static func generateStorageNode(_ node: LayerComponentNode) -> StorageComponentNode {
        switch node.type {
        case .composite(let children):
            let storageChildren = children.map({ generateStorageNode($0) })
            return StorageComponentNode(transformInfo: node.transformInfo,
                                        type: .composite(storageChildren))
        case .drawing(let drawingComponent):
            return StorageComponentNode(transformInfo: node.transformInfo,
                                        type: .drawing(drawingComponent))
        }
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

        if let children = try? container.decode([StorageComponentNode].self, forKey: .children) {
            self.type = .composite(children)
            return
        }

        if let drawingComponent = try? container.decode(DrawingComponent.self, forKey: .drawing) {
            self.type = .drawing(drawingComponent)
            return
        }

        throw CodableError.decoding("Error while decoding LayerComponentNode")
    }
}

extension StorageComponentNode {
    static func generateComponentNode(_ node: StorageComponentNode) -> LayerComponentNode {
        switch node.type {
        case .composite(let storageChildren):
            let children = storageChildren.map({ generateComponentNode($0) })
            return LayerComponentNode(transformInfo: node.transformInfo,
                                      type: .composite(children))
        case .drawing(let drawingComponent):
            return LayerComponentNode(transformInfo: node.transformInfo,
                                      type: .drawing(drawingComponent))
        }
    }

    var componentNode: LayerComponentNode {
        StorageComponentNode.generateComponentNode(self)
    }
}
