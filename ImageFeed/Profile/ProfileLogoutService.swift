//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 1.6.2025.
//

import Foundation
import WebKit

final class ProfileLogoutService {
    // MARK: -Public properties
    static let shared = ProfileLogoutService()
    
    // MARK: -Private properies
    private var tokenStorage = OAuth2TokenStorage()
    private var profileStorage = ProfileStorage()
    
    // MARK: -Public methods
    func logout() {
        cleanCookies()
        tokenStorage.reset()
        profileStorage.reset()
        ProfileImageService.shared.reset()
        OAuth2Service.shared.reset()
        ImagesListService.shared.reset()
        ProfileService.shared.reset()
    }
    
    // MARK: -Private methods
    private init() { }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}

