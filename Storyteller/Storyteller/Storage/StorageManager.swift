//
//  StorageManager.swift
//  Storyteller
//
//  Created by Marcus on 25/4/21.
//
import Foundation

protocol StorageManager {
    var fileUrl: URL { get }
    func delete(layer: PersistedLayer)
    func delete(shot: PersistedShot)
    func delete(scene: PersistedScene)
    func delete(project: Project)
    func save(layer: Layer)
    func save(shot: Shot)
    func save(scene: Scene)
    func save(project: Project)
}

extension StorageManager {
    var fileUrl: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
