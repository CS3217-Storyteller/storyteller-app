//
//  TransformInfo+transform.swift
//  Storyteller
//
//  Created by TFang on 1/4/21.
//
import CoreGraphics

extension TransformInfo {
    var transform: CGAffineTransform {
        CGAffineTransform(translationX: xTranslation, y: yTranslation)
            .rotated(by: rotation)
            .scaledBy(x: scale, y: scale)
    }
}
