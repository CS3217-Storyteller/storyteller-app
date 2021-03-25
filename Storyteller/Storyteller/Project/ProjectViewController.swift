//
//  ProjectViewController.swift
//  Storyteller
//
//  Created by John Pan on 21/3/21.
//

import UIKit

class ProjectViewController: UIViewController {

    @IBOutlet private var collectionView: UICollectionView!

    private var modelManager = ModelManager()

    private var NumOfProjects: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        modelManager.observers.append(self)

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        self.collectionView.collectionViewLayout = layout
        self.collectionView.backgroundColor = .systemGray
        self.collectionView.register(ProjectViewCell.self, forCellWithReuseIdentifier: ProjectViewCell.identifier)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.view.addSubview(collectionView)
        self.NumOfProjects = self.modelManager.projects.count
    }

    @IBAction private func addProject(_ sender: UIButton) {
        let canvasSize = Constants.defaultCanvasSize
        let projectTitle = "Project \(self.NumOfProjects)"
        self.modelManager.addProject(canvasSize: canvasSize, title: projectTitle)
        self.NumOfProjects += 1
        self.collectionView.reloadData()
    }
}

extension ProjectViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let projectViewCell = self.collectionView
                .dequeueReusableCell(withReuseIdentifier: ProjectViewCell.identifier,
                                     for: indexPath) as? ProjectViewCell else {
            return UICollectionViewCell()
        }
        projectViewCell.setTitle(from: indexPath.row)
        return projectViewCell
    }
}

extension ProjectViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.modelManager.projects.count
    }
}

extension ProjectViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = (self.view.frame.width / 5) - 5
        let itemHeight = (self.view.frame.width / 5) - 5
        return CGSize(width: itemWidth, height: itemHeight)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        3
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        3
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.collectionView.deselectItem(at: indexPath, animated: true)
        guard let sceneViewController = self.storyboard?
                .instantiateViewController(identifier: "SceneViewController") as? SceneViewController else {
            return
        }
        sceneViewController.modalPresentationStyle = .fullScreen
        let projectLabel = ProjectLabel(projectIndex: indexPath.row)
        sceneViewController.setProjectLabel(to: projectLabel)
        sceneViewController.setModelManager(to: self.modelManager)
//        self.present(sceneViewController, animated: true, completion: nil)
        self.navigationController?.pushViewController(sceneViewController, animated: true)
    }

}

// MARK: - ModelManagerObserver
extension ProjectViewController: ModelManagerObserver {
    func modelDidChanged() {
        collectionView.reloadData()
    }
}
