//
//  ImagesListCellDelegateProtocol.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 1.6.2025.
//

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}
