//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 24.5.2025.
//
import UIKit

final class ProfileImageService {
    // MARK: - Public properties
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    //MARK: -Private properties
    private let tokenStorage = OAuth2TokenStorage()
    private(set) var avatarURL: String?
    private var task: URLSessionTask?
    private var lastUsername: String?
    
    //MARK: -Public methods
    func reset() {
        avatarURL = nil
        task = nil
        lastUsername = nil
    }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastUsername != username else {
            completion(.failure(CommonErrors.repeatedRequest))
            return
        }
        task?.cancel()
        lastUsername = username
        
        guard let URLRequest = generateProfileImageRequest(username) else {
            completion(.failure(CommonErrors.invalidUrlRequest))
            return
        }
        
        let task = URLSession.shared.objectTask(for: URLRequest) { [weak self] (result: Result<ProfileImageModel, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let profileImageData):
                self.avatarURL = profileImageData.profileImage.small
                completion(.success(profileImageData.profileImage.small))
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": self.avatarURL ?? ""]
                )
            case .failure(let error):
                completion(.failure(error))
            }
            self.task = nil
            self.lastUsername = nil
        }
        self.task = task
        task.resume()
    }
    
    //MARK: -Private methods
    private init() {}
    
    private func generateProfileImageRequest(_ username: String) -> URLRequest? {
        guard let token = tokenStorage.token else {
            ErrorLoggingService.shared.log(
                from: String(describing: self),
                with: .Database,
                error: CommonErrors.tokenStorage
            )
            return nil
        }
        guard var urlComponents = URLComponents(url: Constants.defaultBaseURL, resolvingAgainstBaseURL: true) else {
            ErrorLoggingService.shared.log(
                from: String(describing: self),
                with: .UrlSession,
                error: CommonErrors.urlComponent
            )
            return nil
        }
        urlComponents.path = "/users/\(username)"
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
        request.setValue( "Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
