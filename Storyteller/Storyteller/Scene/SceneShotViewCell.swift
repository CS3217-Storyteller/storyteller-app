//
//  ShotViewCell.swift
//  Storyteller
//
//  Created by John Pan on 21/3/21.
//

import UIKit

class SceneShotViewCell: UICollectionViewCell {

    static let identifier = "SceneShotViewCell"

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "shot")
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = .white
        self.contentView.addSubview(self.imageView)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func setImage(image: UIImage) {
        self.imageView.image = image
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.frame = contentView.bounds
    }

    override func prepareForReuse() {
        super.prepareForReuse()
//        self.imageView.image = nil
    }
}
