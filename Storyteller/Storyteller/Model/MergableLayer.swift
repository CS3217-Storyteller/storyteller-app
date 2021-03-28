//
//  MergableLayer.swift
//  Storyteller
//
//  Created by TFang on 27/3/21.
//

import UIKit

final class MergableLayer: Mergable {

    var view: UIView

    init(view: UIView) {
        self.view = view
    }

    func merge(with other: MergableLayer) -> MergableLayer {
        other.view.addSubview(view)
        other.view.bringSubviewToFront(view)
        return other
    }
}
