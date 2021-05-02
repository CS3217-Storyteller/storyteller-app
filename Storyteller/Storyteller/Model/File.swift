//
//  File.swift
//  Storyteller
//
//  Created by John Pan on 2/5/21.
//

import Foundation

protocol File {

    var id: UUID { get }

    var name: String { get set }

    var description: String { get set }

    var dateAdded: Date { get }

    var dateUpdated: Date { get set }
}


extension File {
    mutating func rename(to name: String) {
        let filteredName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if filteredName.isEmpty {
            return
        }
        self.name = filteredName
    }

    mutating func updateDescription(to description: String) {
        let filteredDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        if filteredDescription.isEmpty {
            return
        }
        self.description = filteredDescription
    }

    mutating func dateWasUpdated() {
        self.dateUpdated = Date()
    }
}
