//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 27.4.2025.
//

import UIKit
import ProgressHUD

final class AuthViewController: UIViewController {
    // MARK: - Public properties
    var delegate: AuthViewControllerDelegate?
    
    // MARK: - Private properties
    private let showWebViewSegueIdentifier = "ShowWebView"
    private let oauth2Service = OAuth2Service.shared
    private let tokenStorage = OAuth2TokenStorage()
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
    }
    
    // MARK: - Public methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let viewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Failed to prepare for \(showWebViewSegueIdentifier)")
                return
            }
            viewController.authDelegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Private methods
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "AuthBackButton")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "AuthBackButton")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .ypBlack
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true)
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                ProgressHUD.dismiss()
                switch result {
                case .success(let token):
                    self.tokenStorage.store(token: token)
                    self.delegate?.didAuthenticate(self)
                case .failure(let error):
                    assertionFailure("Error occured during token data loading: \(error)")
                }
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
