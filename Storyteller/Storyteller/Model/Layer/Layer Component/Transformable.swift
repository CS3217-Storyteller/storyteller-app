//
//  Transformable.swift
//  Storyteller
//
//  Created by TFang on 31/3/21.
//
import CoreGraphics

protocol Transformable {
    var frame: CGRect { get }
    var anchorPoint: CGPoint { get }
    var transformInfo: TransformInfo { get }
    func updateTransformInfo(info: TransformInfo) -> Self
}

extension Transformable {
    func scaled(by scale: CGFloat) -> Self {
        let newInfo = transformInfo.scaled(by: scale)
        return updateTransformInfo(info: newInfo)
    }

    func rotated(by angle: CGFloat) -> Self {
        let newInfo = transformInfo.rotated(by: angle)
        return updateTransformInfo(info: newInfo)
    }

    func translatedBy(x: CGFloat, y: CGFloat) -> Self {
        let newInfo = transformInfo.translatedBy(x: x, y: y)
        return updateTransformInfo(info: newInfo)
    }

    func resetTransform() -> Self {
        updateTransformInfo(info: TransformInfo())
    }
}
