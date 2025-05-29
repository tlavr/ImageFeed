//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 2.5.2025.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    // MARK: - Public properties
    var token: String? {
        get { storage.string(forKey: Keys.authToken.rawValue) ?? nil }
        set {
            guard let newValue else { return }
            let isSuccess = storage.set(newValue, forKey: Keys.authToken.rawValue)
            guard isSuccess else {
                ErrorLoggingService.shared.log(
                    from: String(describing: self),
                    with: .Database,
                    error: CommonErrors.tokenStorage
                )
                return
            }
        }
    }
    
    // MARK: - Public methods
    func store(token: String) {
        self.token = token
    }    
    func reset() {
        storage.removeObject(forKey: Keys.authToken.rawValue)
    }
    
    // MARK: - Private properties
    private let storage: KeychainWrapper = .standard
    private enum Keys: String {
        case authToken
    }
}
