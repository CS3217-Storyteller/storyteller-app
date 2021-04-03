//
//  Transformable.swift
//  Storyteller
//
//  Created by TFang on 31/3/21.
//
import CoreGraphics

protocol Transformable {
    var transformedFrame: CGRect { get }
    var originalFrame: CGRect { get }
    var transform: CGAffineTransform { get }
    func transformed(using transform: CGAffineTransform) -> Self
    func resetTransform() -> Self
}
