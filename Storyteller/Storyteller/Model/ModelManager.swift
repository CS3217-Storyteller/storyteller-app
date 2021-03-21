//
//  ModelManager.swift
//  Storyteller
//
//  Created by TFang on 20/3/21.
//

import PencilKit

// TODO
class ModelManager {
    func getBackgroundColor(of shotLabel: ShotLabel) -> UIColor {
        return #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }

    func getLayers(of shotLabel: ShotLabel) -> [Layer] {
        return []
    }

    func getCanvasSize(of shotLabel: ShotLabel) -> CGSize {
        return CGSize(width: Constants.screenWidth, height: Constants.screenHeight)
    }

    func updateDrawing(ofShot: ShotLabel, atLayer: Int, drawing: PKDrawing) {
    }
}
