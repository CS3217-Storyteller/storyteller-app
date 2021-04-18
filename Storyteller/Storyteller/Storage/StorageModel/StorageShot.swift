//
//  StorageShot.swift
//  Storyteller
//
//  Created by TFang on 28/3/21.
//

import UIKit

struct StorageShot: Codable {
    var layers: [UUID: StorageLayer]
    var layerOrder: [UUID]
    var label: ShotLabel
    var backgroundColor: Color
    let canvasSize: CGSize

    var thumbnail: Data
    var redOnionSkin: Data
    var greenOnionSkin: Data

    init(_ shot: Shot) {
        self.layers = shot.layers.mapValues({ StorageLayer($0) })
        self.layerOrder = shot.layerOrder
        self.label = shot.label
        self.backgroundColor = shot.backgroundColor
        self.canvasSize = shot.canvasSize
        self.thumbnail = shot.thumbnail.pngData()!
        self.redOnionSkin = shot.redOnionSkin.pngData()!
        self.greenOnionSkin = shot.greenOnionSkin.pngData()!
    }
}

extension StorageShot {
    var shot: Shot {
        Shot(layers: layers.mapValues({ $0.layer }),
             layerOrder: layerOrder,
             id: label.shotId,
             label: label,
             backgroundColor: backgroundColor,
             canvasSize: canvasSize,
             thumbnail: UIImage(data: thumbnail)!,
             redOnionSkin: UIImage(data: redOnionSkin)!,
             greenOnionSkin: UIImage(data: greenOnionSkin)!)
    }
}
