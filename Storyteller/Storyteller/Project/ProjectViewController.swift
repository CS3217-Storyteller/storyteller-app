//
//  ProjectViewController.swift
//  Storyteller
//
//  Created by John Pan on 21/3/21.
//

import UIKit

class ProjectViewController: UIViewController {

    
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = UICollectionViewFlowLayout()
                layout.scrollDirection = .vertical
                self.collectionView.collectionViewLayout = layout
                self.collectionView.backgroundColor = .systemGray
                self.collectionView.register(ProjectViewCell.self, forCellWithReuseIdentifier: ProjectViewCell.identifier)
                self.collectionView.delegate = self
                self.collectionView.dataSource = self
                self.view.addSubview(collectionView)
    }
}

extension ProjectViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: ProjectViewCell.identifier, for: indexPath)
        return cell
    }
}

    
extension ProjectViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30
    }
}

extension ProjectViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = (self.view.frame.width / 3) - 3
        let itemHeight = (self.view.frame.width / 3) - 3
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.collectionView.deselectItem(at: indexPath, animated: true)
        print(indexPath.row)
        guard let sceneViewController = self.storyboard?.instantiateViewController(identifier: "SceneViewController") as? SceneViewController else {
            return
        }
        sceneViewController.modalPresentationStyle = .fullScreen

        navigationController?.pushViewController(sceneViewController, animated: true)
    }
    
}

