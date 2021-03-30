//
//  TransformInfo.swift
//  Storyteller
//
//  Created by TFang on 31/3/21.
//
import CoreGraphics

struct TransformInfo {
    var rotation = CGFloat.zero
    var scale = CGFloat.zero
    var xTranslation = CGFloat.zero
    var yTranslation = CGFloat.zero
}

extension TransformInfo: Codable {

}

extension TransformInfo {
    mutating func scaled(by scale: CGFloat) {
        guard scale >= 0 else {
            return
        }
        self.scale *= scale
    }

    mutating func rotated(by angle: CGFloat) {
        self.rotation += angle
    }

    mutating func translatedBy(x: CGFloat, y: CGFloat) {
        self.xTranslation += x
        self.yTranslation += y
    }
}
