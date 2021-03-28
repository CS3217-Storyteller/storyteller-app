//
//  Mergable.swift
//  Storyteller
//
//  Created by TFang on 27/3/21.
//

protocol Mergable {
    func merge(with other: Self) -> Self
}
