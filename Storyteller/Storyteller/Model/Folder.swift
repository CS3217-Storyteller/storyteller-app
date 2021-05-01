//
//  File.swift
//  Storyteller
//
//  Created by John Pan on 1/5/21.
//

import Foundation

class Folder: Directory {
    
    var name: String
    
    var description: String
    
    var size: Int
    
    var dateAdded: Date
    
    var dateUpdated: Date
    
    var children: [Folder]

    init(name: String) {
        self.name = name
        self.description = ""
        self.size = 0
        self.dateAdded = Date()
        self.dateUpdated = Date()
        self.children = []
    }
}
