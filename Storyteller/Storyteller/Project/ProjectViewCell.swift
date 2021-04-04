//
//  ProjectViewCell.swift
//  Storyteller
//
//  Created by John Pan on 21/3/21.
//

import UIKit

class ProjectViewCell: UICollectionViewCell {

    static let identifier = "ProjectViewCell"

    let imageView: UIImageView = UIImageView()
    
    let label: UILabel = UILabel()
    
    let highlightView: UIView = UIView()

    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                self.highlightView.frame = self.bounds
                self.highlightView.backgroundColor = .white
                self.highlightView.alpha = 0.5
                self.contentView.addSubview(self.highlightView)
            } else {
                self.highlightView.removeFromSuperview()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.clipsToBounds = true
        self.imageView.image = UIImage(named: "project")
        
        self.label.font = UIFont.systemFont(ofSize: 30)
        self.label.textAlignment = .center
        self.label.textColor = .black
        self.label.alpha = 1
        self.label.frame = CGRect(x: 0, y: 20, width: self.bounds.size.width,
                                  height: self.bounds.size.height)
        
        self.contentView.addSubview(self.label)
        self.contentView.addSubview(self.imageView)
    }

    func setTitle(to title: String) {
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
    }
}
