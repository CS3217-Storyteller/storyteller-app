//
//  UIImage+clearImage.swift
//  Storyteller
//
//  Created by TFang on 31/3/21.
//

import UIKit

extension UIImage {
    static func clearImage(ofSize size: CGSize) -> UIImage {
        let rect = size.rectAtOrigin

        UIGraphicsBeginImageContextWithOptions(size, false, 0)

        UIColor.clear.set()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()!

        UIGraphicsEndImageContext()

        return image
    }
}
