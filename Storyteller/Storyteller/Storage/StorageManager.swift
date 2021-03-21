//
//  StorageManager.swift
//  Storyteller
//
//  Created by TFang on 21/3/21.
//

import Foundation

class StorageManager {

    // MARK: - Load
    private var dataURLs: [URL] {
        StorageUtility.getDocumentDirectoryFileURLs(with: "json")?
            .sorted(by: { $0.deletingPathExtension().lastPathComponent
                        < $1.deletingPathExtension().lastPathComponent }) ?? []
    }

    var projectCount: Int {
        dataURLs.count
    }

    func getProjectTitle(at index: Int) -> String? {
        guard dataURLs.indices.contains(index) else {
            return nil
        }

        let url = dataURLs[index]
        return url.deletingPathExtension().lastPathComponent
    }

    func getLevel(at index: Int) -> Project? {
        guard dataURLs.indices.contains(index) else {
            return nil
        }

        let url = dataURLs[index]
        return loadProject(from: url)
    }

    private func loadProject(from url: URL) -> Project? {
        try? JSONDecoder().decode(Project.self, from: Data(contentsOf: url))
    }

    // MARK: - Save
    static func saveProject(project: Project) -> Bool {
        let fileName = project.projectLabel.projectTitle
        let fileUrl = StorageUtility.getFileUrl(of: fileName)
        guard (try? JSONEncoder().encode(project).write(to: fileUrl)) != nil else {
            return false
        }
        return true
    }

    static func deleteProject(projectTitle: String) {
        let filePath = StorageUtility.getFileUrl(of: projectTitle)
        try? FileManager.default.removeItem(at: filePath)
    }
}
