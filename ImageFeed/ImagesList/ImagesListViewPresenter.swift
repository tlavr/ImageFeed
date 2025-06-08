//
//  ImageListViewPresenter.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 8.6.2025.
//

import Foundation
import Kingfisher

final class ImagesListViewPresenter: @preconcurrency ImagesListViewPresenterProtocol {
    // MARK: -Public properties
    weak var view: ImagesListViewControllerProtocol?
    
    // MARK: -Private properies
    private let imagesList = ImagesListService.shared
    private var photos: [Photo] = []
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    } ()
    
    // MARK: -Public methods
    init(view: ImagesListViewControllerProtocol) {
        self.view = view
    }
    
    func getPhoto(with index: Int) -> Photo? {
        if index < photos.count {
            return self.photos[index]
        } else {
            return nil
        }
    }
    
    func getPhotosCount() -> Int {
        photos.count
    }
    
    func addPhotos() {
        let oldPhotosCount = photos.count
        photos = imagesList.photos
        let newPhotosCount = photos.count
        var indexPaths: [IndexPath] = []
        (oldPhotosCount..<newPhotosCount).forEach {
            indexPaths.append(IndexPath(row: $0, section: 0))
        }
        view?.updateTableRows(for: indexPaths)
    }
    
    @MainActor
    func configureCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let thumbImageStr = photos[indexPath.row].thumbImageURL
        guard let thumbImageUrl = URL(string: thumbImageStr) else {
            ErrorLoggingService.shared.log(
                from: String(describing: self),
                with: .UrlSession,
                error: CommonErrors.url
            )
            return
        }
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(with: thumbImageUrl,
                                   placeholder: view?.imageStub,
                                   options: []) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let value):
                self.view?.setCellImage(for: cell, with: value.image)
                self.view?.reloadTableRows(at: indexPath)
            case .failure(let error):
                ErrorLoggingService.shared.log(
                    from: String(describing: self),
                    with: .Network,
                    error: error
                )
            }
        }
        
        if let imageDate = photos[indexPath.row].createdAt {
            view?.setCellDate(for: cell, with: dateFormatter.string(from: imageDate))
        } else {
            view?.setCellDate(for: cell, with: "")
        }
        
        if photos[indexPath.row].isLiked {
            view?.setCellLikeActive(for: cell)
        } else {
            view?.setCellLikeInactive(for: cell)
        }
    }
    
    func requestPhotos() {
        imagesList.fetchPhotosNextPage() { [weak self] result in
            guard let self else { return }
            switch result {
            case .success():
                break
            case .failure(let error):
                ErrorLoggingService.shared.log(
                    from: String(describing: self),
                    with: .UrlSession,
                    error: error
                )
            }
        }
    }
    
    func checkIfNewPhotosNeeded(for index: Int) {
        if index == photos.count - 1 {
            requestPhotos()
        }
    }
    
    func changeLike(for cell: ImagesListCell, with index: Int) {
        let photo = photos[index]
        view?.showProgressHUD()
        imagesList.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                if let index = self.photos.firstIndex(where: { $0.id == photo.id }) {
                    self.photos[index].isLiked = !self.photos[index].isLiked
                }
                cell.setIsLiked(self.photos[index].isLiked)
                self.view?.hideProgressHUD()
            case .failure:
                self.view?.hideProgressHUD()
                self.view?.showErrorAlert()
            }
        }
    }
}
