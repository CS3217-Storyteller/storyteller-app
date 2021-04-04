//
//  SceneViewController.swift
//  Storyteller
//
//  Created by John Pan on 21/3/21.
//

import UIKit

class SceneViewController: UIViewController {

    @IBOutlet private var collectionView: UICollectionView!

    var projectLabel: ProjectLabel?
    var modelManager: ModelManager?

    lazy var addSceneBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(
            title: "Add Scene",
            style: .plain,
            target: self,
            action: #selector(didAddSceneButtonClicked(_:))
        )
        return barButtonItem
    }()
    
    func setProjectLabel(to projectLabel: ProjectLabel) {
        self.projectLabel = projectLabel
    }

    func setModelManager(to modelManager: ModelManager) {
        self.modelManager = modelManager
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        self.collectionView.collectionViewLayout = layout
        self.collectionView.backgroundColor = .systemGray
        self.collectionView.register(SceneShotViewCell.self, forCellWithReuseIdentifier: SceneShotViewCell.identifier)
        self.collectionView.register(AddShotViewCell.self, forCellWithReuseIdentifier: AddShotViewCell.identifier)
        self.collectionView.register(
            SceneHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SceneHeaderView.identifier
        )
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.view.addSubview(collectionView)

        guard let modelManager = self.modelManager,
              let projectLabel = self.projectLabel,
              let project = modelManager.getProject(of: projectLabel) else {
            return
        }
        
        modelManager.observers.append(self)
        self.navigationItem.title = project.title
        self.navigationItem.rightBarButtonItem = self.addSceneBarButton
    }

    @objc func didAddSceneButtonClicked(_ sender: Any) {
        guard let projectLabel = self.projectLabel,
              let modelManager = self.modelManager else {
            return
        }
        modelManager.addScene(projectLabel: projectLabel)
        self.collectionView.reloadData()
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
        
        let sceneLabel = projectLabel.generateSceneLabel(withId: UUID()) // TODO: pass proper id!
        // let sceneLabel = SceneLabel(projectLabel: projectLabel, sceneIndex: indexPath.section)
        guard let scene = modelManager.getScene(of: sceneLabel) else {
            return UICollectionViewCell()
        }

        if indexPath.row < scene.shots.count {
            let shotLabel = sceneLabel.generateShotLabel(withId: UUID()) // TODO: pass proper id!
            // let shotLabel = ShotLabel(sceneLabel: sceneLabel, shotIndex: indexPath.row)
            guard let shot = modelManager.getShot(of: shotLabel) else {
                return UICollectionViewCell()
            }
            if !shot.layers.isEmpty {
                let thumbnail = shot.orderedLayers[0].drawing
                    .image(from: CGRect(x: 0, y: 0,
                                        width: Constants.screenWidth,
                                        height: Constants.screenHeight), scale: 1.0)
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
        let sceneLabel = projectLabel.generateSceneLabel(withId: UUID()) // TODO: pass in proper ID
        // let sceneLabel = SceneLabel(projectLabel: projectLabel, sceneIndex: indexPath.section)
        guard let scene = modelManager.getScene(of: sceneLabel) else {
            return
        }

        let shotLabel = sceneLabel.generateShotLabel(withId: UUID()) // TODO: pass in proper ID

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
}

extension SceneViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let modelManager = self.modelManager,
              let projectLabel = self.projectLabel
        else {
            return 0
        }
        let sceneLabel = projectLabel.generateSceneLabel(withId: UUID()) // TODO: pass in correct ID
        // let sceneLabel = SceneLabel(projectLabel: projectLabel, sceneIndex: section)
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
        let itemWidth = (self.view.frame.width / 10) - 8
        let itemHeight = (self.view.frame.width / 10) - 8
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
