//
//  SceneHeaderView.swift
//  Storyteller
//
//  Created by John Pan on 21/3/21.
//

import UIKit

class SceneHeader: UICollectionReusableView {
    
    static let identifier = "SceneHeaderView"
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    public func configure(sceneIndex: Int) {
        self.backgroundColor = .black
        self.label.text = "Scene \(sceneIndex)"
        self.addSubview(self.label)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.label.frame = self.bounds
    }
    
}
