//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 2.5.2025.
//

import UIKit

final class OAuth2Service {
    // MARK: - Public properties
    static let shared = OAuth2Service()
    
    // MARK: - Private properties
    private enum JsonError: Error {
        case decoderError
    }
    
    // MARK: - Public methods
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let URLRequest = generateTokenRequest(code: code) else { return }
        
        let task = URLSession.shared.data(for: URLRequest) { result in
            switch result {
            case .success(let data):
                do {
                    let token = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    completion(.success(token.accessToken))
                } catch {
                    completion(.failure(JsonError.decoderError))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    // MARK: - Private methods
    private init() {}
    
    private func generateTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: AuthConstants.tokenRequestURLString) else {
            assertionFailure("Generate token request URLComponent initialization failed")
            return nil
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        guard let url = urlComponents.url else {
            assertionFailure("Generate token request URL initialization failed")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}

enum AuthConstants {
    static let tokenRequestURLString = "https://unsplash.com/oauth/token"
}

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let tokenScope: String
    let createdAt: Int
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case tokenScope = "scope"
        case createdAt = "created_at"
    }
}
