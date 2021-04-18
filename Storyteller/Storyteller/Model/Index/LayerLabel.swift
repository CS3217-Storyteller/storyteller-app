//
//  LayerLabel.swift
//  Storyteller
//
//  Created by mmarcus on 27/3/21.
//
//
// import Foundation
//
// struct LayerLabel: Codable {
//    var projectId: UUID
//    var sceneId: UUID
//    var shotId: UUID
//    var layerId: UUID
//
//    var sceneLabel: SceneLabel {
//        SceneLabel(projectId: projectId, sceneId: sceneId)
//    }
//
//    var projectLabel: ProjectLabel {
//        ProjectLabel(projectId: projectId)
//    }
//
//    var shotLabel: ShotLabel {
//        ShotLabel(projectId: projectId, sceneId: sceneId, shotId: shotId)
//    }
//
//    func withProjectId(_ newProjectId: UUID) -> Self {
//        Self(projectId: newProjectId,
//             sceneId: sceneId,
//             shotId: shotId,
//             layerId: layerId)
//    }
//
//    func withSceneId(_ newSceneId: UUID) -> Self {
//        Self(projectId: projectId,
//             sceneId: newSceneId,
//             shotId: shotId,
//             layerId: layerId)
//    }
//
//    func withShotId(_ newShotId: UUID) -> Self {
//        Self(projectId: projectId,
//             sceneId: sceneId,
//             shotId: newShotId,
//             layerId: layerId)
//    }
//
//    func withLayerId(_ newLayerId: UUID) -> Self {
//        Self(projectId: projectId,
//             sceneId: sceneId,
//             shotId: shotId,
//             layerId: newLayerId)
//    }
// }
