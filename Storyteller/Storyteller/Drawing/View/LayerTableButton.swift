//
//  LayerTableButton.swift
//  Storyteller
//
//  Created by TFang on 31/3/21.
//

import UIKit

class LayerTableButton: UIBarButtonItem {
    var isChosen = false {
        didSet {
            refreshView()
        }
    }
}

extension LayerTableButton: SelectableView {
    func refreshView() {
        if isChosen {
            tintColor = .orange
        } else {
            tintColor = .systemBlue
        }
    }
}
