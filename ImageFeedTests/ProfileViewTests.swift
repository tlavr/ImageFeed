//
//  ProfileViewTests.swift
//  Image FeedTests
//
//  Created by Timur Lavrukhin on 8.6.2025.
//

@testable import ImageFeed
import XCTest

final class ProfileViewTests: XCTestCase {
    // Test profileImageView has placeholder image initially
    func testProfileImageViewPlaceholder() {
        // Given
        let profileViewController = ProfileViewController()
        
        // When
        _ = profileViewController.profileImageView
        
        // Then
        XCTAssertEqual(profileViewController.profileImageView.image, UIImage(named: "ProfileImagePlaceholder"))
    }
    
    
    // Test labels are empty OR correctly filled
    func testProfileEmpty() {
        // Given
        let profileViewController = ProfileViewController()
        let profileViewPresenter = ProfileViewPresenterMock(view: profileViewController)
        profileViewController.presenter = profileViewPresenter
        
        // When
        profileViewController.viewDidLoad()
        
        // Then
        XCTAssertEqual(profileViewController.accountNameLabel.text, "")
        XCTAssertEqual(profileViewController.customTextLabel.text, "")
        XCTAssertEqual(profileViewController.usernameLabel.text, "")
    }
    
    func testProfileFilled() {
        // Given
        let profileViewController = ProfileViewController()
        let profileViewPresenter = ProfileViewPresenterMock(view: profileViewController, isProfileFilled: true)
        profileViewController.presenter = profileViewPresenter
        
        // When
        profileViewController.viewDidLoad()
        
        // Then
        XCTAssertEqual(profileViewController.accountNameLabel.text, "Login")
        XCTAssertEqual(profileViewController.customTextLabel.text, "Bio")
        XCTAssertEqual(profileViewController.usernameLabel.text, "Name")
    }
    
    // Test avatar is set from presenter from viewDidLoad
    func testAvatarSet() {
        // Given
        let profileViewController = ProfileViewController()
        let profileViewPresenter = ProfileViewPresenterMock(view: profileViewController)
        profileViewController.presenter = profileViewPresenter
        
        // When
        profileViewController.viewDidLoad()
        
        // Then
        XCTAssertTrue(profileViewPresenter.isAvatarSetCalled)
    }
}
