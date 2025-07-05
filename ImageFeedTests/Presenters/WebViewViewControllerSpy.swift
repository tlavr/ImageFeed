//
//  WebViewViewControllerSpy.swift
//  Image FeedTests
//
//  Created by Timur Lavrukhin on 8.6.2025.
//

import ImageFeed
import Foundation

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: ImageFeed.WebViewPresenterProtocol?
    
    var loadRequestCalled: Bool = false
    
    func load(request: URLRequest) {
        loadRequestCalled = true
        setProgressValue(0.15)
        setProgressHidden(false)
    }
    
    private(set) var lastProgressValue: Float?
    private(set) var progressHidden: Bool?

    func setProgressValue(_ newValue: Float) {
        lastProgressValue = newValue
    }

    func setProgressHidden(_ isHidden: Bool) {
        progressHidden = isHidden
    }
}
