//
//  ProfileStorage.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 12.5.2025.
//

import Foundation

final class ProfileStorage {
    // MARK: - Public properties
    var userID: String? {
        get { storage.string(forKey: Keys.userID.rawValue) ?? nil }
        set { storage.set(newValue, forKey: Keys.userID.rawValue) }
    }
    var username: String? {
        get { storage.string(forKey: Keys.username.rawValue) ?? nil }
        set { storage.set(newValue, forKey: Keys.username.rawValue) }
    }
    var firstName: String? {
        get { storage.string(forKey: Keys.userFirstName.rawValue) ?? nil }
        set { storage.set(newValue, forKey: Keys.userFirstName.rawValue) }
    }
    var lastName: String? {
        get { storage.string(forKey: Keys.userLastName.rawValue) ?? nil }
        set { storage.set(newValue, forKey: Keys.userLastName.rawValue) }
    }
    var totalPhotos: Int? {
        get { storage.integer(forKey: Keys.userTotalPhotos.rawValue) }
        set { storage.set(newValue, forKey: Keys.userTotalPhotos.rawValue)}
    }
    
    // MARK: - Public methods
    func store(profile: ProfileModel) {
        userID = profile.userID
        username = profile.username
        firstName = profile.firstName
        lastName = profile.lastName
        totalPhotos = profile.totalPhotos
    }
    
    // MARK: - Private properties
    private let storage: UserDefaults = .standard
    private enum Keys: String {
        case userID
        case username
        case userFirstName
        case userLastName
        case userTotalPhotos
    }
}
