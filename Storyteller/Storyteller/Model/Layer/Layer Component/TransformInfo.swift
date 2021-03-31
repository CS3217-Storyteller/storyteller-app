//
//  TransformInfo.swift
//  Storyteller
//
//  Created by TFang on 31/3/21.
//
import CoreGraphics

struct TransformInfo {
    var rotation = CGFloat.zero
    var scale = CGFloat(1)
    var xTranslation = CGFloat.zero
    var yTranslation = CGFloat.zero
}

extension TransformInfo: Codable {

}

extension TransformInfo {
    func scaled(by scale: CGFloat) -> TransformInfo {
        guard scale >= 0 else {
            return self
        }
        var newInfo = self
        newInfo.scale *= scale
        return newInfo
    }

    func rotated(by angle: CGFloat) -> TransformInfo {
        var newInfo = self
        newInfo.rotation += angle
        return newInfo
    }

    func translatedBy(x: CGFloat, y: CGFloat) -> TransformInfo {
        var newInfo = self
        newInfo.xTranslation += x
        newInfo.yTranslation += y
        return newInfo
    }
}
