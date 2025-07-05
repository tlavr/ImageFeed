//
//  WebViewPresenterSpy.swift
//  Image FeedTests
//
//  Created by Timur Lavrukhin on 8.6.2025.
//

import ImageFeed
import Foundation

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var view: WebViewViewControllerProtocol?
    
    private(set) var lastProgressValue: Double?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
        didUpdateProgressValue(0.75)
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        lastProgressValue = newValue
    }
    
    func code(from url: URL) -> String? {
        return nil
    }
}
