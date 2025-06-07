//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 29.3.2025.
//

import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    // MARK: - IBOutlets
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    
    // MARK: - Public properties
    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: ImagesListCellDelegate?
    
    // MARK: -IBActions
    @IBAction private func likeButtonClicked() {
       delegate?.imageListCellDidTapLike(self)
    }
    
    // MARK: -Public methods
    func setIsLiked(_ isLiked: Bool) {
        likeButton.setImage(isLiked ? UIImage(named: "LikeActive") : UIImage(named: "LikeNotActive"), for: .normal)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
    }
}
