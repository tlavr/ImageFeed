//
//  ImagesListViewTests.swift
//  Image FeedTests
//
//  Created by Timur Lavrukhin on 8.6.2025.
//

@testable import ImageFeed
import XCTest

final class ImagesListViewTests: XCTestCase {
    // Test photos requested from viewDidLoad and addPhotos called
    func testImagesListViewPhotoRequests() {
        // Given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")
        guard let imagesListVC = imagesListViewController as? ImagesListViewControllerProtocol else {
            XCTFail("Images list view controller creation error!")
            return
        }
        let imagesListViewPresenter = ImagesListViewPresenterMock(view: imagesListVC)
        imagesListVC.presenter = imagesListViewPresenter
        
        // When
        _ = imagesListViewController.view
        
        // Then
        XCTAssertTrue(imagesListViewPresenter.isRequestPhotosCalled)
        XCTAssertFalse(imagesListViewPresenter.isAddPhotosCalled)
    }
    
    //Test photos count and getPhoto
    func testImagesListPresenterPhotosEmpty() {
        // Given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")
        guard let imagesListVC = imagesListViewController as? ImagesListViewControllerProtocol else {
            XCTFail("Images list view controller creation error!")
            return
        }
        let imagesListViewPresenter = ImagesListViewPresenterMock(view: imagesListVC)
        imagesListVC.presenter = imagesListViewPresenter
        
        // Then
        XCTAssertEqual(imagesListVC.presenter?.getPhotosCount(), 0)
        XCTAssertNil(imagesListVC.presenter?.getPhoto(with: 2))
    }
    
    func testImagesListPresenterPhotosAdded() {
        // Given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")
        guard let imagesListVC = imagesListViewController as? ImagesListViewControllerProtocol else {
            XCTFail("Images list view controller creation error!")
            return
        }
        let imagesListViewPresenter = ImagesListViewPresenterMock(view: imagesListVC)
        imagesListVC.presenter = imagesListViewPresenter
        
        // When
        let photo = Photo(id: "test",
                          size: CGSize(width: 100, height: 100),
                          createdAt: Date(),
                          welcomeDescription: "",
                          thumbImageURL: "",
                          largeImageURL: "",
                          isLiked: false)
        imagesListViewPresenter.photos.append(photo)
        imagesListViewPresenter.photos.append(photo)
        imagesListViewPresenter.photos.append(photo)
        imagesListViewPresenter.photos.append(photo)
        
        // Then
        XCTAssertEqual(imagesListVC.presenter?.getPhotosCount(), 4)
        XCTAssertEqual(imagesListVC.presenter?.getPhoto(with: 3)?.id, "test")
        XCTAssertNil(imagesListVC.presenter?.getPhoto(with: 4))
    }
    
    // Test congig cell call and related updates (cell date, cell like active, cell image)
    func testImagesListViewCellConfig() {
        // Given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")
        guard let imagesListVC = imagesListViewController as? ImagesListViewControllerProtocol else {
            XCTFail("Images list view controller creation error!")
            return
        }
        let imagesListViewPresenter = ImagesListViewPresenterMock(view: imagesListVC, dateIsEmpty: false, isLiked: true)
        imagesListVC.presenter = imagesListViewPresenter
        
        // When
        let photo = Photo(id: "test",
                          size: CGSize(width: 100, height: 100),
                          createdAt: Date(),
                          welcomeDescription: "",
                          thumbImageURL: "",
                          largeImageURL: "",
                          isLiked: false)
        imagesListViewPresenter.photos.append(photo)
        imagesListViewPresenter.photos.append(photo)
        let cell = ImagesListCell()
        cell.cellImage = UIImageView()
        cell.likeButton = UIButton()
        cell.dateLabel = UILabel()
        imagesListVC.presenter?.configureCell(for: cell, with: IndexPath(row: 0, section: 0))
        
        // Then
        XCTAssertEqual(cell.cellImage?.image, UIImage(named: "ImageStub"))
        XCTAssertEqual(cell.likeButton.imageView?.image, UIImage(named: "LikeActive"))
        XCTAssertEqual(cell.dateLabel.text, "Today")
    }
    
}
