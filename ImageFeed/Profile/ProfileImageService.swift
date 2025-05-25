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
    private enum ProfileImageServiceError: Error {
        case repeatedRequest
        case invalidUrlRequest
    }
    private enum JsonError: Error {
        case decoderError
    }
    //MARK: -Public methods
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastUsername != username else {
            completion(.failure(ProfileImageServiceError.repeatedRequest))
            return
        }
        task?.cancel()
        lastUsername = username
        
        guard
            let URLRequest = generateProfileImageRequest(username)
        else
        {
            completion(.failure(ProfileImageServiceError.invalidUrlRequest))
            return
        }
        
        let task = URLSession.shared.data(for: URLRequest) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                do {
                    let profileImageData = try JSONDecoder().decode(UserResult.self, from: data)
                    self.avatarURL = profileImageData.profileImage.small
                    completion(.success(profileImageData.profileImage.small))
                    NotificationCenter.default.post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": self.avatarURL ?? ""]
                    )
                } catch {
                    completion(.failure(JsonError.decoderError))
                }
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
            assertionFailure("Token reading from Storage failed")
            return nil
        }
        guard var urlComponents = URLComponents(url: Constants.defaultBaseURL, resolvingAgainstBaseURL: true) else {
            assertionFailure("Generate profile request URLComponent initialization failed")
            return nil
        }
        urlComponents.path = "/users/\(username)"
        guard let url = urlComponents.url else {
            assertionFailure("Generate token request URL initialization failed")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue( "Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

struct UserResult: Decodable {
    let profileImage: ProfileImage
    
    private enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct ProfileImage: Decodable {
    let small: String
    let medium: String
    let large: String
    
    private enum CodingKeys: String, CodingKey {
        case small = "small"
        case medium = "medium"
        case large = "large"
    }
}
