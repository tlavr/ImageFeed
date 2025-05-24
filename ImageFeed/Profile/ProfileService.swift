//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 24.5.2025.
//
import UIKit

final class ProfileService {
    // MARK: -Public properties
    static let shared = ProfileService()
    
    // MARK: -Private properties
    private var task: URLSessionTask?
    private var lastToken: String?
    
    private enum ProfileServiceError: Error {
        case invalidRequest
    }
    private enum JsonError: Error {
        case decoderError
    }
    
    // MARK: -Public methods
    func fetchProfile(_ token: String, completion: @escaping (Result<ProfileModel, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastToken != token else {
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        task?.cancel()
        lastToken = token
        
        guard
            let URLRequest = generateProfileRequest(token)
        else
        {
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.data(for: URLRequest) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                do {
                    let profileData = try JSONDecoder().decode(ProfileDataResponseBody.self, from: data)
                    let profile = ProfileModel(
                        userID: profileData.userID,
                        username: profileData.username,
                        loginname: "@"+"\(profileData.username)",
                        firstName: profileData.firstName,
                        lastName: profileData.lastName ?? "",
                        name: profileData.firstName + " " + (profileData.lastName ?? ""),
                        bio: profileData.bio ?? "",
                        totalPhotos: profileData.totalPhotos ?? 0
                    )
                    completion(.success(profile))
                } catch {
                    completion(.failure(JsonError.decoderError))
                }
            case .failure(let error):
                completion(.failure(error))
            }
            self.task = nil
            self.lastToken = nil
        }
        self.task = task
        task.resume()
    }
    
    // MARK: -Private methods
    private init() {}
    
    private func generateProfileRequest(_ token: String) -> URLRequest? {
        guard var urlComponents = URLComponents(url: Constants.defaultBaseURL, resolvingAgainstBaseURL: true) else {
            assertionFailure("Generate profile request URLComponent initialization failed")
            return nil
        }
        urlComponents.path = "/me"
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

struct ProfileDataResponseBody: Decodable {
    let userID: String
    let username: String
    let firstName: String
    let lastName: String?
    let bio: String?
    let totalPhotos: Int?
    
    private enum CodingKeys: String, CodingKey {
        case userID = "id"
        case username = "username"
        case firstName = "first_name"
        case lastName = "last_name"
        case bio = "bio"
        case totalPhotos = "total_photos"
    }
}
