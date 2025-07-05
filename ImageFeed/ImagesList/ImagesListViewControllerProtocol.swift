//
//  ImagesListViewControllerProtocol.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 8.6.2025.
//

import UIKit

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListViewPresenterProtocol? { get set }
    var imageStub: UIImage? { get set }
    func reloadTableRows(at: IndexPath)
    func updateTableRows(for indexPaths: [IndexPath])
    func setCellDate(for cell: ImagesListCell, with text: String)
    func setCellLikeActive(for cell: ImagesListCell)
    func setCellLikeInactive(for cell: ImagesListCell)
    func setCellImage(for cell: ImagesListCell, with image: UIImage)
    func showProgressHUD()
    func hideProgressHUD()
    func showErrorAlert()
}
