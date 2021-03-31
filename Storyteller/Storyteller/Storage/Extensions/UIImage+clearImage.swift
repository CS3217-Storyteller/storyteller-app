//
//  UIImage+clearImage.swift
//  Storyteller
//
//  Created by TFang on 31/3/21.
//

import UIKit

extension UIImage {
    static func clearImage(ofSize: CGSize) -> UIImage {
        let rect = CGRect(origin: .zero, size: ofSize)

        UIGraphicsBeginImageContextWithOptions(ofSize, false, 0)

        UIColor.clear.set()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()!

        UIGraphicsEndImageContext()

        return image
    }
}
