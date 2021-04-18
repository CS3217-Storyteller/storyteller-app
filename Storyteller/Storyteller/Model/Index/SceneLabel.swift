//
//  SceneLabel.swift
//  Storyteller
//
//  Created by TFang on 20/3/21.
//
// import Foundation
//
// struct SceneLabel: Codable {
//    var projectId: UUID
//    var sceneId: UUID
//
//    var projectLabel: ProjectLabel {
//        ProjectLabel(projectId: projectId)
//    }
//
//    func generateShotLabel(withId shotId: UUID) -> ShotLabel {
//        ShotLabel(projectId: projectId, sceneId: sceneId, shotId: shotId)
//    }
//
//    func withProjectId(_ newProjectId: UUID) -> Self {
//        Self(projectId: newProjectId,
//             sceneId: sceneId)
//    }
//
//    func withSceneId(_ newSceneId: UUID) -> Self {
//        Self(projectId: projectId,
//             sceneId: newSceneId)
//    }
// }
