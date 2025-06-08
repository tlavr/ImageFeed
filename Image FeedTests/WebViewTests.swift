//
//  Image_FeedTests.swift
//  Image FeedTests
//
//  Created by Timur Lavrukhin on 8.6.2025.
//

@testable import ImageFeed
import XCTest

final class WebViewTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //MARK: -Given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController

        //MARK: -When
        _ = viewController.view

        //MARK: -Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testPresenterCallsLoadRequest() {
        //MARK: -Given
        let viewController = WebViewViewControllerSpy()
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        viewController.presenter = presenter
        presenter.view = viewController

        //MARK: -When
        presenter.viewDidLoad()

        //MARK: -Then
        XCTAssertTrue(viewController.loadRequestCalled)
    }

    func testProgressVisibleWhenLessThenOne() {
        //MARK: -Given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6

        //MARK: -When
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)

        //MARK: -Then
        XCTAssertFalse(shouldHideProgress)
    }

    func testProgressHiddenWhenOne() {
        //MARK: -Given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1.0

        //MARK: -When
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)

        //MARK: -Then
        XCTAssertTrue(shouldHideProgress)
    }

    func testAuthHelperAuthURL() {
        //MARK: -Given
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)

        //MARK: -When
        let url = authHelper.authURL()
        guard let urlString = url?.absoluteString else {
            XCTFail("Auth string is uncorrectly constructed!")
            return
        }

        //MARK: -Then
        XCTAssertTrue(urlString.contains(configuration.authURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
    }

    func testCodeFromURL() {
        //MARK: -Given
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
        urlComponents.queryItems = [URLQueryItem(name: "code", value: "test code")]
        guard let url = urlComponents.url else {
            XCTFail("Wrong URL!")
            return
        }
        let authHelper = AuthHelper()

        //MARK: -When
        let code = authHelper.code(from: url)

        //MARK: -Then
        XCTAssertEqual(code, "test code")
    }

}
