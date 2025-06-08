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
        // MARK: -Given
        let profileViewController = ProfileViewController()
        
        // MARK: -When
        _ = profileViewController.profileImageView
        
        // MARK: -Then
        XCTAssertEqual(profileViewController.profileImageView.image, UIImage(named: "ProfileImagePlaceholder"))
    }
    
    
    // Test labels are empty OR correctly filled
    func testProfileEmpty() {
        // MARK: -Given
        let profileViewController = ProfileViewController()
        let profileViewPresenter = ProfileViewPresenterFake(view: profileViewController)
        profileViewController.presenter = profileViewPresenter
        
        // MARK: -When
        profileViewController.viewDidLoad()
        
        // MARK: -Then
        XCTAssertEqual(profileViewController.accountNameLabel.text, "")
        XCTAssertEqual(profileViewController.customTextLabel.text, "")
        XCTAssertEqual(profileViewController.usernameLabel.text, "")
    }
    
    func testProfileFilled() {
        // MARK: -Given
        let profileViewController = ProfileViewController()
        let profileViewPresenter = ProfileViewPresenterFake(view: profileViewController, isProfileFilled: true)
        profileViewController.presenter = profileViewPresenter
        
        // MARK: -When
        profileViewController.viewDidLoad()
        
        // MARK: -Then
        XCTAssertEqual(profileViewController.accountNameLabel.text, "Login")
        XCTAssertEqual(profileViewController.customTextLabel.text, "Bio")
        XCTAssertEqual(profileViewController.usernameLabel.text, "Name")
    }
    
    // Test avatar is set from presenter from viewDidLoad OR notification?
    func testAvatarSet() {
        // MARK: -Given
        let profileViewController = ProfileViewController()
        let profileViewPresenter = ProfileViewPresenterFake(view: profileViewController)
        profileViewController.presenter = profileViewPresenter
        
        // MARK: -When
        profileViewController.viewDidLoad()
        
        // MARK: -Then
        XCTAssertTrue(profileViewPresenter.isAvatarSetCalled)
    }

}

