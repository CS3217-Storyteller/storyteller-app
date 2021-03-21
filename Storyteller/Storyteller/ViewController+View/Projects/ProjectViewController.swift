//
//  ViewController.swift
//  Storyteller
//
//  Created by John Pan on 16/3/21.
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
        self.collectionView.register(ProjectCell.self, forCellWithReuseIdentifier: ProjectCell.identifier)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self        
        self.view.addSubview(collectionView)
    }
    
//    override func viewDidLayoutSubviews() {
//        self.collectionView.frame = self.view.bounds
//    }

}

extension ProjectViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: ProjectCell.identifier, for: indexPath)
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
        
        let sceneStoryBoard = UIStoryboard(name: "Scene", bundle: Bundle.main)
        guard let sceneViewController = sceneStoryBoard.instantiateViewController(identifier: "SceneViewController") as? SceneViewController else {
            return
        }
        self.present(sceneViewController, animated: true, completion: nil)
    }
    
}

//        let layout = UICollectionViewFlowLayout()
//        layout.itemSize = CGSize(width: 120, height: 120)
//        collectionView.collectionViewLayout = layout
//
//        collectionView.register(ProjectCell.nib(), forCellWithReuseIdentifier: ProjectCell.identifier)
//
//        collectionView.delegate = self
////        collectionView.dataSource = self
//    }
//}
//}
//
//extension ProjectViewController: UICollectionViewDelegate {
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        collectionView.deselectItem(at: indexPath, animated: true)
//        print("Tapped")
//    }
//
//}
//
//extension ProjectViewController: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 12
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProjectCell.identifier, for: indexPath) as! ProjectCell
//        cell.configure(with: UIImage(named: "image")!)
//        return cell
//    }
//}
//
//extension ProjectViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 120, height: <#T##CGFloat#>)
//    }
//}

