//
//  WebViewPresenter.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 8.6.2025.
//

import Foundation

final class WebViewPresenter: WebViewPresenterProtocol {
    // MARK: -Public properties
    weak var view: WebViewViewControllerProtocol?
    var authHelper: AuthHelperProtocol
    
    // MARK: - View lifecycle
    func viewDidLoad() {
        guard let request = authHelper.authRequest() else {
            ErrorLoggingService.shared.log(
                from: String(describing: self),
                with: .Network,
                error: CommonErrors.invalidUrlRequest
            )
            return
        }
        view?.load(request: request)
        didUpdateProgressValue(0.15)
    }
    
    // MARK: -Public methods
    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }
    
    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
    
    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }
}
