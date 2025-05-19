//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 2.5.2025.
//

import Foundation

final class OAuth2TokenStorage {
    // MARK: - Public properties
    var token: String? {
        get { storage.string(forKey: Keys.authToken.rawValue) ?? nil }
        set { storage.set(newValue, forKey: Keys.authToken.rawValue) }
    }
    
    // MARK: - Public methods
    func store(token: String) {
        self.token = token
    }    
    func reset() {
        token = nil
        storage.removeObject(forKey: Keys.authToken.rawValue)
    }
    
    // MARK: - Private properties
    private let storage: UserDefaults = .standard
    private enum Keys: String {
        case authToken
    }
}
