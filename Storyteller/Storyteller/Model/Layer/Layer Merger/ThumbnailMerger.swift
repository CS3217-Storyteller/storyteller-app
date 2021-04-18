//
//  ThumbnailMerger.swift
//  Storyteller
//
//  Created by TFang on 18/4/21.
//

import UIKit

class ThumbnailMerger: LayerMerger {

    func mergeDrawing(component: DrawingComponent) -> Thumbnail {
        let thumbnail = component.merge(merger: ImageMerger())
        let redOnionSkin = component.merge(merger: RedOnionSkinMerger())
        let greenOnionSkin = component.merge(merger: GreenOnionSkinMerger())
        return Thumbnail(defaultThumbnail: thumbnail, redOnionSkin: redOnionSkin,
                         greenOnionSkin: greenOnionSkin)
    }
    func mergeImage(component: ImageComponent) -> Thumbnail {
        let thumbnail = component.merge(merger: ImageMerger())
        let redOnionSkin = component.merge(merger: RedOnionSkinMerger())
        let greenOnionSkin = component.merge(merger: GreenOnionSkinMerger())
        return Thumbnail(defaultThumbnail: thumbnail, redOnionSkin: redOnionSkin,
                         greenOnionSkin: greenOnionSkin)
    }

    func merge(results: [Thumbnail], composite: CompositeComponent) -> Thumbnail {
        let thumbnail = composite.merge(merger: ImageMerger())
        let redOnionSkin = composite.merge(merger: RedOnionSkinMerger())
        let greenOnionSkin = composite.merge(merger: GreenOnionSkinMerger())
        return Thumbnail(defaultThumbnail: thumbnail, redOnionSkin: redOnionSkin,
                         greenOnionSkin: greenOnionSkin)
    }
}
