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
        label.text = "Scene Title"
        label.font = UIFont.systemFont(ofSize: 30)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    public func configure() {
        self.backgroundColor = .black
        self.addSubview(label)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.label.frame = self.bounds
    }
    
}
