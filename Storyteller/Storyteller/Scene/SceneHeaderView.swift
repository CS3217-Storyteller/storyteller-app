//
//  SceneHeaderView.swift
//  Storyteller
//
//  Created by John Pan on 21/3/21.
//

import UIKit

class SceneHeaderView: UICollectionReusableView {
    static let identifier = "SceneHeaderView"

    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.textAlignment = .left
        label.textColor = .black
        return label
    }()

    func configure(sceneIndex: Int) {
        self.backgroundColor = .gray
        self.label.text = "  Scene \(sceneIndex)"
        self.addSubview(self.label)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.label.frame = self.bounds
    }

}
