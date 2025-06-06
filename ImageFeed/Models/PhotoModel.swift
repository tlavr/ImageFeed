//
//  PhotoModel.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 29.5.2025.
//

import UIKit

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
}
