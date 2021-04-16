//
//  Transformable.swift
//  Storyteller
//
//  Created by TFang on 31/3/21.
//
import CoreGraphics

protocol Transformable {
    func transformed(using transform: CGAffineTransform) -> Self
    func scaled(by scale: CGFloat) -> Self
    func rotated(by rotation: CGFloat) -> Self
    func translatedBy(x: CGFloat, y: CGFloat) -> Self
}
