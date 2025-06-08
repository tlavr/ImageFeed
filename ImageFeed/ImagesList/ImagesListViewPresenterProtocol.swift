//
//  ImagesListViewPresenterProtocol.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 8.6.2025.
//

import Foundation

protocol ImagesListViewPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    func getPhoto(with index: Int) -> Photo?
    func configureCell(for cell: ImagesListCell, with indexPath: IndexPath)
    func addPhotos()
    func requestPhotos()
    func checkIfNewPhotosNeeded(for index: Int)
    func getPhotosCount() -> Int
    func changeLike(for cell:ImagesListCell, with index: Int)
}
