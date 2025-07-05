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
        //Given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController

        //When
        _ = viewController.view

        //Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
        XCTAssertEqual(presenter.lastProgressValue, 0.75)
    }

    func testPresenterCallsLoadRequest() {
        //Given
        let viewController = WebViewViewControllerSpy()
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        viewController.presenter = presenter
        presenter.view = viewController

        //When
        presenter.viewDidLoad()

        //Then
        XCTAssertTrue(viewController.loadRequestCalled)
        XCTAssertEqual(viewController.lastProgressValue, 0.15)
        XCTAssertEqual(viewController.progressHidden, false)
    }

    func testProgressVisibleWhenLessThenOne() {
        //Given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6

        //When
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)

        //Then
        XCTAssertFalse(shouldHideProgress)
    }

    func testProgressHiddenWhenOne() {
        //Given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1.0

        //When
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)

        //Then
        XCTAssertTrue(shouldHideProgress)
    }

    func testAuthHelperAuthURL() {
        //Given
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)

        //When
        let url = authHelper.authURL()
        guard let urlString = url?.absoluteString else {
            XCTFail("Auth string is uncorrectly constructed!")
            return
        }

        //Then
        XCTAssertTrue(urlString.contains(configuration.authURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
    }

    func testCodeFromURL() {
        //Given
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
        urlComponents.queryItems = [URLQueryItem(name: "code", value: "test code")]
        guard let url = urlComponents.url else {
            XCTFail("Wrong URL!")
            return
        }
        let authHelper = AuthHelper()

        //When
        let code = authHelper.code(from: url)

        //Then
        XCTAssertEqual(code, "test code")
    }

}
