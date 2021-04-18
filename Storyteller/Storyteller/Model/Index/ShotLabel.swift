//
//  ShotLabel.swift
//  Storyteller
//
//  Created by TFang on 20/3/21.
//
// import Foundation
//
// struct ShotLabel: Codable {
//    var projectId: UUID
//    var sceneId: UUID
//    var shotId: UUID
//
//    var sceneLabel: SceneLabel {
//        SceneLabel(projectId: projectId, sceneId: sceneId)
//    }
//
//    var projectLabel: ProjectLabel {
//        ProjectLabel(projectId: projectId)
//    }
//
//    func generateLayerLabel(withId layerId: UUID) -> LayerLabel {
//        LayerLabel(projectId: projectId, sceneId: sceneId, shotId: shotId, layerId: layerId)
//    }
//
//    func withProjectId(_ newProjectId: UUID) -> Self {
//        Self(projectId: newProjectId,
//             sceneId: sceneId,
//             shotId: shotId)
//    }
//
//    func withSceneId(_ newSceneId: UUID) -> Self {
//        Self(projectId: projectId,
//             sceneId: newSceneId,
//             shotId: shotId)
//    }
//
//    func withShotId(_ newShotId: UUID) -> Self {
//        Self(projectId: projectId,
//             sceneId: sceneId,
//             shotId: newShotId)
//    }
// }
//
// extension ShotLabel {
//    var nextLabel: ShotLabel {
//        ShotLabel(projectId: projectId, sceneId: sceneId, shotId: UUID())
//    }
// }
