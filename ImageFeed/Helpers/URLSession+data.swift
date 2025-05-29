//
//  URLSession+data.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 2.5.2025.
//

import UIKit

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        })
        return task
    }
    
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        let task = data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let decodedData = try decoder.decode(T.self, from: data)
                    completion(.success(decodedData))
                } catch {
                    completion(.failure(JsonError.decoderError(data)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return task
    }
}

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .httpStatusCode(let code):
            return NSLocalizedString("HTTP status code: \(code)", comment: "HTTP Error")
        case .urlRequestError(let error):
            return NSLocalizedString("URL Request Error: \(error.localizedDescription)", comment: "URL Request Error")
        case .urlSessionError:
            return NSLocalizedString("URL Session Error", comment: "URL Session Error")
        }
    }
}

enum JsonError: Error {
    case decoderError(Data)
}

extension JsonError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .decoderError(let data):
            return NSLocalizedString("JSON Decoder Error during processing following data: \(String(data: data, encoding: .utf8) ?? "Unable to convert data to string")", comment: "JSON Decoder Error")
        }
    }
}
