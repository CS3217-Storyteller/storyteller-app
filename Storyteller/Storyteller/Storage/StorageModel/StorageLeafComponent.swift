//
//  StorageLeafComponent.swift
//  Storyteller
//
//  Created by TFang on 28/3/21.
//

import Foundation

enum StorageError: Error {
    case invalidLeafComponent
}

enum StorageLeafComponent: Codable {
    case drawing(DrawingComponent)


    init(leaf: LeafComponent) throws {
        if let component = leaf as? DrawingComponent {
            self = StorageLeafComponent.drawing(component)
            return
        }

        throw StorageError.invalidLeafComponent
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
