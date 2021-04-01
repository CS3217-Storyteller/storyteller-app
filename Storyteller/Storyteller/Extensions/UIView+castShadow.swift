//
//  UIView+castShadow.swift
//  Storyteller
//
//  Created by TFang on 1/4/21.
//

import UIKit

extension UIView {
    func castShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = .zero
        layer.shadowRadius = 10
    }
    func disableShadow() {
        layer.shadowOpacity = 0
    }
}
