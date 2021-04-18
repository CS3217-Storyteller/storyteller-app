//
//  StorageShot.swift
//  Storyteller
//
//  Created by TFang on 28/3/21.
//

import UIKit

struct StorageShot: Codable {
    var layers: [StorageLayer]
    var backgroundColor: Color
    let canvasSize: CGSize
    var thumbnail: Thumbnail

    init(_ shot: Shot) {
        self.layers = shot.layers.map({ StorageLayer($0) })
        self.backgroundColor = shot.backgroundColor
        self.canvasSize = shot.canvasSize
        self.thumbnail = shot.thumbnail
    }
}

extension StorageShot {
    var shot: Shot {
        Shot(canvasSize: canvasSize,
             backgroundColor: backgroundColor,
             layers: layers.map({ $0.layer }),
             thumbnail: thumbnail)
    }
}
