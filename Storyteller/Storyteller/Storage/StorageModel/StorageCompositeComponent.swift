//
//  StorageCompositeComponent.swift
//  Storyteller
//
//  Created by TFang on 28/3/21.
//

struct StorageCompositeComponent: Codable {
    var components = [StorageLeafComponent]()

    init(_ composite: CompositeComponent) {
        composite.components.forEach( { components.append(StorageLeafComponent($0)) })
    }

}

extension StorageCompositeComponent {
    var compositeComponent: CompositeComponent {
        CompositeComponent(components: components.map({ $0.leafComponent }))
    }
}
