//
//  ProjectViewCell.swift
//  Storyteller
//
//  Created by John Pan on 21/3/21.
//

import UIKit

class ProjectViewCell: UICollectionViewCell {
    
    static let identifier = "ProjectViewCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "project")
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.textAlignment = .center
        label.textColor = .black
        label.alpha = 1
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(self.imageView)
    }
    
    func setTitle(to title: String) {
        self.label.frame = CGRect(x: 0, y: 20, width: self.bounds.size.width, height: self.bounds.size.height)        
        self.label.text = title
        self.contentView.addSubview(self.label)
    }
    
    func setTitle(from index: Int) {
        self.setTitle(to: "Project \(index)")
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.frame = self.contentView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
//        self.imageView.image = nil
    }
}
