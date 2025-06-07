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
    private var task: URLSessionTask?
    private var lastCode: String?
    
    // MARK: - Public methods
    func reset() {
        task = nil
        lastCode = nil
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastCode != code else {
            completion(.failure(CommonErrors.repeatedRequest))
            return
        }
        task?.cancel()
        lastCode = code
        
        guard let URLRequest = generateTokenRequest(code: code) else {
            completion(.failure(CommonErrors.invalidUrlRequest))
            return
        }
        
        let task = URLSession.shared.objectTask(for: URLRequest) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                completion(.success(token.accessToken))
            case .failure(let error):
                completion(.failure(error))
            }
            self.task = nil
            self.lastCode = nil
        }
        self.task = task
        task.resume()
    }
    
    // MARK: - Private methods
    private init() {}
    
    private func generateTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: AuthConstants.tokenRequestURLString) else {
            ErrorLoggingService.shared.log(
                from: String(describing: self),
                with: .UrlSession,
                error: CommonErrors.urlComponent
            )
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
            ErrorLoggingService.shared.log(
                from: String(describing: self),
                with: .UrlSession,
                error: CommonErrors.url
            )
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}
