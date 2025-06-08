//
//  Image_FeedUITests.swift
//  Image FeedUITests
//
//  Created by Timur Lavrukhin on 8.6.2025.
//

import XCTest

enum UITestsConstants {
    #warning("Update this with your own credentials")
    static let email = ""
    static let password = ""
    static let name = ""
    static let username = ""
}

final class Image_FeedUITests: XCTestCase {
    // MARK: -Private properies
    let app = XCUIApplication()
    
    // MARK: -Public methods
    override func setUpWithError() throws {
        app.launch()
        continueAfterFailure = false
    }
    
    @MainActor
    func testAuth() throws {
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
        
//        cellToLike.buttons.firstMatch.tap()
//        cellToLike.buttons.firstMatch.tap()
        cellToLike.buttons["LikeButton"].tap()
        cellToLike.buttons["LikeButton"].tap()
//        
        sleep(2)
        
        cellToLike.tap()
        
        sleep(2)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        // Zoom in
        image.pinch(withScale: 3, velocity: 1) // zoom in
        // Zoom out
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["SingleImageBackButton"]
        navBackButtonWhiteButton.tap()
    }
    
    @MainActor
    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        XCTAssertTrue(app.staticTexts[UITestsConstants.name].exists)
        XCTAssertTrue(app.staticTexts[UITestsConstants.username].exists)
        
        app.buttons["LogoutButton"].tap()
        
        app.alerts["Bye bye!"].scrollViews.otherElements.buttons["Да"].tap()
    }
    
//    @MainActor
//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
//            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTApplicationLaunchMetric()]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
}
