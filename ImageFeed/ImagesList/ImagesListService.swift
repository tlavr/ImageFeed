//
//  ImageListService.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 29.5.2025.
//

import UIKit

final class ImagesListService {
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private(set) var photos: [Photo] = []
    
    private var lastLoadedPage: Int? = .zero
    private var task: URLSessionTask?
    private let formatter = ISO8601DateFormatter()
    
    func fetchPhotosNextPage(completion: @escaping (Result<[PhotoResult], Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
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
                completion(.success(photos))
            case .failure(let error):
                completion(.failure(error))
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
    
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
            URLQueryItem(name: "per_page", value: String(ImageListServiceConstants.photosPerPage)),
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
        //        request.setValue( "Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func getPhoto(from result: PhotoResult) -> Photo {
        let photo = Photo(
            id: result.id,
            size: CGSize(width: result.width, height: result.height),
            createdAt: formatter.date(from: result.createdAt),
            welcomeDescription: result.description,
            thumbImageURL: result.urls.thumb,
            largeImageURL: result.urls.full,
            isLiked: result.likedByUser
        )
        return photo
    }
}
