//
//  ImageListService.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 29.5.2025.
//

import UIKit

final class ImagesListService {
    // MARK: -Public properties
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    // MARK: -Private properies
    private(set) var photos: [Photo] = []
    private var tokenStorage = OAuth2TokenStorage()
    private var lastLoadedPage: Int? = .zero
    private var photosRequestTask: URLSessionTask?
    private var likeChangeTask: URLSessionTask?
    private var lastLikePhotoId: String?
    private let formatter = ISO8601DateFormatter()
    
    // MARK: -Public methods
    func reset() {
        photos = []
        lastLoadedPage = .zero
        photosRequestTask = nil
        likeChangeTask = nil
        lastLikePhotoId = nil
    }
    
    func fetchPhotosNextPage(completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        photosRequestTask?.cancel()
        let nextPage = (lastLoadedPage ?? 0) + 1
        guard let URLRequest = generatePhotosRequest(pageNumber: nextPage) else {
            completion(.failure(CommonErrors.invalidUrlRequest))
            return
        }
        let task = URLSession.shared.objectTask(for: URLRequest) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let photos):
                photos.forEach { self.photos.append(self.getPhoto(from: $0)) }
                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self,
                    userInfo: ["Photos": self.photos]
                )
                self.lastLoadedPage = nextPage
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
            self.photosRequestTask = nil
        }
        self.photosRequestTask = task
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard lastLikePhotoId != photoId else {
            completion(.failure(CommonErrors.repeatedRequest))
            return
        }
        photosRequestTask?.cancel()
        lastLikePhotoId = photoId
        
        guard let URLRequest = generateLikeChangeRequest(for: photoId, with: isLike) else {
            completion(.failure(CommonErrors.invalidUrlRequest))
            return
        }
        let task = URLSession.shared.objectTask(for: URLRequest) { [weak self] (result: Result<LikeResult, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(_):
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
            self.likeChangeTask = nil
            self.lastLikePhotoId = nil
        }
        self.likeChangeTask = task
        task.resume()
    }
    
    // MARK: -Private methods
    private init() {}
    
    private func generatePhotosRequest(pageNumber: Int) -> URLRequest? {
        guard var urlComponents = URLComponents(url: Constants.defaultBaseURL, resolvingAgainstBaseURL: true) else {
            ErrorLoggingService.shared.log(
                from: String(describing: self),
                with: .UrlSession,
                error: CommonErrors.urlComponent
            )
            return nil
        }
        urlComponents.path = "/photos"
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: String(pageNumber)),
            URLQueryItem(name: "per_page", value: String(ImagesListConstants.photosPerPage)),
        ]
        guard let url = urlComponents.url else {
            ErrorLoggingService.shared.log(
                from: String(describing: self),
                with: .UrlSession,
                error: CommonErrors.url
            )
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        guard let token = tokenStorage.token else {
            ErrorLoggingService.shared.log(
                from: String(describing: self),
                with: .Database,
                error: CommonErrors.tokenStorage
            )
            return nil
        }
        request.setValue( "Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func generateLikeChangeRequest(for photoId: String, with isLike: Bool) -> URLRequest? {
        guard var urlComponents = URLComponents(url: Constants.defaultBaseURL, resolvingAgainstBaseURL: true) else {
            ErrorLoggingService.shared.log(
                from: String(describing: self),
                with: .UrlSession,
                error: CommonErrors.urlComponent
            )
            return nil
        }
        urlComponents.path = "/photos/\(photoId)/like"
        guard let url = urlComponents.url else {
            ErrorLoggingService.shared.log(
                from: String(describing: self),
                with: .UrlSession,
                error: CommonErrors.url
            )
            return nil
        }
        
        var request = URLRequest(url: url)
        if isLike {
            request.httpMethod = "POST"
        } else {
            request.httpMethod = "DELETE"
        }
        guard let token = tokenStorage.token else {
            ErrorLoggingService.shared.log(
                from: String(describing: self),
                with: .Database,
                error: CommonErrors.tokenStorage
            )
            return nil
        }
        request.setValue( "Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func getPhoto(from result: PhotoResult) -> Photo {
        let photo = Photo(
            id: result.id,
            size: CGSize(width: result.width, height: result.height),
            createdAt: formatter.date(from: result.createdAt),
            welcomeDescription: result.description,
            thumbImageURL: result.urls.regular,
            largeImageURL: result.urls.raw,
            isLiked: result.likedByUser
        )
        return photo
    }
}
