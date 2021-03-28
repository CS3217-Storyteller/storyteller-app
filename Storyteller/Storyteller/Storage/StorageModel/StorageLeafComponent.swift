//
//  StorageLeafComponent.swift
//  Storyteller
//
//  Created by TFang on 28/3/21.
//

enum StorageLeafComponent: Codable {
    case drawing(DrawingComponent)

    init(_ leaf: LeafComponent) {
        if let component = leaf as? DrawingComponent {
            self = StorageLeafComponent.drawing(component)
            return
        }

        fatalError("Failed to initilaize StorageLeafComponent")
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let component = try? container.decode(DrawingComponent.self) {
            self = .drawing(component)
            return
        }
        throw DecodingError
        .typeMismatch(StorageLeafComponent.self,
                      DecodingError.Context(codingPath: decoder.codingPath,
                                            debugDescription: "Wrong type for StorageLeafComponent"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .drawing(let component):
            try container.encode(component)
        }
    }
}

extension StorageLeafComponent {
    var leafComponent: LeafComponent {
        switch self {
        case .drawing(let component):
            return component
        }
    }
}
