//
//  Transformable.swift
//  Storyteller
//
//  Created by TFang on 31/3/21.
//
import CoreGraphics

protocol Transformable {
    var transform: CGAffineTransform { get }
    func updateTransform(_ transform: CGAffineTransform) -> Self
}

extension Transformable {
    func scaled(by scale: CGFloat) -> Self {
        updateTransform(transform.scaledBy(x: scale, y: scale))
    }
    func rotated(by rotation: CGFloat) -> Self {
        updateTransform(transform.rotated(by: rotation))
    }
    func translatedBy(x: CGFloat, y: CGFloat) -> Self {
        updateTransform(transform.concatenating(CGAffineTransform(translationX: x, y: y)))
    }
    func resetTransform() -> Self {
        updateTransform(.identity)
    }
}
