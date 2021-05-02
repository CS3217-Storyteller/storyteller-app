//
//  Folder.swift
//  Storyteller
//
//  Created by John Pan on 2/5/21.
//

import Foundation

class Folder: Directory {

    var id: UUID

    var name: String

    var description: String

    var dateAdded: Date

    var dateUpdated: Date

    var children: [Directory]

    init(name: String) {
        self.id = UUID()
        self.name = name
        self.description = ""
        self.dateAdded = Date()
        self.dateUpdated = Date()
        self.children = []
    }
}
