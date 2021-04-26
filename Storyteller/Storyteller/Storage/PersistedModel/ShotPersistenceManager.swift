//
//  ShotPersistenceManager.swift
//  Storyteller
//
//  Created by mmarcus on 25/4/21.
//

import Foundation

struct ShotPersistenceManager: Identifiable {
    var shot: Shot
    var storageManager: StorageManager
    var id: UUID {
        shot.id
    }
}

// MARK: - ShotObserver
extension ShotPersistenceManager: ShotObserver {
    func modelDidChange() {
        print("ShotPersistenceManager: Shot changed!")
    }
}
