//
//  ProfileViewPresenterFake.swift
//  Image FeedTests
//
//  Created by Timur Lavrukhin on 8.6.2025.
//

@testable import ImageFeed
import Foundation

final class ProfileViewPresenterMock: ProfileViewPresenterProtocol {
    // MARK: -Public properties
    weak var view: ProfileViewControllerProtocol?
    var isProfileFilled = false
    var isLogoutCalled = false
    var isAvatarSetCalled = false
    
    // MARK: -Public methods
    init(view: ProfileViewControllerProtocol, isProfileFilled: Bool = false) {
        self.view = view
        self.isProfileFilled = isProfileFilled
    }
    
    func getLogin() -> String {
        if isProfileFilled {
            return "Login"
        } else {
            return ""
        }
    }
    
    func getName() -> String {
        if isProfileFilled {
            return "Name"
        } else {
            return ""
        }
    }
    
    func getBio() -> String {
        if isProfileFilled {
            return "Bio"
        } else {
            return ""
        }
    }
    
    func performLogout() {
        isLogoutCalled = true
    }
    
    func setAvatar() {
        isAvatarSetCalled = true
    }
}
