//
//  ProfileStorage.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 12.5.2025.
//

import Foundation
import SwiftKeychainWrapper

final class ProfileStorage {
    // MARK: - Public properties
    var userID: String? {
        get { storage.string(forKey: Keys.userID.rawValue) ?? nil }
        set {
            guard let newValue else { return }
            let isSuccess = storage.set(newValue, forKey: Keys.userID.rawValue)
            guard isSuccess else {
                logProfileStorageError()
                return
            }
        }
    }
    var username: String? {
        get { storage.string(forKey: Keys.username.rawValue) ?? nil }
        set {
            guard let newValue else { return }
            let isSuccess = storage.set(newValue, forKey: Keys.username.rawValue)
            guard isSuccess else {
                logProfileStorageError()
                return
            }
        }
    }
    var loginname: String? {
        get {
            if let username = storage.string(forKey: Keys.username.rawValue) {
                return "@"+username
            } else {
                return nil
            }
        }
    }
    var firstName: String? {
        get { storage.string(forKey: Keys.userFirstName.rawValue) ?? nil }
        set {
            guard let newValue else { return }
            let isSuccess = storage.set(newValue, forKey: Keys.userFirstName.rawValue)
            guard isSuccess else {
                logProfileStorageError()
                return
            }
        }
    }
    var lastName: String? {
        get { storage.string(forKey: Keys.userLastName.rawValue) ?? nil }
        set {
            guard let newValue else { return }
            let isSuccess = storage.set(newValue, forKey: Keys.userLastName.rawValue)
            guard isSuccess else {
                logProfileStorageError()
                return
            }
        }
    }
    var name: String? {
        get {
            if let firstName = storage.string(forKey: Keys.userFirstName.rawValue),
               let lastName = storage.string(forKey: Keys.userLastName.rawValue) {
                return "\(firstName) \(lastName)"
            } else {
                return nil
            }
        }
    }
    var bio: String? {
        get { storage.string(forKey: Keys.userBio.rawValue) ?? nil }
        set {
            guard let newValue else { return }
            let isSuccess = storage.set(newValue, forKey: Keys.userBio.rawValue)
            guard isSuccess else {
                logProfileStorageError()
                return
            }
        }
    }
    var totalPhotos: Int? {
        get { storage.integer(forKey: Keys.userTotalPhotos.rawValue) }
        set {
            guard let newValue else { return }
            let isSuccess = storage.set(newValue, forKey: Keys.userTotalPhotos.rawValue)
            guard isSuccess else {
                logProfileStorageError()
                return
            }
        }
    }
    
    // MARK: - Private properties
    private let storage: KeychainWrapper = .standard
    private enum Keys: String {
        case userID
        case username
        case userFirstName
        case userLastName
        case userBio
        case userTotalPhotos
    }
    
    // MARK: - Public methods
    func store(profile: ProfileModel) {
        userID = profile.userID
        username = profile.username
        firstName = profile.firstName
        lastName = profile.lastName
        bio = profile.bio
        totalPhotos = profile.totalPhotos
    }
    
    func reset() {
        storage.removeObject(forKey: Keys.userID.rawValue)
        storage.removeObject(forKey: Keys.username.rawValue)
        storage.removeObject(forKey: Keys.userFirstName.rawValue)
        storage.removeObject(forKey: Keys.userLastName.rawValue)
        storage.removeObject(forKey: Keys.userBio.rawValue)
        storage.removeObject(forKey: Keys.userTotalPhotos.rawValue)
    }
    
    func getProfile() -> ProfileModel? {
        guard let userID = userID else { return nil }
        return ProfileModel(userID: userID,
                            username: username ?? "",
                            loginname: loginname ?? "",
                            firstName: firstName ?? "",
                            lastName: lastName ?? "",
                            name: name ?? "",
                            bio: bio ?? "",
                            totalPhotos: totalPhotos ?? 0)
    }
    
    // MARK: -Private methods
    private func logProfileStorageError() {
        ErrorLoggingService.shared.log(
            from: String(describing: self),
            with: .Database,
            error: CommonErrors.profileStorage
        )
    }
}
