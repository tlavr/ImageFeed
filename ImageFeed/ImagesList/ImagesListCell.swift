//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 29.3.2025.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    // MARK: - Public properties
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - IBOutlets
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
}
