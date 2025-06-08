//
//  Image_FeedUITestsLaunchTests.swift
//  Image FeedUITests
//
//  Created by Timur Lavrukhin on 8.6.2025.
//

import XCTest

final class Image_FeedUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let testTarget = Image_FeedUITests()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app
        do {
            try testTarget.testAuth()
            try testTarget.testFeed()
            try testTarget.testProfile()
        }
        catch let error {
            print(error.localizedDescription)
        }
        
//        let attachment = XCTAttachment(screenshot: app.screenshot())
//        attachment.name = "Launch Screen"
//        attachment.lifetime = .keepAlways
//        add(attachment)
    }
}
