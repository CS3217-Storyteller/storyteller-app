//
//  Alert.swift
//  Storyteller
//
//  Created by TFang on 2/4/21.
//

import UIKit

class Alert {
    static func presentAtLeastOneLayerAlert(controller: UIViewController) {
        presentAlert(controller: controller,
                     title: Constants.errorTitle, message: Constants.atLeastOneLayerMessage)
    }
    
    private static func presentAlert(controller: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Constants.okTitle, style: .default, handler: nil))
        controller.present(alert, animated: true)
    }
}
