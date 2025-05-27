//
//  ErrorLoggingService.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 25.5.2025.
//

import Foundation

final class ErrorLoggingService {
    // MARK: -Public properties
    static let shared = ErrorLoggingService()
    
    // MARK: -Public methods
    func log(from service: String, with type: ErrorType, error: Error) {
        print("[\(service)]: \(type) : \(error.localizedDescription)")
    }
    
    // MARK: -Private methods
    private init() {}
}

enum ErrorType {
    case Network
    case DataDecoding
    case UrlSession
    case SeguePreparation
    case Database
    case Window
    case ControllerPresentation
}

enum CommonErrors: Error {
    case repeatedRequest
    case invalidUrlRequest
    case urlComponent
    case url
    case urlSession
    case seguePreparation(String)
    case segueDestination
    case tokenStorage
    case windowConfiguration
    case controllerPresentation(String)
}

extension CommonErrors: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .repeatedRequest:
            return NSLocalizedString("There are several attempts to make the same request!", comment: "Repeated Request")
        case .invalidUrlRequest:
            return NSLocalizedString("There is an issue happened during URL request construction!", comment: "Invalid URL Request")
        case .urlComponent:
            return NSLocalizedString("There is an issue happened during URLComponents construction!", comment: "URLComponents")
        case .url:
            return NSLocalizedString("There is an issue happened during URL construction!", comment: "URL")
        case .urlSession:
            return NSLocalizedString("There is an issue happened during URLSession construction!", comment: "URLSession")
        case .seguePreparation(let segueName):
            return NSLocalizedString("There is an issue happened during segue \(segueName) preparation!", comment: "Segue Preparation")
        case .segueDestination:
            return NSLocalizedString("There is an issue happened during segue destination selection!", comment: "Segue Destination")
        case .tokenStorage:
            return NSLocalizedString("Token Storage error happened!", comment: "Token Storage")
        case .windowConfiguration:
            return NSLocalizedString("Invalid window configuration!", comment: "Window Configuration")
        case .controllerPresentation(let message):
            return NSLocalizedString("Error during attempt to present \(message)", comment: "Controller Presentation")
        }
    }
}
