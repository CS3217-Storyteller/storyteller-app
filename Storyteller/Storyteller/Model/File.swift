//
//  File.swift
//  Storyteller
//
//  Created by John Pan on 1/5/21.
//

import Foundation

protocol File {
    
    var name: String { get }
    
    var description: String { get }
    
    var size: Int { get }
    
    var dateAdded: Date { get }
    
    var dateUpdated: Date { get }
}
