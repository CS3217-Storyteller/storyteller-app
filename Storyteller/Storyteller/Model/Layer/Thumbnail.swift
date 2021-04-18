//
//  Thumbnail.swift
//  Storyteller
//
//  Created by TFang on 18/4/21.
//
import UIKit
struct Thumbnail {
    var defaultThumbnail: Data
    var redThumbnail: Data
    var greenThumbnail: Data

    
}

extension Thumbnail: Codable {
}

extension Thumbnail {
    var thumbnail: UIImage {
        UIImage(data: defaultThumbnail)!
    }
    var redOnionSkin: UIImage {
        UIImage(data: redThumbnail)!
    }
    var greenOnionSkin: UIImage {
        UIImage(data: greenThumbnail)!
    }
}
