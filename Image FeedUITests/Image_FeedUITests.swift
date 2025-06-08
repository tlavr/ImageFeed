//
//  Image_FeedUITests.swift
//  Image FeedUITests
//
//  Created by Timur Lavrukhin on 8.6.2025.
//

import XCTest

enum UITestsConstants {
#warning("Update using your own credentials!")
    static let email = "your.email@example.com"
    static let password = "Your Password"
    static let name: String = "Your Profile Name"
    static let username: String = "@your_profile_username"
}

final class Image_FeedUITests: XCTestCase {
    // MARK: -Private properies
    let app = XCUIApplication()
    
    // MARK: -Public methods
    override func setUpWithError() throws {
        try super.setUpWithError()
        app.launch()
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        app.terminate()
    }
    
    @MainActor
    func testAuth() throws {
        sleep(2)
        app.buttons["Authenticate"].tap()
        let webView = app.webViews["UnsplashWebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText(UITestsConstants.email)
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        passwordTextField.typeText(UITestsConstants.password)
        webView.swipeUp()
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    @MainActor
    func testFeed() throws {
        let tablesQuery = app.tables
        
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        sleep(2)
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        cellToLike.buttons.firstMatch.tap()
        sleep(2)
        cellToLike.buttons.firstMatch.tap()
        sleep(2)
        cellToLike.tap()
        sleep(2)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["SingleImageBackButton"]
        navBackButtonWhiteButton.tap()
    }
    
    @MainActor
    func testProfile() throws {
        sleep(1)
        app.tabBars.buttons.element(boundBy: 1).tap()
        sleep(2)
        
        XCTAssertTrue(app.staticTexts[UITestsConstants.name].exists)
        XCTAssertTrue(app.staticTexts[UITestsConstants.username].exists)
        
        app.buttons["LogoutButton"].tap()
        sleep(1)
        app.alerts["LogoutAlert"].scrollViews.otherElements.buttons["Да"].tap()
    }
}
