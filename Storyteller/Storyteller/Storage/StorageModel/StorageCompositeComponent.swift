//
//  StorageCompositeComponent.swift
//  Storyteller
//
//  Created by TFang on 28/3/21.
//

struct StorageCompositeComponent: Codable {
    var components = [StorageLeafComponent]()

    init(_ composite: LayerComponentNode) {
        composite.components.forEach({ components.append(StorageLeafComponent($0)) })
    }

}

extension StorageCompositeComponent {
    var compositeComponent: LayerComponentNode {
        LayerComponentNode(components: components.map({ $0.leafComponent }))
    }
}
