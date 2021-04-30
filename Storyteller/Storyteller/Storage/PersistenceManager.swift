//
//  PersistenceManager.swift
//  Storyteller
//
//  Created by mmarcus on 29/4/21.
//

import Foundation

struct PersistenceManager {
    var url: URL

    init(at url: URL? = nil) {
        let defaultUrl = FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.url = url ?? defaultUrl
    }
}

extension PersistenceManager {
    func getAllDirectoryUrls() -> [URL]? {
        try? FileManager.default.contentsOfDirectory(at: url,
                                                     includingPropertiesForKeys: [.isDirectoryKey],
                                                     options: .skipsSubdirectoryDescendants)
    }

    func createFolder(named folderName: String) {
        let newFolderUrl = url.appendingPathComponent(folderName)
        try? FileManager.default.createDirectory(at: newFolderUrl, withIntermediateDirectories: false)
    }

    func deleteFolder(named folderName: String) {
        let deletedFolderUrl = url.appendingPathComponent(folderName)
        try? FileManager.default.removeItem(at: deletedFolderUrl)
    }

    func saveData(_ data: Data, toFile fileName: String, atFolder folderName: String? = nil) {
        var targetFolderUrl: URL = url
        if let folderName = folderName {
            targetFolderUrl = url.appendingPathComponent(folderName)
        }
        let fileUrl = targetFolderUrl.appendingPathComponent(fileName).appendingPathExtension("json")
        try? data.write(to: fileUrl)
    }

    func loadData(_ fileName: String, atFolder folderName: String? = nil) -> Data? {
        var targetFolderUrl: URL = url
        if let folderName = folderName {
            targetFolderUrl = url.appendingPathComponent(folderName)
        }
        let fileUrl = targetFolderUrl.appendingPathComponent(fileName).appendingPathExtension("json")
        return FileManager.default.contents(atPath: fileUrl.path)
    }

    func deleteFile(_ fileName: String, atFolder folderName: String? = nil) {
        var targetFolderUrl: URL = url
        if let folderName = folderName {
            targetFolderUrl = url.appendingPathComponent(folderName)
        }
        let fileUrl = targetFolderUrl.appendingPathComponent(fileName).appendingPathExtension("json")
        try? FileManager.default.removeItem(at: fileUrl)
    }

    func encodeToJSON<T: Encodable>(_ encodableObject: T) -> Data? {
        try? JSONEncoder().encode(encodableObject)
    }
}

/*
class PersistenceManager {
    let manager = FileManager.default

    var url: URL {
        manager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    /// Creates a new project directory
    @discardableResult
    func saveProject(_ project: PersistedProject) -> Bool {
        let folderName = project.id.uuidString
        guard let jsonProject = try? JSONEncoder().encode(project) else {
            return false
        }
        let newFolderUrl = url.appendingPathComponent(folderName)
        guard (try? manager.createDirectory(at: newFolderUrl, withIntermediateDirectories: true, attributes: [:]))
                != nil else {
            return false
        }
        guard (try? jsonProject.write(to: newFolderUrl
                                        .appendingPathComponent("Project Metadata")
                                        .appendingPathExtension("json"))) != nil else {
            return false
        }
        return true
    }

    /// Delete the entire project directory associated with the project
    func deleteProject(_ project: PersistedProject) {
        let folderName = project.id.uuidString
        try? manager.removeItem(at: url.appendingPathComponent(folderName))
    }
}
*/
