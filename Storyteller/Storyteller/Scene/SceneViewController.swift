//
//  SceneViewController.swift
//  Storyteller
//
//  Created by John Pan on 21/3/21.
//

import UIKit
import PencilKit

class SceneViewController: UIViewController {

    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var projectTitle: UILabel!

    var projectLabel: ProjectLabel?
    var modelManager: ModelManager?

    func setProjectLabel(to projectLabel: ProjectLabel) {
        self.projectLabel = projectLabel
    }

    func setModelManager(to modelManager: ModelManager) {
        self.modelManager = modelManager
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.hidesBackButton = true

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        self.collectionView.collectionViewLayout = layout
        self.collectionView.backgroundColor = .systemGray
        self.collectionView.register(SceneShotViewCell.self, forCellWithReuseIdentifier: SceneShotViewCell.identifier)
        self.collectionView.register(AddShotViewCell.self, forCellWithReuseIdentifier: AddShotViewCell.identifier)
        self.collectionView.register(
            SceneHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SceneHeaderView.identifier
        )
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.view.addSubview(collectionView)

        if let modelManager = self.modelManager,
           let projectLabel = self.projectLabel,
           let project = modelManager.getProject(of: projectLabel) {
            self.projectTitle.text = project.title
            modelManager.observers.append(self)
        }
    }

    @IBAction private func addScene(_ sender: Any) {
        guard let projectLabel = self.projectLabel,
              let modelManager = self.modelManager else {
            return
        }
        modelManager.addScene(projectLabel: projectLabel)
        self.collectionView.reloadData()
    }

    @IBAction private func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension SceneViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sceneCell = self.collectionView
                .dequeueReusableCell(withReuseIdentifier: SceneShotViewCell.identifier,
                                     for: indexPath) as? SceneShotViewCell,
              let addCell = self.collectionView
                .dequeueReusableCell(withReuseIdentifier: AddShotViewCell.identifier,
                                     for: indexPath) as? AddShotViewCell else {
            return UICollectionViewCell()
        }
        guard let modelManager = self.modelManager,
              let projectLabel = self.projectLabel
        else {
            return UICollectionViewCell()
        }
        let sceneLabel = SceneLabel(projectLabel: projectLabel, sceneIndex: indexPath.section)
        guard let scene = modelManager.getScene(of: sceneLabel) else {
            return UICollectionViewCell()
        }

        if indexPath.row < scene.shots.count {
            let shotLabel = ShotLabel(sceneLabel: sceneLabel, shotIndex: indexPath.row)
            guard let shot = modelManager.getShot(of: shotLabel) else {
                return UICollectionViewCell()
            }
            if !shot.layers.isEmpty {
                // TODO: implement generating thumbnail
                let thumbnail = UIImage()
                sceneCell.setImage(image: thumbnail)
            }
            return sceneCell
        } else {
            return addCell
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let sceneHeader = self.collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: SceneHeaderView.identifier, for: indexPath) as? SceneHeaderView else {
            fatalError("cannot get scene header!")
        }
        sceneHeader.configure(sceneIndex: indexPath.section)
        return sceneHeader

    }
}

extension SceneViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let modelManager = self.modelManager,
              let projectLabel = self.projectLabel
        else {
            return 0
        }
        let sceneLabel = SceneLabel(projectLabel: projectLabel, sceneIndex: section)
        guard let scene = modelManager.getScene(of: sceneLabel) else {
            return 0
        }
        return scene.shots.count + 1
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let projectLabel = self.projectLabel,
              let modelManager = self.modelManager else {
            return 0
        }
        guard let project = modelManager.getProject(of: projectLabel) else {
            return 0
        }
        return project.scenes.count
    }
}

extension SceneViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = (self.view.frame.width / 7) - 7
        let itemHeight = (self.view.frame.width / 7) - 7
        return CGSize(width: itemWidth, height: itemHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        3
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        3
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.collectionView.deselectItem(at: indexPath, animated: true)

        guard let shotDesignerController = self.storyboard?
                .instantiateViewController(identifier: "ShotDesignerViewController")
                as? ShotDesignerViewController else {
            return
        }
        shotDesignerController.modalPresentationStyle = .fullScreen

        guard let modelManager = self.modelManager,
              let projectLabel = self.projectLabel
        else {
            return
        }
        let sceneLabel = SceneLabel(projectLabel: projectLabel, sceneIndex: indexPath.section)
        guard let scene = modelManager.getScene(of: sceneLabel) else {
            return
        }

        let shotLabel = ShotLabel(sceneLabel: sceneLabel, shotIndex: indexPath.row)

        if indexPath.row < scene.shots.count {
            shotDesignerController.setModelManager(to: modelManager)
            shotDesignerController.setShotLabel(to: shotLabel)
            shotDesignerController.modalTransitionStyle = .flipHorizontal
//            self.present(shotDesignerController, animated: true, completion: nil)
            self.navigationController?.pushViewController(shotDesignerController, animated: true)
        } else {
            modelManager.addShot(ofShot: shotLabel, backgroundColor: .white)
            self.collectionView.reloadData()
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: self.view.frame.size.width, height: 50)
    }
}

// MARK: - ModelManagerObserver
extension SceneViewController: ModelManagerObserver {
    func modelDidChanged() {
        collectionView.reloadData()
    }
}
