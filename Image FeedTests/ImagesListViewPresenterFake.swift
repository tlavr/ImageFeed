//
//  ImagesListViewPresenterFake.swift
//  Image FeedTests
//
//  Created by Timur Lavrukhin on 8.6.2025.
//

@testable import ImageFeed
import UIKit

final class ImagesListViewPresenterFake: ImagesListViewPresenterProtocol {
    // MARK: -Public properties
    weak var view: ImagesListViewControllerProtocol?
    var isAddPhotosCalled = false
    var isRequestPhotosCalled = false
    var dateIsEmpty = true
    var isLiked = false
    var photos: [Photo] = []
    
    // MARK: -Private properies
    private let imagesList = ImagesListService.shared
    
    // MARK: -Public methods
    init(view: ImagesListViewControllerProtocol, dateIsEmpty: Bool = true, isLiked: Bool = false) {
        self.view = view
        self.dateIsEmpty = dateIsEmpty
        self.isLiked = isLiked
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
        isAddPhotosCalled = true
    }
    
    func configureCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let image = UIImage(named: "ImageStub") else { return }
        self.view?.setCellImage(for: cell, with: image)
        if !dateIsEmpty {
            view?.setCellDate(for: cell, with: "Today")
        } else {
            view?.setCellDate(for: cell, with: "")
        }
        
        if isLiked {
            view?.setCellLikeActive(for: cell)
        } else {
            view?.setCellLikeInactive(for: cell)
        }
    }
    
    func requestPhotos() {
        isRequestPhotosCalled = true
    }
    
    func checkIfNewPhotosNeeded(for index: Int) { }
    
    func changeLike(for cell: ImagesListCell, with index: Int) {
        isLiked = !isLiked
    }
}
