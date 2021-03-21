//
//  LayerType.swift
//  Storyteller
//
//  Created by TFang on 20/3/21.
//
enum LayerType: String {
    case drawing
    case image
}

// MARK: Hashable
extension LayerType: Hashable {
}

// MARK: Codable
extension LayerType: Codable {
}
