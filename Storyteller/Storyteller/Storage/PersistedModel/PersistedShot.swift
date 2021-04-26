//
//  PersistedShot.swift
//  Storyteller
//
//  Created by mmarcus on 26/4/21.
//

import UIKit

struct PersistedShot: Codable {
    var layers: [UUID]
    var backgroundColor: Color
    let canvasSize: CGSize
    var thumbnail: Thumbnail
    let id: UUID

    init(_ shot: Shot) {
        self.layers = shot.layers.map({ $0.id })
        self.backgroundColor = shot.backgroundColor
        self.canvasSize = shot.canvasSize
        self.thumbnail = shot.thumbnail
        self.id = shot.id
    }
}
