//
//  LayerPersistenceManager.swift
//  Storyteller
//
//  Created by mmarcus on 25/4/21.
//

import Foundation

struct LayerPersistenceManager: Identifiable {
    var layer: Layer
    var storageManager: StorageManager
    var id: UUID {
        layer.id
    }
}

// MARK: - LayerObserver
extension LayerPersistenceManager: LayerObserver {
    func modelDidChange() {
        print("LayerPersistenceManager: Layer changed!")
    }
}
