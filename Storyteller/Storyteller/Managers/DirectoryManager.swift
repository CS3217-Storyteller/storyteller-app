////
////  DirectoryManager.swift
////  Storyteller
////
////  Created by John Pan on 2/5/21.
////
//
//import Foundation
//
//class FolderManager {
//
//    var parent: Folder?
//    var current: Folder?
//    var children: current?.
//
//    var projects: [Project]
//
//    var observer: DirectoryManagerObserver?
//
//    init(
//        current: Folder? = nil,
//        parent: Folder? = nil,
//        children: [Directory] = [],
//        observer: DirectoryManagerObserver? = nil
//    ) {
//        self.current = current
//        self.parent = parent
//        self.children = []
//
//
//        current?.children
//
//        self.observer = observer
//
//        /// Mock
//        self.children.append(Folder(name: "Temp Folder"))
//        self.children.append(Folder(name: "Temp Folder 3"))
//        self.children.append(Folder(name: "Temp Folder 2"))
//        self.children.append(Project(title: "Project Temp 2", canvasSize: Constants.defaultCanvasSize))
//        self.children.append(Project(title: "Project Temp 6", canvasSize: Constants.defaultCanvasSize))
//        self.children.append(Project(title: "Project Temp 7", canvasSize: Constants.defaultCanvasSize))
//    }
//
//    func deleteChildren(at indexes: [Int]) {
//
//        let sortedIndexes = indexes.sorted(by: { $1 < $0 })
//
//        for index in sortedIndexes {
//            self.children.remove(at: index)
//        }
//        self.observer?.didChange()
//    }
//
//    func moveChildren(indexes: [Int], to folder: Folder) {
//        let sortedIndexes = indexes.sorted(by: { $1 < $0 })
//
//        print(sortedIndexes)
//        print(self.children)
//
//        for index in sortedIndexes {
//            print(index)
//            let child = self.children[index]
//            folder.children.append(child)
//            self.children.remove(at: index)
//        }
//        self.observer?.didChange()
//    }
//
//
//}
//
//protocol DirectoryManagerObserver {
//    func didChange()
//}
